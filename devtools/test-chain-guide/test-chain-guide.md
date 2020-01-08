# Test Chain Guide

**Level**: Intermediate    

**Estimated-Time**: 30 - 50 minutes   

## Overview

This guide is intended to give an introduction on how to use Maker’s custom test chain. This test chain has all of Maker’s smart contracts deployed on it, so you as a developer can start building your dApps on top of Maker’s system. In addition, you can also use our [dai.js](https://docs.makerdao.com/building-on-top-of-the-maker-protocol/dai.js) library with this test chain.

## Learning Objectives

Learn how to deploy and interact with the test chain for your development purposes.

## Pre-requisites

You can run the testchain on MacOS/Linux systems and also on the [Windows Subsystem For Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10).
You need to have [dapp.tools](https://dapp.tools/), [NodeJs](https://nodejs.org/en/) and bash installed on your machine.

## Sections

- Note on Windows Subsystem for Linux
- Benefits of using the test chain
- Getting Started
- Options
- Interacting with MakerDAO contracts
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
scripts/launch -s default --fast --verbose
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
scripts/launch -s default --fast --verbose
 -p 2001 
```

For more options check out our [repo](https://github.com/makerdao/testchain#options).

## Interacting with Maker Protocol contracts
You’ll find all the necessary Maker contract addresses in the `out/addresses-mcd.json` file in the testchain folder. You can use these addresses to develop your own tools that interact with Maker contracts. Use our own [dai.js](https://docs.makerdao.com/building-on-top-of-the-maker-protocol/dai.js) library or interact through the command line with [seth](https://dapp.tools/seth/). We will go through both of these methods now.

#### Open a Vault with [dai.js](https://docs.makerdao.com/building-on-top-of-the-maker-protocol/dai.js)

So, to start from scratch:
- Start the testchain in another terminal, as you’ll be connecting to it when running the js file.
- In a directory of your choice, in another terminal, initiate an empty project with `npm init -y`
- Add the `@makerdao/dai` and the `@makerdao/dai-plugin-mcd` packages: `npm i --save @makerdao/dai @makerdao/dai-plugin-mcd`
- Create a `cdp.js` file where you’ll write your script.
- Copy the below example in your js file
- Run the file with `node cdp.js`

Below is an example that shows the process of opening a CDP in the Single Collateral Dai system, locking some Eth and drawing some Dai:

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

So, if everything went according to plan, you should see an output like the one below:
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

#### Interact with contracts directly with [seth](https://dapp.tools/seth/)

In this example, we will draw Dai by depositing ETH into the MCD contracts that are deployed on our testchain. We will interact with the smart contracts directly, so there’s more steps involved.   

As a prerequisite, you need to have the test chain running in a terminal with the `scripts/launch --verbose` command, if you haven’t done so already.  Note: If you see a message saying the testchain is already running on port 2000, you can kill it with `kill -9 $(lsof -t -i:2000)`

Next, go to another terminal window or tab.  To start, we will need to set up and export some environmental variables in our second  terminal. These variables will help you connect to the test chain and interact with the MCD system through seth. 

Let’s add the variables that will set our account and connection with the test chain. In your second terminal tab, in your home location, add these variables:

```
export ETH_FROM=0x...address
```
- This is the first address under ‘Available Accounts’ appearing in the first terminal when starting the test chain with `--verbose` flag.  
You need to add this address because it is already filled with some ether for you by the test chain.


```
export ETH_RPC_URL=http://localhost:2000
```
- This sets the connection to the test chain.

For the next two variables, you need to create a keystore file with the private key of the `ETH_FROM` address used earlier. Each private key, corresponding to the above-mentioned available accounts, is also printed in the test chain terminal. This newly created keystore file will be stored in a folder called `accounts`.

In order to create the keystore with the private key, do one of the following:

- Go to https://www.mycrypto.com/ and view the wallet with your private key. Then save it locally as a keystore file. Keep in mind the password for your keystore.

- Use `geth`. To create a keystore file with geth, the command used is: `geth account import <(echo <privateKey>)`. By default, the file is stored here: `~/Library/Ethereum/keystore/<UTC…time.info…> — <yourPublicAddress>` on MAC OS or here `~/.ethereum/keystore` on Ubuntu. 

Store the `keystore` in the `accounts` folder.    
Next, you need to create a file, let’s name it `pass` and save the password that accesses the keystore file you created prior.    
So, by now you should have two files in the accounts folder: `keystore` and `pass`. Now you can add the next variables:

```
export ETH_KEYSTORE=/home/user/accounts/
export ETH_PASSWORD=/home/user/accounts/pass
```

- `pass` being the name of the password file you created

You can try to test your connection by seeing your account balance:

```
seth balance $ETH_FROM
```
If connection is right, you’ll see this (your values might differ):
```
95708649200000000000
```

Next, we can start adding the MCD contract addresses. You’ll find these addresses in the `/testchain/out/addresses-mcd.json`:

```
export MCD_MOM=0x….
```
 - `MCD_MOM` is a contract interface that sets the risk parameters of the Dai Credit   System

```
export MCD_MOM_LIB=0x….
```
- `MCD_MOM_LIB` is a contract library for the `MCD_MOM`

```
export MCD_JOIN_ETH=0x….
```
- `MCD_JOIN_ETH` is the ETH adapter responsible for joining and exiting ETH collateral.

```
export MCD_SPOT=0x….
```
- `MCD_SPOT` is a contract that allows external actors to update the price feed for the given collateral type (ilk).

```
export MCD_VAT=0x….
```
- `MCD_VAT` is a contract for the Vault core engine, keeps track of DAI credit system accounting.

```
export MCD_JOIN_DAI=0x….
```
- `MCD_JOIN_DAI` is a contract for the DAI adapter responsible for minting and burning DAI.

```
export MCD_DAI=0x….
```
- `MCD_DAI` is a contract for the DAI stablecoin contract.

```
export PIP_ETH=0x….
```
- `PIP_ETH` is a contract for the price feed oracle for the ETH price

```
export WETH=0x….
```
- `WETH` is the wrapped ether contract, you can find it as `ETH` in the json file

Next, add the variables that will be used in calling specific functions in the MCD contracts:

```
export ceiling=$(seth --to-uint256 "$(echo 10000*10^45 | bc)")
```
 - Setting the `ceiling` variable to a large number and converting it to hexadecimal
 - This variable is used to set the total debt ceiling for the Dai System and each collateral. 

```
export ilk=$(seth --to-bytes32 "$(seth --from-ascii "ETH-A")")
```
- `ilk` - a collateral type
- Setting the `ilk` variable to the `ETH` type of collateral and converting it to hex and bytes32 format.

```
export urn=$(seth --to-bytes32 $ETH_FROM)
```
- `urn` - a specific Vault
- Setting the `urn` variable to your ethereum address. Urn being the specific Vault that you’ll create

```
export mat=1500000000
```
- Setting the collateral ratio variable to 1.5. The reason this number has 9 extra digits is because of the necessary conversion in seth. The value of `mat` in the Dai system has a 27 digit precision, so using a `seth --to-wei` conversion, it adds 18 extra digits to the 9 digit number. Giving the total of 27 digits.

```
export dink=$(seth --to-uint256 $(seth --to-hex $(seth --to-wei 5 eth)))
```
- `dink` is delta ink - a signed difference value to the current value. This value is used in the frob function call to determine how much ink to lock in the Vat. 

```
export dart=$(seth --to-uint256 $(seth --to-hex $(seth --to-wei 20 eth)))
```
- `dart`  is delta art - a signed difference value to the current value. This value is used in the frob function call to determine how much art(debt) to mint in the Vat.

As the MCD contracts are freshly deployed, we need to configure some parameters in the MCD system. They are the general debt ceiling, debt ceiling for ether collateral, collateral ratio for ether collateral, ether price feed and value of spot.  As a side note, these parameters are set by certain actors such as Maker Governance and Oracle Relayer Network on the mainnet. Changes to these parameters occur through voting mechanisms. However, in this situation, you are the complete owner of the MCD system. You can make any change you want to your specific scenarios. 

`MCD_MOM` is a contract interface that sets the risk parameters of the Dai Credit System. The DSChief contract has authority to call functions on the MOM contract after the MKR holders have voted their decisions. 

In this case, you as the sole user on the test chain, are performing all the function calls necessary to bootstrap the Dai Credit System.     
All the `MCD_MOM` function calls are called by the DSChief contract on the mainnet. While on the test chain, you are performing all the roles. 

Setting the general debt ceiling:
```
seth send "$MCD_MOM" 'execute(address,bytes memory)' "$MCD_MOM_LIB" "$(seth calldata 'file(address,bytes32,uint256)' "$MCD_VAT" "$(seth --to-bytes32 "$(seth --from-ascii "Line")")" "$ceiling")"
```

Setting the ceiling for ether collateral:
```
seth send "$MCD_MOM" 'execute(address,bytes memory)' "$MCD_MOM_LIB" "$(seth calldata 'file(address,bytes32,bytes32,uint256)' "$MCD_VAT" "$ilk" "$(seth --to-bytes32 "$(seth --from-ascii "line")")" "$ceiling")"
```

Setting the collateral ratio for each collateral:
```
seth send "$MCD_MOM" 'execute(address,bytes memory)' "$MCD_MOM_LIB" "$(seth calldata 'file(address,bytes32,bytes32,uint256)' "$MCD_SPOT" "$ilk" "$(seth --to-bytes32 "$(seth --from-ascii "mat")")" "$(seth --to-uint256 "$(seth --to-wei "$mat" ETH)")")"
```

`PIP_ETH` is a price oracle feed for the ETH price. In this case, you are providing the price feed information to the contract.    
Setting the price feed:
```
seth send $PIP_ETH 'poke(bytes32)' $(seth --to-uint256 "$(seth --to-wei 150 ETH)")
```

Setting the liquidation ratio:
```
seth send "$MCD_MOM" 'execute(address,bytes memory)' "$MCD_MOM_LIB" "$(seth calldata 'file(address,bytes32,bytes32,uint256)' "$MCD_SPOT" "$(seth --to-bytes32 "$(seth --from-ascii "ETH")")" "$(seth --to-bytes32 "$(seth --from-ascii "mat")")" "$(seth --to-uint256 "$(seth --to-wei "$(echo "150 * 10 ^ 7" | bc -l)" ETH)")")"
```

The `MCD_SPOT` contract allows external actors to update the price feed in the Vat contract. 
Setting the value of spot, which defines how much unit dai we can draw from unit collateral. 
```
seth send "$MCD_SPOT" 'poke(bytes32)' "$ilk"
```

Let’s deposit 5 eth into the `WETH` adapter:
```
seth send $WETH 'deposit()' --value $(seth --to-wei 5 ETH)
```

Let’s approve `MCD_JOIN_ETH` to withdraw some `WETH`:
```
seth send $WETH 'approve(address, uint256)' $MCD_JOIN_ETH $(seth --to-uint256 $(seth --to-wei 5 ETH))
```
Let’s lock 5 ether into the ether adapter:
```
seth send $MCD_JOIN_ETH 'join(bytes32,uint256)' $urn $(seth --to-uint256 $(seth --to-wei 5 ETH))
```
Checking if `MCD_JOIN_ETH` got the collateral:
```
seth --from-wei $(seth --to-dec $(seth call $MCD_VAT 'gem(bytes32,bytes32)(uint256)' $ilk $urn)) eth
```

Finally, we can lock up collateral in the Vat and generate Dai. The parameters `$dink` and `$dart` that we defined earlier represent how much ether we want to lock in our ether Vault and how much Dai we want to generate, respectively. This being 5 ether and 20 Dai. We can deposit the ether and generate Dai all in one transaction, as shown below:
```
seth send $MCD_VAT "frob(bytes32,bytes32,bytes32,bytes32,int256,int256)" $ilk $urn $urn $urn $dink $dart
```

Now we can check if we successfully generated our Dai in the Dai Adapter:
```
seth --from-wei $(seth --to-dec $(seth call $MCD_VAT 'dai(bytes32)(uint256)' $urn))
```
We need to approve the Dai adapter to withdraw the created Dai from the `urn`.
```
seth send $MCD_VAT 'hope(address)' $MCD_JOIN_DAI
```
Lastly, we can withdraw the Dai to your account. We need the `$wad` parameter that will define the amount of Dai we want to withdraw.
```
export wad=$(seth --to-uint256 $(seth --to-wei 20 eth))
seth send $MCD_JOIN_DAI "exit(bytes32,address, uint256)" $urn $ETH_FROM $wad
```
- `wad`  - some quantity of tokens

Checking the balance in your account:
```
seth --from-wei $(seth --to-dec $(seth call $MCD_DAI 'balanceOf(address)' $ETH_FROM)) eth
```
Output:
```
20.000000000000000000
```

If all went right, you should see your balance of Dai in your account. Congratulations, you’ve successfully created an ETH Vault in the MCD system and drawn some fresh Dai. 

Note, if you want to create a Vault with other tokens, like `COL1`, you need to request some from the `FAUCET` contract. You'll find the `FAUCET` contract address in the `out/addresses-mcd.json` file.

Add the `FAUCET` address to the env variable:
```
export FAUCET=0x..
```
Add the `COL1` address to the variable:
```
export COL1=0x...
```
Now, you can call the gulp(address) function:
```
seth send $FAUCET 'gulp(address)' $COL1
```

Verify your balance:
```
seth --from-wei $(seth --to-dec $(seth call $COL1 'balanceOf(address)' $ETH_FROM)) eth 
```

Then you need to follow the same steps as above but change the `$ilk` to `COL1`  and interact with `$COL1` and `$MCD_JOIN_COL1_A` contracts. 

#### Pay back Dai debt
If you want to pay back your Dai, follow the steps below. 

Approve `$MCD_JOIN_DAI` to withdraw `$wad` from `$MCD_DAI`
```
seth send $MCD_DAI 'approve(address,uint256)' $MCD_JOIN_DAI $wad
```

Add Dai back to the MCD_JOIN_DAI adapter. 
```
seth send $MCD_JOIN_DAI 'join(bytes32,uint256)' $urn $wad
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

 Now we can call the `frob` function in `VAT` to pay back Dai and unlock our collateral.
```
seth send $MCD_VAT "frob(bytes32,bytes32,bytes32,bytes32,int256,int256)" $ilk $urn $urn $urn $dink $dart
```
Our ETH is in the `MCD_JOIN_ETH` adapter now, we need to call the exit function to withdraw them. 
```
seth send $MCD_JOIN_ETH 'exit(bytes32,address,uint)' $urn $ETH_FROM $(seth --to-uint256 $(seth --to-wei 5 eth)) 
```
Finally, we just need to unwrap our ETH from the `$WETH` contract. 
```
seth send $WETH 'withdraw(uint)' $(seth --to-uint256 $(seth --to-wei 5 eth))
```

You can check your account balance again and see that your ETH is back.
```
seth balance $ETH_FROM
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




