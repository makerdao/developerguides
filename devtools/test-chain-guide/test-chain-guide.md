# Test Chain Guide

**Level**: Intermediate    

**Estimated-Time**: 30 - 50 minutes   

## Overview

This guide is intended to give an introduction on how to use Maker’s custom test chain. This test chain has all of Maker’s smart contracts deployed on it, so you as a developer can start building your dApps on top of Maker’s system. In addition, you can also use our [dai.js](https://docs.makerdao.com/building-on-top-of-the-maker-protocol/dai.js-wiki) library with this test chain.

## Learning Objectives

Learn how to deploy and interact with the test chain for your development purposes.

## Pre-requisites

You can run the testchain on MacOS/Linux systems and also on the [Windows Subsystem For Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10).
You need to have [dapp.tools](https://dapp.tools/), [NodeJs](https://nodejs.org/en/), [jq](https://stedolan.github.io/jq/download/) and bash installed on your machine.

## Sections

- Note on Windows Subsystem for Linux
- Benefits of using the test chain
- Getting Started
- Options
- Interacting with Maker Protocol contracts
    - Open a Vault with dai.js
    - Use Maker Protocol contracts to draw some Dai with seth

## Note on Windows Subsystem for Linux

If you want to run this test chain on the Windows Subsystem for Linux, you’ll run into some issues when installing the [nix](https://dapp.tools/) package manager.    

This [thread](https://github.com/NixOS/nix/issues/1203#issuecomment-275089112) has some solutions to the installation process. In summary, their solution is to create a file in `/etc/nix/nix.conf` and add these flags in the file:

```text
use-sqlite-wal = false
sandbox = false
```
Have a go and see if it works for you.

## Benefits of using the test chain
This test chain has Maker’s smart contracts deployed on it. This is very convenient for you as a developer to interact or build smart contracts that interact with the Maker system. 
In addition, you have the convenience of tweaking your chain configurations to suit your needs, such as changing the block time or deploying your own set of smart contracts when instantiating the chain.

## Getting Started

In a terminal, execute the following commands.    

To [download](https://github.com/makerdao/testchain) the repo to your machine execute:

```
git clone https://github.com/makerdao/testchain.git
cd testchain
```
Install all the necessary dependencies

```bash
npm install
or
yarn install
```

To launch the chain
```bash
scripts/launch -s default --fast
```

In your terminal, after some time you'll see this text:
```
Starting Ganache...
Launched testchain in --- seconds.
Press Ctrl-C to stop the test chain.
```

If you see this, then congrats, you have your test chain running on `http://127.0.0.1:2000`

## Options
You have some configuration options to run your test chain.   
In order to add these options you need to add some flags `-- optionName` as a suffix to the start command. 

For example:   
If you want to run the test chain with verbose option, you run the bellow script:

This will show you the chain logs in the terminal
```bash
scripts/launch -s default --fast --verbose
```
Here you change your port and add verbose option
```bash
scripts/launch -s default --fast --verbose -p 2001 
```

For more options check out our [repo](https://github.com/makerdao/testchain#options).

## Interacting with Maker Protocol contracts
You’ll find all the necessary Maker contract addresses in the `out/addresses-mcd.json` file in the testchain folder. You can use these addresses to develop your own tools that interact with Maker contracts. Use our own [dai.js](https://docs.makerdao.com/building-on-top-of-the-maker-protocol/dai.js-wiki) library or interact through the command line with [seth](https://dapp.tools/seth/). We will go through both of these methods now.

#### Open a Vault with [dai.js](https://docs.makerdao.com/building-on-top-of-the-maker-protocol/dai.js-wiki)

To start from scratch:
- Start the testchain in another terminal, as you’ll be connecting to it when running the js file.
- In a directory of your choice, in another terminal, initiate an empty project with `npm init -y`
- Add the `@makerdao/dai` and the `@makerdao/dai-plugin-mcd` packages: `npm i --save @makerdao/dai @makerdao/dai-plugin-mcd`
- Create a `vault.js` file where you’ll write your script.
- Copy the below example in your js file
- Run the file with `node vault.js`

Below is an example that shows the process of opening a Vault in the Multi Collateral Dai system, locking some Eth and drawing some Dai:

```javascript
const Maker = require('@makerdao/dai');
const McdPlugin = require('@makerdao/dai-plugin-mcd').default;
const ETH = require('@makerdao/dai-plugin-mcd').ETH;
const MDAI = require('@makerdao/dai-plugin-mcd').MDAI;

async function start() {
  try {
    const maker = await Maker.create('test', {
      plugins: [
        [McdPlugin, {}]
      ]
    });
    await maker.authenticate();

    const balance = await maker
      .service('token')
      .getToken('ETH')
      .balance();
    console.log('Account: ', maker.currentAddress());
    console.log('Balance', balance.toString());

    const cdp = await maker
      .service('mcd:cdpManager')
      .openLockAndDraw('ETH-A', ETH(1), MDAI(20));

    console.log('Opened CDP #'+cdp.id);
    console.log('Collateral amount:'+cdp.collateralAmount.toString());
    console.log('Debt Value:'+cdp.debtValue.toString());

  } catch (error) {
    console.log('error', error);
  }
}

start();
```

If everything went according to plan, you should see an output like the one below:
```
Web3 is initializing...
Web3 is connecting...
Web3 version:  1.2.1
Web3 is authenticating...
Account:  0x16fb96a5fa0427af0c8f7cf1eb4870231c8154b6
Balance 70.85 ETH
Opened CDP #6
Collateral amount:1.00 ETH
Debt Value:20.00 MDAI
```

### Interact with contracts directly with [seth](https://dapp.tools/seth/)

In this example, we will draw Dai by depositing ETH into the MCD contracts that are deployed on our testchain. We will interact with the smart contracts directly, so there’s more steps involved.   

As a prerequisite, you need to have the test chain running in a terminal with the `scripts/launch -s default --fast ` command, if you haven’t done so already.  Note: If you see a message saying the testchain is already running on port 2000, you can kill it with `kill -9 $(lsof -t -i:2000)`

Next, go to another terminal window or tab.  To start, we will need to set up and export some environmental variables in our second  terminal. These variables will help you connect to the test chain and interact with the MCD system through seth. 

Let’s add the variables that will set our account and connection with the test chain. In your second terminal tab, in your home location, add these variables:

```
export ETH_FROM=0x16fb96a5fa0427af0c8f7cf1eb4870231c8154b6
```
- Taken from `testchain/out/addresses-mcd.json` under `ETH_FROM`.  
You need to add this address because it is already filled with some ether for you by the test chain.

```
export ETH_RPC_URL=http://localhost:2000
```
- This sets the connection to the test chain.

We are using an account handled by the ethereum client, and as such we need to instruct `seth` not to use local keystores and instead use to use the RPC account to sign the transactions:
```
export ETH_RPC_ACCOUNTS=1
```

You can try to test your connection by seeing your account balance:

```
seth balance $ETH_FROM
```
If connection is right, you’ll see this (your values might differ):
```
94829630380000000000
```

Next, we can start adding the MCD contract addresses. You’ll find these addresses in the file `testchain/out/addresses-mcd.json`. Make sure to be in the testchain directory. The following command will parse the json file and store the addresses as environment variables:
```
eval $(jq -r 'to_entries|map("\(.key)=\(.value|tostring)")|.[]' out/addresses-mcd.json)
```

####Opening a Vault

We will begin by setting a few useful variables:
```
export ilk=$(seth --to-bytes32 "$(seth --from-ascii "ETH-A")")
```
- `ilk` - a collateral type
- Setting the `ilk` variable to the `ETH` type of collateral and converting it to hex and bytes32 format.

We also set the gas limit for our transactions (with the default, certain transactions are likely to fail):
```
export ETH_GAS=1000000
```

First we open the Vault using the CDP Manager:
```
seth send -F $ETH_FROM $CDP_MANAGER 'open(bytes32,address)' "$ilk" "$ETH_FROM" 
```

This call does not return anything useful, so we use these commands to determine the Id and urn address of the vault we just opened:
```
export cdpId=$(seth --to-dec $(seth call $CDP_MANAGER 'last(address)' $ETH_FROM))
export urn=$(seth call $CDP_MANAGER 'urns(uint)(address)' $cdpId)
echo $cdpId
echo $urn
```

Then we deposit 5 eth into the `WETH` adapter:
```
seth send $ETH 'deposit()' --value $(seth --to-wei 5 ETH)
```

And we approve `MCD_JOIN_ETH_A` to withdraw some `WETH`:
```
seth send $ETH 'approve(address,uint256)' $MCD_JOIN_ETH_A $(seth --to-uint256 $(seth --to-wei 5 ETH))
```
To finally lock the 5 ether into the ether adapter, to the benefit of our vault (urn):
```
seth send $MCD_JOIN_ETH_A 'join(address,uint256)' $urn $(seth --to-uint256 $(seth --to-wei 5 ETH))
```
As a validation, we can confirm that the collateral is available to our vault:
```
seth --from-wei $(seth --to-dec $(seth call $MCD_VAT 'gem(bytes32,address)(uint256)' $ilk $urn)) eth
```
At this point, the collateral is in `MCD_JOIN_ETH_A` and available for use in the vault, but isn't yet locked. 

To prepare the locking of collateral, we set two variables with the amount of collateral that we will put in the Vault and the amount of Dai we will be generating:
```
export dink=$(seth --to-uint256 $(seth --to-hex $(seth --to-wei 5 eth)))
export dart=$(seth --to-uint256 $(seth --to-hex $(seth --to-wei 20 eth)))
```
- `dink` is delta ink - a signed difference value to the current value. This value is used in the frob function call to determine how much ink to lock in the Vat. 
- `dart`  is delta art - a signed difference value to the current value. This value is used in the frob function call to determine how much art(debt) to mint in the Vat.

Finally, we can lock up collateral in the Vat and generate Dai. The parameters `$dink` and `$dart` that we defined earlier represent how much ether we want to lock in our ether Vault and how much Dai we want to generate, respectively. This being 5 ether and 20 Dai. We can deposit the ether and generate Dai all in one transaction, as shown below:

```
seth send $CDP_MANAGER 'frob(uint256,int256,int256)' $cdpId $dink $dart
```

Now we can check if we successfully generated our Dai in the Dai Adapter (output is in rad):
```
 seth --to-dec $(seth call $MCD_VAT 'dai(address)(uint256)' $urn)
```
And then move the internal Dai balance from the urn account to our account:
```
export rad=$(seth --to-dec $(seth call $MCD_VAT 'dai(address)(uint256)' $urn))
seth send $CDP_MANAGER 'move(uint256,address,uint256)' $cdpId $ETH_FROM $(seth --to-uint256 $rad)
```

We need to approve the Dai adapter to withdraw the created Dai from the `urn`.
```
seth send $MCD_VAT 'hope(address)' $MCD_JOIN_DAI
```
Finally, we withdraw the Dai to our account. We need the `$wad` parameter that will define the amount of Dai we want to withdraw.
```
export wad=$(seth --to-uint256 $(seth --to-wei 20 eth))
seth send $MCD_JOIN_DAI "exit(address,uint256)" $ETH_FROM $wad
```
- `wad`  - some quantity of tokens

Checking the balance in the account:
```
seth --from-wei $(seth --to-dec $(seth call $MCD_DAI 'balanceOf(address)' $ETH_FROM)) eth
```
Output:
```
20.000000000000000000
```

Congratulations, you’ve successfully created an ETH Vault in the MCD system and drawn some fresh Dai. 

#### Pay back Dai debt
If you want to pay back your Dai, follow the steps below.

Note: These steps assume that the DAI is paid before fees are accrued using `drip()`. If `drip()` is called, an extra amount of DAI must be paid back. 

Approve `$MCD_JOIN_DAI` to withdraw `$wad` DAI (the amount we just generated) from `$MCD_DAI`
```
seth send $MCD_DAI 'approve(address,uint256)' $MCD_JOIN_DAI $wad
```

Add Dai back to the MCD_JOIN_DAI adapter. 
```
seth send $MCD_JOIN_DAI 'join(address,uint256)' $urn $wad
```

Pay back your Dai debt and unlock your collateral. We do this with the same `$dink` `$dart` values and with the `$frob` function. But we change them into negative numbers instead. We do it this way:

Using [mcd-cli](https://github.com/makerdao/mcd-cli#installation), we create our two negative numbers:
```
export minus20hex=$(mcd --to-hex $(seth --to-wei -20 eth))
export minus5hex=$(mcd --to-hex $(seth --to-wei -5 eth))
```
Then, we set these negative numbers to `$dink` and `$dart`.
 ```
 export dink=$(seth --to-uint256 $minus5hex)
 export dart=$(seth --to-uint256 $minus20hex)
 ```

 Now we can call the `frob` function via the CDPManager to pay back Dai and unlock our collateral.
```
seth send $CDP_MANAGER "frob(uint256,int256,int256)" $cdpId $dink $dart
```
The collateral withdrawn by from is still in possession of the urn, so we have to move to our own account:
```
seth send $CDP_MANAGER 'flux(uint256,address,uint256)' $cdpId $ETH_FROM $(seth --to-uint256 $(seth --to-wei 5 eth))
```

Our ETH is in the `MCD_JOIN_ETH_A` adapter now, we need to call the exit function to withdraw them. 
```
seth send $MCD_JOIN_ETH_A 'exit(address,uint)' $ETH_FROM $(seth --to-uint256 $(seth --to-wei 5 eth))
```
Finally, we just need to unwrap our ETH from the `$WETH` contract. 
```
seth send $ETH 'withdraw(uint)' $(seth --to-uint256 $(seth --to-wei 5 eth))
```

You can check your account balance again and see that your ETH is back.
```
seth balance $ETH_FROM
```

#### Using the testchain faucet

If you want to create a Vault with other tokens, like `BAT`, you need to request some from the `FAUCET` contract. You'll find the `FAUCET` contract address in the `out/addresses-mcd.json` file.

Add the `FAUCET` address to the env variable:
```
export FAUCET=0x9783d28387f5097d72397388d98c52ca9b18dec8
```
Add the `BAT` address to the variable:
```
export BAT=0x927f29f213c691ace67cbc9fdb6ebbfd04d07ec4
```
Now, you can call the gulp(address) function:
```
seth send $FAUCET 'gulp(address)' $BAT
```

Verify your balance:
```
seth --from-wei $(seth --to-dec $(seth call $BAT 'balanceOf(address)' $ETH_FROM)) eth 
```

Then you need to follow the same steps as above but change the `$ilk` to `BAT`  and interact with `$BAT` and `$MCD_JOIN_BAT_A` contracts. 

#### Changing collateral prices
By running your own MCD instance, you have the liberty of changing the collateral prices. This can be useful to test liquidations.

`PIP_ETH` is a price oracle feed for the ETH price. In this case, you are providing the price feed information to the contract.    
To read the current price:
```
seth --from-wei $(seth --to-dec $(seth call $PIP_ETH 'read()(uint256)'))
```

Setting the price feed:
```
seth send $PIP_ETH 'poke(bytes32)' $(seth --to-uint256 "$(seth --to-wei 151 ETH)")
```

The `MCD_SPOT` contract allows external actors to update the price feed in the Vat contract. 
Setting the value of spot, which defines how much unit dai we can draw from unit collateral. 
```
seth send "$MCD_SPOT" 'poke(bytes32)' "$ilk"
```

## Summary
In this guide, you have been introduced to Maker’s test chain and its benefits. You’ve learned how to deploy your own test chain with your preferred configuration options. You have interacted with the Maker system through the dai.js and seth tools by creating a Vault and drawing some Dai. 

## Troubleshooting
Feel free to create an [issue](https://github.com/makerdao/testchain/issues) if you run into trouble. We are here to help you. 


## Next Steps
After you have deployed your test chain, you could go and discover our [integration examples](https://github.com/makerdao/integration-examples). Some of them will need to use this test chain that you just deployed. Feel free to poke around and do PRs with your own examples. 
In addition, you can use this [repo](https://github.com/makerdao/dss-deploy) to deploy the MCD contracts to your own local test chain of choice. 

## Resources

- https://makerdao.com/documentation/
- https://docs.microsoft.com/en-us/windows/wsl/install-win10 
- https://dapp.tools/ 
- https://nodejs.org 
- https://github.com/NixOS/nix/issues/1203#issuecomment-275089112 
- https://github.com/makerdao/testchain.git 
- https://www.mycrypto.com/ 
- https://medium.com/makerdao/guide-vote-proxy-setup-with-seth-f62397a10c59 
- https://github.com/makerdao/integration-examples 
- https://github.com/makerdao/dss-deploy 
- https://github.com/makerdao/mcd-cli
