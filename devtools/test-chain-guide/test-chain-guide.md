# Test Chain Guide

**Level**: Intermediate  
**Estimated-Time**: 30 - 50 minutes

- [Test Chain Guide](#test-chain-guide)
  - [Overview](#overview)
  - [Learning Objectives](#learning-objectives)
  - [Pre-requisites](#pre-requisites)
  - [Sections](#sections)
  - [Note on Windows Subsystem for Linux](#note-on-windows-subsystem-for-linux)
  - [Benefits of using the test chain](#benefits-of-using-the-test-chain)
  - [Getting Started](#getting-started)
  - [Options](#options)
  - [Interacting with Maker Protocol contracts](#interacting-with-maker-protocol-contracts)
    - [Open a Vault with dai.js](#open-a-vault-with-daijs)
    - [Interact with contracts directly with seth](#interact-with-contracts-directly-with-seth)
      - [Opening a Vault](#opening-a-vault)
      - [Pay back Dai debt](#pay-back-dai-debt)
      - [Using the testchain faucet](#using-the-testchain-faucet)
      - [Changing collateral prices](#changing-collateral-prices)
  - [Summary](#summary)
  - [Troubleshooting](#troubleshooting)
  - [Next Steps](#next-steps)
  - [Resources](#resources)

## Overview

This guide is intended to give an introduction on how to use test chain. The test chain has all of the Maker Protocol's smart contracts deployed on it, so you as a developer can start building your dApps on top of the Maker Protocol. In addition, you can also use [dai.js](https://docs.makerdao.com/building-on-top-of-the-maker-protocol/dai.js-wiki) library with this test chain.

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

This test chain has the Maker Protocol smart contracts deployed on it. This is very convenient for you as a developer to interact or build smart contracts that interact with the Maker Protocol.
In addition, you have the convenience of tweaking your chain configurations to suit your needs, such as changing the block time or deploying your own set of smart contracts when instantiating the chain.

## Getting Started

In a terminal, execute the following commands.

To [download](https://github.com/makerdao/testchain) the repo to your machine execute:

```bash
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

```bash
Starting Ganache...
Skipping git submodule update.
Launched testchain in --- seconds.
Press Ctrl-C to stop the test chain.
```

If you see this, then congratulations, you have your test chain running on `http://127.0.0.1:2000`

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

For more options check out this [repo](https://github.com/makerdao/testchain#options).

## Interacting with Maker Protocol contracts

You’ll find all the necessary Maker Protocol contract addresses in the `out/addresses-mcd.json` file in the testchain folder. You can use these addresses to develop your own tools that interact with Maker Protocol contracts. Use [dai.js](https://docs.makerdao.com/building-on-top-of-the-maker-protocol/dai.js-wiki) library or interact through the command line with [seth](https://dapp.tools/seth/). You will go be introduced to both of these methods now.

### Open a Vault with [dai.js](https://docs.makerdao.com/building-on-top-of-the-maker-protocol/dai.js-wiki)

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
      .openLockAndDraw('ETH-A', ETH(5), MDAI(500));

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

```bash
Web3 is initializing...
Web3 is connecting...
Web3 version:  1.2.1
Web3 is authenticating...
Account:  0x16fb96a5fa0427af0c8f7cf1eb4870231c8154b6
Balance 70.85 ETH
Opened CDP #6
Collateral amount:5.00 ETH
Debt Value:500.00 MDAI
```

### Interact with contracts directly with [seth](https://dapp.tools/seth/)

In this example, you will draw Dai by depositing ETH into the MCD contracts that are deployed on the testchain. You will interact with the smart contracts directly, so there’s more steps involved.

As a prerequisite, you need to have the test chain running in a terminal with the `scripts/launch -s default --fast` command, if you haven’t done so already.  Note: If you see a message saying the testchain is already running on port 2000, you can kill it with `kill -9 $(lsof -t -i:2000)`

Next, go to another terminal window or tab. To start, you will need to set up and export some environmental variables in your second terminal. These variables will help you connect to the test chain and interact with the MCD system through seth.

Let’s add the variables that will set your account and connection with the test chain. In your second terminal tab, in your home location, add these variables:

```bash
export ETH_FROM=0x16fb96a5fa0427af0c8f7cf1eb4870231c8154b6
```

- Taken from `testchain/out/addresses-mcd.json` under `ETH_FROM`.  
You need to add this address because it is already filled with some ether for you by the test chain.

```bash
export ETH_RPC_URL=http://localhost:2000
```

- This sets the connection to the test chain.

You are using an account handled by the ethereum client, and as such you need to instruct `seth` not to use local keystores and instead use to use the RPC account to sign the transactions:

```bash
export ETH_RPC_ACCOUNTS=1
```

You can try to test your connection by seeing your account balance:

```bash
seth balance $ETH_FROM
```

If connection is right, you’ll see this (your values might differ):

```bash
94829630380000000000
```

Next, you can start adding the MCD contract addresses. You’ll find these addresses in the file `testchain/out/addresses-mcd.json`. Make sure to be in the testchain directory. The following command will parse the json file and store the addresses as environment variables:

```bash
eval $(jq -r 'to_entries|map("\(.key)=\(.value|tostring)")|.[]' out/addresses-mcd.json)
```

#### Opening a Vault

You will begin by setting a few useful variables:

```bash
export ilk=$(seth --to-bytes32 "$(seth --from-ascii "ETH-A")")
```

- `ilk` - a collateral type
- Setting the `ilk` variable to the `ETH` type of collateral and converting it to hex and bytes32 format.

You also set the gas limit for your transactions (with the default, certain transactions are likely to fail):

```bash
export ETH_GAS=1000000
```

First you open the Vault using the CDP Manager:

```bash
seth send -F $ETH_FROM $CDP_MANAGER 'open(bytes32,address)' "$ilk" "$ETH_FROM"
```

This call does not return anything useful, so you use these commands to determine the Id and urn address of the vault you just opened:

```bash
export cdpId=$(seth --to-dec $(seth call $CDP_MANAGER 'last(address)' $ETH_FROM))
export urn=$(seth call $CDP_MANAGER 'urns(uint)(address)' $cdpId)
echo $cdpId
echo $urn
```

Then you deposit 5 eth into the `WETH` adapter:

```bash
seth send $ETH 'deposit()' --value $(seth --to-wei 5 ETH)
```

And you approve `MCD_JOIN_ETH_A` to withdraw some `WETH`:

```bash
seth send $ETH 'approve(address,uint256)' $MCD_JOIN_ETH_A $(seth --to-uint256 $(seth --to-wei 5 ETH))
```

To finally lock the 5 ether into the ether adapter, to the benefit of our vault (urn):

```bash
seth send $MCD_JOIN_ETH_A 'join(address,uint256)' $urn $(seth --to-uint256 $(seth --to-wei 5 ETH))
```

As a validation, you can confirm that the collateral is available to our vault:

```bash
seth --from-wei $(seth --to-dec $(seth call $MCD_VAT 'gem(bytes32,address)(uint256)' $ilk $urn)) eth
```

At this point, the collateral is in `MCD_JOIN_ETH_A` and available for use in the vault, but isn't yet locked.

To prepare the locking of collateral, you set two variables with the amount of collateral that you will put in the Vault and the amount of Dai you will be generating:

```bash
export dink=$(seth --to-uint256 $(seth --to-hex $(seth --to-wei 5 eth)))
export dart=$(seth --to-uint256 $(seth --to-hex $(seth --to-wei 500 eth)))
```

- `dink` is delta ink - a signed difference value to the current value. This value is used in the frob function call to determine how much ink to lock in the Vat.
- `dart`  is delta art - a signed difference value to the current value. This value is used in the frob function call to determine how much art(debt) to mint in the Vat.

Finally, you can lock up collateral in the Vat and generate Dai. The parameters `$dink` and `$dart` that you defined earlier represent how much ether you want to lock in our ether Vault and how much Dai you want to generate, respectively. This being 5 ether and 500 Dai. You can deposit the ether and generate Dai all in one transaction, as shown below:

```bash
seth send $CDP_MANAGER 'frob(uint256,int256,int256)' $cdpId $dink $dart
```

Now you can check if you successfully generated your Dai in the Dai Adapter (output is in rad):

```bash
 seth call $MCD_VAT 'dai(address)(uint256)' $urn
```

And then move the internal Dai balance from the urn account to your account:

```bash
export rad=$(seth call $MCD_VAT 'dai(address)(uint256)' $urn)
seth send $CDP_MANAGER 'move(uint256,address,uint256)' $cdpId $ETH_FROM $(seth --to-uint256 $rad)
```

You need to approve the Dai adapter to withdraw the created Dai from the `urn`.

```bash
seth send $MCD_VAT 'hope(address)' $MCD_JOIN_DAI
```

Finally, you withdraw the Dai to your account. You need the `$wad` parameter that will define the amount of Dai you want to withdraw.

```bash
export wad=$(seth --to-uint256 $(seth --to-wei 500 eth))
seth send $MCD_JOIN_DAI "exit(address,uint256)" $ETH_FROM $wad
```

- `wad`  - some quantity of tokens

Checking the balance in the account:

```bash
seth --from-wei $(seth --to-dec $(seth call $MCD_DAI 'balanceOf(address)' $ETH_FROM)) eth
```

Output:

```bash
500.000000000000000000
```

Congratulations, you’ve successfully created an ETH Vault in the MCD system and drawn some fresh Dai.

#### Pay back Dai debt

If you want to pay back your Dai, follow the steps below.

Note: These steps assume that the DAI is paid before fees are accrued using `drip()`. If `drip()` is called, an extra amount of DAI must be paid back.

Approve `$MCD_JOIN_DAI` to withdraw `$wad` DAI (the amount you just generated) from `$MCD_DAI`

```bash
seth send $MCD_DAI 'approve(address,uint256)' $MCD_JOIN_DAI $wad
```

Add Dai back to the MCD_JOIN_DAI adapter.

```bash
seth send $MCD_JOIN_DAI 'join(address,uint256)' $urn $wad
```

Pay back your Dai debt and unlock your collateral. You do this with the same `$dink` `$dart` values and with the `$frob` function. But you change them into negative numbers instead. You do it this way:

Using [mcd-cli](https://github.com/makerdao/mcd-cli#installation), you create your two negative numbers:

```bash
export minus5hex=$(mcd --to-hex $(seth --to-wei -5 eth))
export minus500hex=$(mcd --to-hex $(seth --to-wei -500 eth))
```

Then, you set these negative numbers to `$dink` and `$dart`.

 ```bash
 export dink=$(seth --to-uint256 $minus5hex)
 export dart=$(seth --to-uint256 $minus500hex)
 ```

 Now you can call the `frob` function via the CDPManager to pay back Dai and unlock your collateral.

```bash
seth send $CDP_MANAGER "frob(uint256,int256,int256)" $cdpId $dink $dart
```

The collateral withdrawn by from is still in possession of the urn, so you have to move to your own account:

```bash
seth send $CDP_MANAGER 'flux(uint256,address,uint256)' $cdpId $ETH_FROM $(seth --to-uint256 $(seth --to-wei 5 eth))
```

Your ETH is in the `MCD_JOIN_ETH_A` adapter now, you need to call the exit function to withdraw them.

```bash
seth send $MCD_JOIN_ETH_A 'exit(address,uint)' $ETH_FROM $(seth --to-uint256 $(seth --to-wei 5 eth))
```

Finally, you just need to unwrap your ETH from the `$WETH` contract.

```bash
seth send $ETH 'withdraw(uint)' $(seth --to-uint256 $(seth --to-wei 5 eth))
```

You can check your account balance again and see that your ETH is back.

```bash
seth balance $ETH_FROM
```

#### Using the testchain faucet

If you want to create a Vault with other tokens, like `BAT`, you need to request some from the `FAUCET` contract. You'll find the `FAUCET` contract address in the `out/addresses-mcd.json` file.

Add the `FAUCET` address to the env variable:

```bash
export FAUCET=0x9783d28387f5097d72397388d98c52ca9b18dec8
```

Add the `BAT` address to the variable:

```bash
export BAT=0x927f29f213c691ace67cbc9fdb6ebbfd04d07ec4
```

Now, you can call the gulp(address) function:

```bash
seth send $FAUCET 'gulp(address)' $BAT
```

Verify your balance:

```bash
seth --from-wei $(seth --to-dec $(seth call $BAT 'balanceOf(address)' $ETH_FROM)) eth
```

Then you need to follow the same steps as above but change the `$ilk` to `BAT`  and interact with `$BAT` and `$MCD_JOIN_BAT_A` contracts.

#### Changing collateral prices

By running your own MCD instance, you have the liberty of changing the collateral prices. This can be useful to test liquidations.

`PIP_ETH` is a price oracle feed for the ETH price. In this case, you are providing the price feed information to the contract.

To read the current price:

```bash
seth --from-wei $(seth --to-dec $(seth call $PIP_ETH 'read()(uint256)'))
```

Setting the price feed:

```bash
seth send $PIP_ETH 'poke(bytes32)' $(seth --to-uint256 "$(seth --to-wei 151 ETH)")
```

The `MCD_SPOT` contract allows external actors to update the price feed in the Vat contract.
Setting the value of spot, which defines how much unit dai you can draw from unit collateral.

```bash
seth send "$MCD_SPOT" 'poke(bytes32)' "$ilk"
```

## Summary

In this guide, you have been introduced to Maker’s test chain and its benefits. You’ve learned how to deploy your own test chain with your preferred configuration options. You have interacted with the Maker system through the dai.js and seth tools by creating a Vault and drawing some Dai.

## Troubleshooting

Feel free to create an [issue](https://github.com/makerdao/testchain/issues) if you run into trouble.

## Next Steps

After you have deployed your test chain, you could go and discover your [integration examples](https://github.com/makerdao/integration-examples). Some of them will need to use this test chain that you just deployed. Feel free to poke around and do PRs with your own examples.
In addition, you can use this [repo](https://github.com/makerdao/dss-deploy) to deploy the MCD contracts to your own local test chain of choice.

## Resources

- <https://docs.makerdao.com/>
- <https://docs.microsoft.com/en-us/windows/wsl/install-win10>
- <https://dapp.tools/>
- <https://nodejs.org>
- <https://github.com/NixOS/nix/issues/1203#issuecomment-275089112>
- <https://github.com/makerdao/testchain.git>
- <https://www.mycrypto.com/>
- <https://medium.com/makerdao/guide-vote-proxy-setup-with-seth-f62397a10c59>
- <https://github.com/makerdao/integration-examples>
- <https://github.com/makerdao/dss-deploy>
- <https://github.com/makerdao/mcd-cli>
