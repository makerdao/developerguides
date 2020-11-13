**DEPRECATED**

# Migrating Dai and CDPs to MCD on Kovan using Seth

This guide is tested on the [2.10 deployment of MCD to Kovan.](https://changelog.makerdao.com/releases/0.2.10/index.html)

- [Migrating Dai and CDPs to MCD on Kovan using Seth](#migrating-dai-and-cdps-to-mcd-on-kovan-using-seth)
  - [Introduction](#introduction)
  - [Setup](#setup)
  - [Migrating Sai to Dai and Dai to Sai](#migrating-sai-to-dai-and-dai-to-sai)
  - [Migrating CDPs](#migrating-cdps)
  - [Need help](#need-help)
  - [Additional resources](#additional-resources)

## Introduction

This guide will explain how to use the command line tools [seth](http://dapp.tools/seth/) and [mcd-cli](https://github.com/makerdao/mcd-cli#installation) to migrate Single Collateral Dai tokens (SAI) to Multi Collateral Dai tokens (DAI), and CDP migration on the Kovan network.

Since this guide will utilize `seth` and `mcd-cli`, we highly recommend you to go over these guides first to get you setup and acquainted with the tools.

- [Introduction to Seth](https://github.com/makerdao/developerguides/blob/master/devtools/seth/seth-guide-01/seth-guide-01.md)
- [Using seth to draw Dai from Kovan deployment of MCD](https://github.com/makerdao/developerguides/blob/master/mcd/mcd-seth/mcd-seth-01.md)  

## Setup

Make sure you have installed [seth](http://dapp.tools/seth/) and [mcd-cli](https://github.com/makerdao/mcd-cli#installation) before starting this guide. See the links and guides above for guidance. Since we are using the Kovan testnet for this guide, ensure that your seth and mcd-cli variables are set to interact with the Kovan network. You can do this by putting the following lines:

`export SETH_CHAIN=kovan`

`export MCD_CHAIN=kovan`

in your local `.sethrc` file, or by pasting it in a terminal window.

Also make sure that your `ETH_FROM`, `ETH_KEYSTORE` and `ETH_PASSWORD` variables are set up in similar fashion. Example:

`export ETH_FROM=0x21E91332984eEd55e88131C5829xC8Dce379E2aB`

`export ETH_KEYSTORE=~/path/to/keystore`

`export ETH_PASSWORD=~/path/to/pass.txt`

When you are using `seth` and `mcd-cli` in the terminal, make sure you are calling the commands from the same folder as where your `.sethrc` file is located.

## Migrating Sai to Dai and Dai to Sai

Now that the `seth` and `mcd-cli` variables are setup, we can go ahead with upgrading SAI to DAI. In this case we are going to upgrade 5 SAI to DAI. To make life easier, we are going to setup variables for the contracts we are going to interact with. Paste the following commands in the terminal window:

`export MIGRATION=0x25601b0f6ba68197de2a7ae3c11ab2c965221e44`

`export SAI_SAI=0xc4375b7de8af5a38a93548eb8453a498222c4ff2`

`export MCD_DAI=0x5944413037920674d39049ec4844117a031eaa74`

`MIGRATION` is the migration smart contract that will handle the upgrade of Sai to Dai. `SAI_SAI` is the SAI token contract (the old Dai/Single Collateral Dai). `MCD_DAI` is the new DAI token contract (Multi Collateral Dai token).

First, check that you have a SAI balance by executing the following command:

`seth --from-wei $(seth --to-dec $(seth call $SAI_SAI 'balanceOf(address)' $ETH_FROM)) eth`

Example output:

`$ 5.000000000000000000`

In this case, we have 5 SAI.

Next, in order to allow the migration contract to interact with your SAI holdings, you need to approve that the migration contract can transfer SAI on your behalf. Execute the following command:

`seth send "$SAI_SAI" 'approve(address)' "$MIGRATION"`

Now that the migration contract has been approved to transfer our SAI, we can execute the `swapSaiToDai` function which will upgrade the specified amount of SAI to DAI. To upgrade 5 SAI, execute the following command (feel free to use another amount than 5, by changing the number):

`seth send $MIGRATION 'swapSaiToDai(uint256)' $(seth --to-uint256 $(seth --to-wei 5 ETH)) --gas=500000`

Once the transaction has gone through, check your DAI balance to verify that the upgrade was complete by executing:

`seth --from-wei $(seth --to-dec $(seth call $MCD_DAI 'balanceOf(address)' $ETH_FROM)) eth`

Example output:

`$ 5.000000000000000000`

The migration contract also allows users to reverse the migration by swapping DAI for SAI. This function call however relies on SAI liquidity in the migration contract, why this can only be done if there’s enough surplus of SAI in the contract to cover the amount of DAI you want to swap.

In order to swap DAI for SAI, you must again grant the migration contract approval to transfer DAI from your account. Execute the following command:

`seth send "$MCD_DAI" 'approve(address,uint256)' "$MIGRATION" "$(seth --to-uint256 "$(seth --to-wei 1000000000 ETH)")"`

Once the transaction is mined, you can now execute the reverse swap by executing the following command:

`seth send $MIGRATION 'swapDaiToSai(uint256)' $(seth --to-uint256 $(seth --to-wei 1 ETH)) --gas=500000`

When the transaction has been mined, you can verify your SAI balance using this command:

`seth --from-wei $(seth --to-dec $(seth call $SAI_SAI 'balanceOf(address)' $ETH_FROM)) eth`

Example output:

`$ 5.000000000000000000`

If everything went to plan, congratulations, you have successfully swapped Sai to Dai and back again.

## Migrating CDPs

The following section will cover how you use the migration contract to migrate a Single Collateral Dai CDP (SCDCDP) to a Multi Collateral Dai CDP (MCDCDP). Again, we are going to save a bunch of smart contract addresses in variables. Paste the following lines into your terminal window:

`export MIGRATION=0x25601b0f6ba68197de2a7ae3c11ab2c965221e44`

`export MIGRATION_PROXY_ACTIONS=0x36370426f47028621edc2203dcae6c1431b679b0`

`export PROXY_REGISTRY=0x64a436ae831c1672ae81f674cab8b6775df3475c`

`export MCD_JOIN_SAI=0xe4164871f8366527d492ec52889c89343db48b69`

`export SAI_SAI=0xc4375b7de8af5a38a93548eb8453a498222c4ff2`

`export MCD_DAI=0x5944413037920674d39049ec4844117a031eaa74`

`export MCD_GOV=0xaaf64bfcc32d0f15873a02163e7e500671a4ffcd`

The migration, SAI and DAI contracts remain the same as before. `MIGRATION_PROXY_ACTIONS` is a proxy smart contract that will execute the CDP migration on the migration contract, by bundling a bunch of function calls into one, making migration a lot safer and simpler. `PROXY_REGISTRY` is a smart contract that keeps track of users and their corresponding proxy contract addresses. When a user creates a CDP at [cdp.makerdao.com](https://cdp.makerdao.com/), a proxy contract is created for the user to bundle function calls, again to make interactions a lot simpler and safer for the user. The `PROXY_REGISTRY` keeps track of these deployed contracts.

`MCD_JOIN_SAI` is the token adapter in MCD that allows us to deposit SAI to mint DAI against.

`MCD_GOV` is the Maker governance token, MKR.

In order to do the migration, ensure that you have some Kovan MKR to pay down the stability fee. If you do not have K-MKR, you can utilize our faucet to get some. Execute the following commands:

`export FAUCET=0xCbd3e165cE589657feFd2D38Ad6B6596A1f734F6`

`seth send $FAUCET 'gulp(address)' $MCD_GOV`

Now that the contract variables are set up, and your have K-MKR, we are ready to start migrating a CDP. If you do not already have a CDP to migrate, go to cdp.makerdao.com, and ensure that you are connected to the Kovan network (i.e. through MetaMask). Open a CDP using Kovan ETH, and draw some Kovan SAI.

Once you have created a CDP (or if you already had one), find the CDP id in the CDP portal. See picture below - the CDP id is in the red ring: ![SCD CDP Portal](https://lh3.googleusercontent.com/TdddYarFtj2kIg2w_8JGGQ-j7PKEPuhOKE0_EWksIRm-3o7O7Z-RIBBwYsLntuJi4HFCyDE36EKQtciTELKitE_SxoYzWqVhV9nJBrKzCYjgwV4iUvr-6X6SWyox8m002W4ZRBfb)

We need to turn this CDP id into a bytes32 string to pass it onto the smart contracts. We do so by converting it and storing it in a variable using mcd-cli. Execute the following command to do so - replace cdp-id with your id. In our case 6613:

`export CDPID=$(mcd --to-hex cdp-id)`

In this case for example, that would be:

`export CDPID=$(mcd --to-hex 6613)`

Because we are using the `MIGRATION_PROXY_ACTIONS` contract to execute the CDP migration for us, we need to encode the smart contract call data for the migration call and save it in a variable as well. We do this by executing:

`export calldata="$(seth calldata 'migrate(address,bytes32)' "$MIGRATION" "$CDPID")"`

Lastly, we need to save the contract address of our proxy contract from the SCD CDP portal. We do this by looking up our address in the `PROXY_REGISTRY`. Execute the following to save the contract address:

`export MYPROXY=$(seth call "$PROXY_REGISTRY" 'proxies(address)(address)' $ETH_FROM)`

You can also find the proxy address through the CDP portal, as it will be the contract you are interacting with when you are generating SAI. It will for example show up when you are using MetaMask.

Now that we have saved a bunch of variables, we are ready to begin the migration of our CDP. Because the migration contract will close our SCD CDP and open a MCD CDP for us, utilizing liquidity of SAI in the migration contract to pay back our debt, there must be an excess of SAI liquidity equal or greater than the debt of the CDP we are going to migrate. If we have a CDP with a debt of 2 SAI, the migration contract must have at least 2 SAI surplus to execute migration. You can check the SAI balance of the contract by executing:

`seth --from-wei $(seth --to-dec $(seth call $SAI_SAI 'balanceOf(address)' "$MCD_JOIN_SAI")) eth`

Example output:

`$ 998.000000000000000000`

In this case, the contract has 998 SAI, so that’s plenty of leeway for us to migrate a CDP with a debt of 2 SAI.

Since the migration contract will close our SCD CDP for us, we will need to approve it to transfer some of our MKR to pay down the stability fee of the CDP. Therefore you must first approve the transfer of MKR to the migration contract by executing:

`seth send "$MCD_GOV" 'approve(address,uint256)' "$MYPROXY" "$(seth --to-uint256 "$(seth --to-wei 1000000000 ETH)")"`

Once the transaction is mined, you are ready to migrate your CDP. Execute the following command to initiate your proxy contract to migrate the CDP:

`seth send "$MYPROXY" 'execute(address,bytes memory)' "$MIGRATION_PROXY_ACTIONS" "$calldata" -G 5000000`

If the transaction fails, try increasing the gas limit with the -G modifier.

When the transaction is mined, the SCD CDP should have disappeared from cdp.makerdao.com, and the MCD CDP should appear on the MCD CDP Portal at [https://portal-main-dev.mkr-js-prod.now.sh/borrow?network=kovan](https://portal-main-dev.mkr-js-prod.now.sh/borrow?network=kovan)

If that is the case, congratulations, you have successfully migrated your CDP from SCD to MCD!

## Need help

- Rocket chat - [#dev](https://chat.makerdao.com/channel/dev) channel

## Additional resources

Guides:

- [Introduction and Overview of Multi-Collateral Dai: MCD101](https://github.com/makerdao/developerguides/blob/master/mcd/mcd-101/mcd-101.md)
- [Using MCD-CLI to create and close a MCD CDP on Kovan](https://github.com/makerdao/developerguides/blob/master/mcd/mcd-cli/mcd-cli-guide-01/mcd-cli-guide-01.md)
- [Upgrading to MCD - overview for different partners](https://github.com/makerdao/developerguides/blob/master/mcd/upgrading-to-multi-collateral-dai/upgrading-to-multi-collateral-dai.md)  
- [Add a new collateral type to DCS - Kovan](https://github.com/makerdao/developerguides/blob/master/mcd/add-collateral-type-testnet/add-collateral-type-testnet.md)  
- Source code/wiki:
  - [Multi Collateral Dai code + wiki](https://github.com/makerdao/dss)
