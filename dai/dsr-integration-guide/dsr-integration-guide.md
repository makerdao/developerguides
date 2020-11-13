---
title: DSR Integration Guide
description: Learm about DSR amd integrate it into your platform
parent: dai
tags:
  - dai
	- DSR
	- dai savings rate
	- earn savings in dai
slug: dsr-integration-guide
contentType: guides
root: false
---

# DSR Integration Guide

Level: Intermediate  
Intended Audience: Developers/Technical teams  
Time: 30-60 minutes

- [DSR Integration Guide](#dsr-integration-guide)
  - [Overview](#overview)
    - [Learning Objectives](#learning-objectives)
    - [Pre-requisites](#pre-requisites)
  - [What is DSR](#what-is-dsr)
    - [How to activate DSR](#how-to-activate-dsr)
  - [How to integrate DSR](#how-to-integrate-dsr)
    - [Smart contract addresses and ABIs](#smart-contract-addresses-and-abis)
    - [How to integrate DSR using DsrManager](#how-to-integrate-dsr-using-dsrmanager)
      - [Difference between DSRManager and Proxy Contracts](#difference-between-dsrmanager-and-proxy-contracts)
    - [How to integrate with proxy contracts](#how-to-integrate-with-proxy-contracts)
      - [Activate Savings](#activate-savings)
      - [Retrieve Savings](#retrieve-savings)
    - [Example of how to interact with the proxy contracts](#example-of-how-to-interact-with-the-proxy-contracts)
      - [Check if you have a DS-Proxy contract](#check-if-you-have-a-ds-proxy-contract)
      - [Approve DS-Proxy](#approve-ds-proxy)
      - [Deposit Dai in DSR](#deposit-dai-in-dsr)
      - [Withdraw Dai from DSR](#withdraw-dai-from-dsr)
      - [Withdraw all Dai from DSR](#withdraw-all-dai-from-dsr)
    - [How to integrate DSR through the core](#how-to-integrate-dsr-through-the-core)
    - [How to integrate with Dai.js](#how-to-integrate-with-daijs)
      - [Earning Savings on Dai](#earning-savings-on-dai)
      - [Monitor Savings](#monitor-savings)
      - [Retrieve Accrued Savings](#retrieve-accrued-savings)
    - [How to integrate with Pymaker](#how-to-integrate-with-pymaker)
      - [Examples](#examples)
  - [How to calculate rates and savings](#how-to-calculate-rates-and-savings)
    - [Calculating user earnings on a pool of Dai in DSR](#calculating-user-earnings-on-a-pool-of-dai-in-dsr)
  - [Integration Stories](#integration-stories)
    - [Centralized Exchange](#centralized-exchange)
      - [Miscellaneous recommendations](#miscellaneous-recommendations)
  - [Summary](#summary)
  - [Additional Resources](#additional-resources)
  - [Need help](#need-help)

## Overview

This guide will explain the Dai Savings Rate and how to integrate DSR into your platform. For specific DSR integration use cases, such as integrating DSR as a centralized exchange see the [Integration Stories](#integration-stories) section for a quick start guides.

### Learning Objectives

- Understand the concept of DSR

- Understand the functionality of the DSR contract

- How to best integrate DSR

### Pre-requisites

- [Working with DSProxy](https://github.com/makerdao/developerguides/blob/master/devtools/working-with-dsproxy/working-with-dsproxy.md)

- [Working with Dai.js SDK](https://docs.makerdao.com/building-on-top-of-the-maker-protocol/dai.js-wiki)

- [Working seth](https://docs.makerdao.com/clis/seth)

## What is DSR

Dai Savings Rate (DSR) is an addition to the Maker Protocol that allows any Dai holder to earn savings in Dai.

### How to activate DSR

Dai does not automatically earn savings, rather you must activate the DSR by interacting with the DSR contract [pot](https://etherscan.io/address/0x197e90f9fad81970ba7976f33cbd77088e5d7cf7#code) of the Maker Protocol. This means transferring Dai from your wallet to the Maker Protocol. It is important to note that the Dai can always be redeemed immediately (within a block), as there are no liquidity constraints, and can ONLY be retrieved to the depositing account.

Therefore it can be beneficial for any centralized exchange or custodian of Dai to integrate functionality to activate the DSR on Dai in their custody. Similarly, any decentralized exchange, wallet or dapp in general can enable anyone to earn the DSR by integrating the functionality as well.

## How to integrate DSR

There are different ways to integrate the DSR, the four main ones being either to integrate directly with the smart contracts of the Maker Protocol, `DsrManager` integrate through proxy smart contracts, using the Dai.js library, the Maker Javascript library, or through Pymaker - the Maker Python API.

- If you are running a smart contract system, or are already integrated with other protocols at a smart contract level, then it makes sense to interact directly with the Maker smart contracts. In most cases the DsrManager is the simplest way to integrate DSR functionality, as it provides an easy to use contract for this purpose. However there is also the option to integrate through the core or through proxy contracts depending on the use case.

  - If you just need to enable DSR on an amount of Dai, then it makes sense to integrate using `DsrManager`.

  - If you need to integrate with multiple features of the Maker protocol, and want to carry over the proxy identity of users that are reflected in Maker front ends (i.e. be able to automatically show vaults, earned savings etc. in a UI), then it makes sense to integrate with the proxy contracts that the Maker Foundation uses.

  - If you need to integrate the DSR and the functionality of the `DsrManager` is not enough, then it makes sense to look at integrating directly with the core Maker smart contracts.

- If you custody Dai, but are not otherwise integrated directly with the smart contract layer of Ethereum, then it makes sense to use Dai.js, as the heavy plumbing of calling the smart contracts have been done for you. In the following, both approaches will be detailed.

### Smart contract addresses and ABIs

The latest contract addresses and ABIs of the Maker Protocol can be found here: [https://changelog.makerdao.com](https://changelog.makerdao.com/)

The 1.0.2 contracts we are going to cover in the following are:

- [Dai](https://github.com/makerdao/dss/blob/master/src/dai.sol) - [0x6b175474e89094c44da98b954eedeac495271d0f](https://etherscan.io/address/0x6b175474e89094c44da98b954eedeac495271d0f#code)

- [DsrManager - 0x373238337Bfe1146fb49989fc222523f83081dDb](https://etherscan.io/address/0x373238337Bfe1146fb49989fc222523f83081dDb#code)

- [DssProxyActionsDsr](https://github.com/makerdao/dss-proxy-actions/blob/master/src/DssProxyActions.sol#L891) - [0x07ee93aeea0a36fff2a9b95dd22bd6049ee54f26](https://etherscan.io/address/0x07ee93aeea0a36fff2a9b95dd22bd6049ee54f26#code)

- [DaiJoin](https://github.com/makerdao/dss/blob/master/src/join.sol) - [0x9759a6ac90977b93b58547b4a71c78317f391a28](https://etherscan.io/address/0x9759a6ac90977b93b58547b4a71c78317f391a28#code)

- [Pot](https://github.com/makerdao/dss/blob/master/src/pot.sol) - [0x197e90f9fad81970ba7976f33cbd77088e5d7cf7](https://etherscan.io/address/0x197e90f9fad81970ba7976f33cbd77088e5d7cf7#code)

- [Vat](https://github.com/makerdao/dss/blob/master/src/vat.sol) - [0x35d1b3f3d7966a1dfe207aa4514c12a259a0492b](https://etherscan.io/address/0x35d1b3f3d7966a1dfe207aa4514c12a259a0492b#code)

### How to integrate DSR using DsrManager

The `DsrManager` is an easy-to-use smart contract that allows service providers to deposit/withdraw Dai into the DSR contract [pot](https://docs.makerdao.com/smart-contract-modules/rates-module/pot-detailed-documentation), and activate/deactivate the Dai Savings Rate to start earning savings on Dai within a single function call.

Other than integrating DSR through the Maker Protocol’s core, interacting with `DsrManager` is very similar to the other integration methods; in fact, the only difference is the former doesn’t require the Ethereum address to build and own a proxy contract.

To use DsrManager, first you need to approve the DsrManager contract in the Dai Token contract by calling `Dai.approve(address DsrManager)`. Then you are free to use the contract functions to deposit and withdraw Dai from the DSR contract.

To activate DSR on your Dai, call `join(address dst, uint256 amount)` with the address parameter being your own wallet address, or if you want to add Dai to DSR to be owned by another address you can specify that - i.e. if you want to move Dai from a hot a wallet into DSR for a cold wallet. To retrieve Dai from DSR, you can use `exit(address dst, uint256 wad)` for withdrawing a certain amount to your chosen address. Or, `exitAll(address dst)` to withdraw all Dai to a chosen address.

The savings activation flow can be split into the following steps:

1. Earn savings on Dai

    a.  `join(address dst, uint wad)`

2. Monitor savings of an address

    a.  `daiBalance(address usr) returns (uint wad)` to return the entire balance (principle + savings)

3. Retrieve earned savings

    a.  For a specific amount `exit(address dst, uint wad)`  
    b.  For entire balance `exitAll(address dst)`

For more details on the DsrManager, read the [DsrManager documentation](../dsr-manager-docs/README.md).

For a DsrManager contract integration example, [look here](./dsrManagerExample.sol). In this example you'll see a simple contract that uses the DsrManager contract as an interface.

#### Difference between DSRManager and Proxy Contracts

By using DsrManager, you can avoid having to use a DS-Proxy contract to deposit Dai into the DSR. Instead, you can simply interact directly with the DsrManager which keeps track of user balances in `pot` through the `pieOf` mapping. In many instances using DsrManager will be the simpler way of doing a smart contract based DSR integration.

### How to integrate with proxy contracts

The Maker Protocol has been developed with formal verification in mind. Therefore, the core smart contracts only contains functions that carry out singular simple actions. Consequently, in order to carry out meaningful invocations on the protocol, you must string together a series of core function calls. Instead of having to send a series of transactions, Maker’s proxy contracts atomically invoke a series of function calls that are used to interact with the Maker core in a safe and easy way. This is done through using a proxy identity for the user called [DS-Proxy](https://github.com/dapphub/ds-proxy). This library is therefore only safe if you execute actions through this proxy identity, since the proxy manages access rights. Therefore, if you execute functions directly on the proxy library DSS-Proxy-Actions-DSR, and not through DS-Proxy, there will be no access management, and funds can therefore be lost, so it is very important you only execute functions through a DS-Proxy. The good thing is that anyone who integrates the DS-Proxy will be able to reflect the same user identity as in the Maker frontends, such as [oasis.app](http://oasis.app). So if you are building a similar product suite and you want to carry over existing users, and their vaults and access to DSR from the Maker frontends, you should integrate using DS-Proxy and the proxy libraries.

In the case of a DSR integration, we want to interact with the core DSR contract called `pot` ([detailed documentation here](https://docs.makerdao.com/smart-contract-modules/rates-module/pot-detailed-documentation)) by executing function calls on a proxy contract called `dss-proxy-actions-dsr` using the [ds-proxy](https://github.com/dapphub/ds-proxy) contract.

**IMPORTANT! You should be familiar with working with ds-proxy before you attempt this integration, so it is very important that you are [well acquainted with the concepts in this guide](https://github.com/makerdao/developerguides/blob/master/devtools/working-with-dsproxy/working-with-dsproxy.md) before you proceed to ensure that you do not risk funds.**

The main idea is that you use the [`execute(address _target, bytes memory _data)`](https://github.com/dapphub/ds-proxy/blob/master/src/proxy.sol#L53) function of `ds-proxy` by using the `dss-proxy-actions-dsr` contract address and the ABI encoded call data of the function you want to execute in that specific contract.

#### Activate Savings

In order to activate savings you must send Dai to the pot contract by invoking the dss-proxy-actions-dsr proxy contract. In order to do this, you must from a ds-proxy, invoke the function [join](https://github.com/makerdao/dss-proxy-actions/blob/master/src/DssProxyActions.sol#L892) of `dss-proxy-actions-dsr` which takes the address of the Dai adapter - `DaiJoin`, the address of the DSR contract `pot`, and the amount of Dai you would like to add to the DSR contract. In order to do this, the `ds-proxy` must have an allowance on the amount of Dai you want to enable savings on.

#### Retrieve Savings

In order to retrieve Dai and savings from the `pot` there are two options - either you can retrieve a specific amount of Dai, or all Dai that the ds-proxy has the rights to with the functions [exit](https://github.com/makerdao/dss-proxy-actions/blob/master/src/DssProxyActions.sol#L910) and [exitAll](https://github.com/makerdao/dss-proxy-actions/blob/master/src/DssProxyActions.sol#L936). In order to do this, you must from the `ds-proxy` invoke the `exit` or `exitAll` functions of the `dss-proxy-actions-dsr` contract.

### Example of how to interact with the proxy contracts

We’ll use the [0.2.17 MCD Kovan Deployment](https://changelog.makerdao.com/releases/kovan/0.2.17/index.html) to showcase how you could interact with DSR using the `seth` tool with the Proxy Actions DSR contract.

**You can also use the Rinkeby, Ropsten and Goerli deployments in this guide. Just make sure to change the contract addresses from the specific network from <https://changelog.makerdao.com>**

Before starting, you need to set up the right variables in your terminal. Save the below variables:

```bash
export PROXY_REGISTRY=0x64A436ae831C1672AE81F674CAb8B6775df3475C
export PROXY_ACTIONS_DSR=0xc5cc1dfb64a62b9c7bb6cbf53c2a579e2856bf92
export POT=0xea190dbdc7adf265260ec4da6e9675fd4f5a78bb
export DaiJoin=0x5aa71a3ae1c0bd6ac27a1f28e1415fffb6f15b8c
export DAI=0x4f96fe3b7a6cf9725f59d353f723c1bdb64ca6aa
export ETH_GAS=4000000
```

#### Check if you have a DS-Proxy contract

Next step is to verify if your address has a proxy contract already deployed. If you have used [oasis.app](http://oasis.app) before, you should already have one.

Execute the command below to verify if you have a proxy contract:

`seth call $PROXY_REGISTRY 'proxies(address)(address)' $ETH_FROM`

If your output is: `0000000000000000000000000000000000000000`, then you don’t have a DS-Proxy contract.
Execute the command below to build a DS-Proxy contract for your address:

`seth send $PROXY_REGISTRY 'build()'`

Now save your proxy address in a variable:

`export MYPROXY=$(seth call $PROXY_REGISTRY 'proxies(address)(address)' $ETH_FROM)`

#### Approve DS-Proxy

In order to use the DS-Proxy contract, first you need to approve it in the Dai token contract to allow it to use your Dai for transfers.

Execute command below to approve your DS-Proxy:

`seth send $DAI 'approve(address,uint256)' $MYPROXY $(seth --to-bytes32 $(mcd --to-hex -1))`

[Here is](https://kovan.etherscan.io/tx/0x3ca89e054cfc7d0088d1a9cb4464d0b105f03c0f25b68d820368a85699adc45c) an example of a successful transaction.

#### Deposit Dai in DSR

Let’s create the calldata that we’ll use for the `execute` function in DS-Proxy.

In a terminal save the following variables:

`export wad=$(seth --to-uint256 $(seth --to-wei 1 eth))`
`export calldata=$(seth calldata 'join(address,address,uint)' $DaiJoin $POT $wad)`

`wad` is the amount of Dai you want to deposit. The `$(seth --to-wei 1 eth))` command converts the number to the eth conversion, i.e. to an integer with 18 decimals after it.

`calldata` is the bytes data defining the function call you will use in the `PROXY_ACTIONS_DSR` contract.

Now let’s call the `execute` function in your proxy contract to deposit 1 Dai into the DSR

`seth send $MYPROXY 'execute(address,bytes memory)' $PROXY_ACTIONS_DSR $calldata`

[Here is](https://kovan.etherscan.io/tx/0x2dfc47edc3c1467217b026e05e3a0ea134539e2bd174fb7e11d6ccbe363234c4) an example of a successful transaction.

#### Withdraw Dai from DSR

To withdraw a portion of your Dai from DSR you can use the `exit` function.

Set the amount you want to withdraw, in this case we use 0.5 Dai:

`export amount=$(seth --to-uint256 $(seth --to-wei 0.5 eth))`

Export the call data of the `exit` function:

`export exitDaiCalldata=$(seth calldata 'exit(address,address,uint)' $DaiJoin $POT $amount)`

Call the `execute` function in your proxy contract to withdraw 0.5 Dai from DSR:

`seth send $MYPROXY 'execute(address,bytes memory)' $PROXY_ACTIONS_DSR $exitDaiCalldata`

To check that you have received the Dai, you can check your balance using the following command:

`seth --from-wei $(seth --to-dec $(seth call $DAI 'balanceOf(address)' $ETH_FROM))`

#### Withdraw all Dai from DSR

To withdraw all your Dai balance from DSR you can call the `exitAll` function.

Export the call data of the `exitAll` function:

`export exitAllCalldata=$(seth calldata 'exitAll(address,address)' $DaiJoin $POT)`

Call the `execute` function in your proxy contract to withdraw the remaining Dai from DSR:

`seth send $MYPROXY 'execute(address,bytes memory)' $PROXY_ACTIONS_DSR $exitAllCalldata`

[Here is](https://kovan.etherscan.io/tx/0xcc4c7b3735a09b5430f0fd655913cc50d3ab563ca51944cab7ef18e6cd1856c9) an example of a successful transaction.

### How to integrate DSR through the core

In order to integrate DSR by interacting directly with the core, you need to implement a smart contract that invokes functions in the `pot` contract.

`pot` is the Dai Savings Rate contract, and you can read [detailed documentation of the contract here](https://docs.makerdao.com/smart-contract-modules/rates-module/pot-detailed-documentation). In order to earn savings on Dai, you must call the function [join](https://github.com/makerdao/dss/blob/master/src/pot.sol#L150) with the amount of Dai you want to earn savings on. However, in order for this function call to succeed you must first call [drip](https://github.com/makerdao/dss/blob/master/src/pot.sol#L140) to update the state of the system, to ensure internal balances are calculated correctly. Therefore to activate savings on x amount of Dai, you must call `pot.drip()` and then `pot.join(x)`, where `x` is a `uint256` in the same transaction. In order to do this atomically you need to implement these calls in a smart contract that can carry out both function calls in a single transaction. If you use a smart contract to carry out these function calls, since the DSR contract uses `msg.sender` as the depositor, `msg.sender` will be the only one able to retrieve Dai from DSR. So, ensure that only you have access to withdraw Dai from the DSR contract by implementing the necessary access mappings.

A simple DSR example of how to interact with the Maker core can be found [here](https://github.com/makerdao/developerguides/blob/master/dai/dsr-integration-guide/dsr.sol). **NOTE: This is just an example and has not been audited**. In this example, you can see how to properly call the `pot.join(x)`, `pot.exit(x)` and `pot.exitAll()` functions. Give close attention to the helper math functions, as they convert the Dai ERC-20 token 18 decimal into the internal accounting 27 decimal numbers.

### How to integrate with Dai.js

Dai.js is a Javascript library that makes implementing the functionality of the Maker protocol into any application easy, enabling you to build powerful applications using just a few simple functions.

By using Dai.js, you will have access to all the available functions of the Maker Protocol. This library can be used both for backend and frontend applications. The documentation of Dai.js can be found here: [https://github.com/makerdao/dai.js/wiki](https://github.com/makerdao/dai.js/wiki). The specific functionality we will go over in this document is contained and documented in the Multi-Collateral Dai package [found here](https://github.com/makerdao/dai.js/tree/dev/packages/dai-plugin-mcd).

To install the library make sure to have [node.js](https://nodejs.org/en/) installed and then run the below command:

`npm install @makerdao/dai` and include the MCD package to work with the functions that will be covered in the following sections.

#### Earning Savings on Dai

Using Dai.js, you can utilize the [join](https://github.com/makerdao/dai.js/blob/dev/packages/dai-plugin-mcd/src/SavingsService.js#L19) function to add a specified amount of Dai to the DSR contract, which will activate savings. In the example of an exchange, any time Dai is deposited into the exchange, the `join` function can be called by the exchange, so the user will instantly start earning savings on the deposited Dai. The diagram below shows the flow for the user, using an exchange which has integrated the DSR. In this case, the flow of the user does not change, as he simply deposit Dai into the exchange, which on behalf of the user will add Dai to the DSR contract to start earning savings.

![DSR Join](https://lh5.googleusercontent.com/gGI5nxHNdMnqDT8YHtUneF6Y7qw72vpwqVa1okKTH_FnXBthg1UaXm8Pm4Fx8bQSRlv5-AWjvMRCMvtaIZN78XQunIWhV5HHRn5Qc0I_ESkC2EpYnNFBCRI2Q92eXVnpsAaNjY8l)

#### Monitor Savings

In order to see the balance of a user’s Dai holdings in the savings contract, and thus how much savings he has earned, the function [balance](https://github.com/makerdao/dai.js/blob/dev/packages/dai-plugin-mcd/src/SavingsService.js#L53) can be used.
The function [getYearlyRate](https://github.com/makerdao/dai.js/blob/dev/packages/dai-plugin-mcd/src/SavingsService.js#L81) can be used to get the current savings rate.
User’s Dai balance with the exchange can be updated continuously by the exchange or in specified intervals.

#### Retrieve Accrued Savings

When a user wants to withdraw Dai, the function [exit](https://github.com/makerdao/dai.js/blob/dev/packages/dai-plugin-mcd/src/SavingsService.js#L31) can be used to withdraw a specific amount of Dai from the DSR contract. You can also invoke the [exitAll](https://github.com/makerdao/dai.js/blob/dev/packages/dai-plugin-mcd/src/SavingsService.js#L43) function, to retrieve all Dai for a user including earned savings. Afterwards, the Dai can be withdrawn from the exchange itself. Therefore, when a user wants to withdraw Dai from the exchange, these function calls can simply be invoked first in that process, resulting in a seamless experience for the user. The diagrams below show the flow for the user, when he wants to withdraw Dai from the exchange.

![DSR Exit](https://lh4.googleusercontent.com/7ZbsR-yKqS6_eRyBuMs6QM7JR30jQ4vCQCI2RwptUQegF6xE0iS2BgUjNMhyRN2oVTisycBvCAM-43AQ0_-U4yINwfJbtqB_TC9tLDFkTFPBep771fR-nGMh7bQ-BGsJZRFw25oH)

![DSR ExitAll](https://lh3.googleusercontent.com/xDj03keC6jjql90Il4-mdFgN_ZXBO2F2HlR3X8rTSPKucXbPPPDTWL42_5JAsNPpYMtMp0MOZoG3ZPisI7h-Zs226-XbQuHiidR3aV6OQonDcofKodpyeheoQ5yOxZOTyuYeTUh_)

### How to integrate with [Pymaker](https://github.com/makerdao/pymaker)

In order to ease Keeper development, a Python API for most of the Maker contracts has been created. It can be used not only by keepers, but may also be found useful by authors of some other, unrelated utilities aiming to interact with these contracts, such as DSR interaction.

You only need to import this project as a Python module if you want to utilize the API. Moreover, it offers a [transaction facility](https://github.com/makerdao/pymaker/blob/master/pymaker/__init__.py#L346), wrapped around `web3.eth.sendTransaction()`, which enables the use of [dynamic gas pricing strategies](https://github.com/makerdao/pymaker/blob/master/pymaker/gas.py).

#### Examples

The below examples follow the same interaction pattern as described above in the Dai.js section, which covers the full DSR Lifecycle of joining and exiting Dai in the `Pot` contract.

- Here's a [simple integration example](https://github.com/makerdao/pymaker/blob/master/tests/manual_test_dsr.py)
- If you need some guidance on incorporating pymaker into your project, check out our [more comprehensive integration example](https://github.com/makerdao/dsr-pymaker-example).

## How to calculate rates and savings

Whether you are integrating with the core, or the proxy contracts, you must interact directly with the core contract `pot` to retrieve the current status of the system, such as the current savings rate or the balance and earned savings for a specific user.

The current savings rate is stored in the variable `dsr` which will return the savings rate per second. At the time of writing this variable returns: 1.000000000627937192491029810 which is the savings % per second. To get the APR you simply have to uplift this number to the amount of seconds in a year: `dsr^(60*60*24*365)` - in this case this is `(1.000000000627937192491029810)^(60*60*24*365)=1.019999766` equal to 2 % APR.

The way savings grow for user balances deposited in `pot` is by using normalized balances and a rate accumulator. When you deposit Dai into `pot` the user balance is divided by the rate accumulator `chi` and stored in the normalized user balances map `pie`.

To calculate the normalized balance stored in pie you simply do the following equation:

`Normalized Balance = Deposited Dai / chi`

Everytime the system is updated by calling `drip()` the number `chi` grows according to the savings rate `dsr`. However the normalized balances in `pie` remain unchanged.

To retrieve current balance of a user in Dai, and therefore also earned savings, you must retrieve the normalized balance and and multiply it with the number `chi` to calculate the amount of Dai the user can retrieve from the contract. This is thus the reverse calculation of the earlier deposit function.

Therefore to retrieve the balance of a user, you need to do the following calculation:

`Dai balance of a user = pie[usr_address] * chi`

The above equation makes it trivial to see that when `chi` grows, Dai balance of a user grows, so this is how the compounded savings are calculated.

You can read more about rates here:

- [https://docs.makerdao.com/smart-contract-modules/rates-module#dai-savings-rate-accumulation](https://docs.makerdao.com/smart-contract-modules/rates-module#dai-savings-rate-accumulation)

- [https://github.com/makerdao/developerguides/blob/master/mcd/intro-rate-mechanism/intro-rate-mechanism.md](https://github.com/makerdao/developerguides/blob/master/mcd/intro-rate-mechanism/intro-rate-mechanism.md)

### Calculating user earnings on a pool of Dai in DSR

If you are an exchange or some other type of custodian that holds funds on behalf of users, and you want to manage a pool of Dai with DSR activated, rather than a stack for each user, you need to do some internal accounting to keep track of how much Dai each user has earned and are allowed to withdraw from the pool.
In order to do this, any time a user activates DSR on an amount of Dai, you need to calculate a normalized balance, to calculate the savings for each user.
The normalized balance is a balance that does not change, but resembles a fraction of Dai in the DSR contract. It is calculated by taking the amount of Dai a user wants to add to the DSR contract, and dividing it by the variable `chi`, which is the “rate accumulator” in the system. `chi` is a variable that increases in value at the rate of the DSR. So if the DSR is set to 4% APY, the chi value will grow 4% in a year. The rate is accumulated every second and is updated almost every block, why the number `chi` is a small number that grows slowly. The variable `chi` can be read from the Oasis API at <https://api.oasis.app/v1/save/info>, directly from the DSR smart contract [pot](https://github.com/makerdao/dss/blob/master/src/pot.sol#L61), or retrieved from the [integration libraries](https://github.com/makerdao/dai.js/blob/dev/packages/dai-plugin-mcd/src/SavingsService.js).

Therefore, when an amount of Dai of a user is added to the DSR contract, you simply need to store how much Dai they are supplying, and calculate and store what the normalized balance is at that time. So if Alice adds 10 Dai to your pool of Dai in DSR, you would record the following:

`Deposit 2020-01-08:    User: Alice,   Dai: 10,   Chi: 1.0002345,   Normalized Balance (Dai/Chi): 9.9976555`

In this case, at the time of deposit, `chi` is 1.0002345, which evaluates to a normalized balance of 9.9976555. In reality `chi` has 27 decimals, and in a production scenario it is beneficial to use all the decimals in order to achieve maximum precision, since `chi` accumulates the savings rate every second, and thus the number only grows a tiny bit every block.

3 days go by, and the `chi` value grows according to the DSR. Now `chi` is 1.0006789. Alice wants to know how much her savings has increased in value. To calculate her stack, you simply take

`Normalized Balance_Alice * chi`
`= 9.9976555 * 1.0006789 = 10.0044429 Dai`

Alice has thus earned 0.0044 Dai in 3 days, and can withdraw this amount + her original 10 Dai from the Dai pool in DSR. However Alice decides to add 10 Dai extra to the pool. Again, you simply need to record the amount she deposits, and the current `chi` value to calculate the normalized balance.

`Deposit 2020-01-11:    User: Alice,   Dai: 10,   Chi: 1.0006789,   Normalized Balance (Dai/Chi): 9.9932156`

Notice that since `chi` has gone up since the first deposit, this time Alice’s normalized balance is lower. This is how the system keeps track on how much Dai deposits on different days have earned from the DSR.

3 days more go by, and now Alice wants to calculate how much her total amount of Dai in DSR is worth. Now `chi` is: 1.0011233.
This time, you must add the two normalized balances, and multiply it with `chi`. So the equation is:

`SUM(Normalized Balances)*chi`
`= (9.997655+9.9932156)*1.0011233 = 20.0133263 Dai`

Alice’s Dai holdings in DSR is now 20.0133 Dai, so she has in total earned 0.0133 Dai over the 6 days.

To sum up, in order to keep track of user holdings of Dai in a DSR pool, you must simply calculate and store the normalized balance of their Dai at that point in time their Dai is added to the pool, by dividing their Dai contribution with `chi`. When the user wants to retrieve all their Dai, you simply take their entire normalized balance and multiply it with `chi`, to calculate how much Dai he can retrieve.

## Integration Stories

As described in this guide, there are many approaches to integrate DSR support into your system. Each approach has pros and cons, varying levels of complexity, and different technical requirements. This section is purposed to help streamline the integration experience for integration stories of common intention. Akin to directions on a map, integration stories help guide the reader through a suggested path, but they do not prohibit exploration of other paths, which may lead to improved or more thoughtful integrations. Each story begins with some assumptions of the developer’s system, an introduction to the story, and the contents thereof.

### Centralized Exchange

The following assumptions about your system’s design and operation:

- Single cold/hot wallet(s) holding assets for multiple users

- Scalable off-chain accounting system holding a record of users’ balances

- Asynchronous contract calls following User action

- Ability to make calls to contracts that don’t inherit the ERC20 spec

- Will not need to interact with adjacent systems that require a [proxy identity](https://github.com/makerdao/developerguides/blob/master/devtools/working-with-dsproxy/working-with-dsproxy.md).

With these assumptions, the following integration story is relieved of the proxy-identity requirement and prioritizes simplicity for the centralized exchange. In the following steps, we build up the prerequisite knowledge of the DSR and outline the steps to integrate the `DsrManager` before concluding with some recommendations. Considered as the simplest and most secure way of adding Dai to the DSR, the `DsrManager` is a smart contract that allows service providers to deposit/withdraw Dai into the DSR contract ([Pot contract](https://docs.makerdao.com/smart-contract-modules/rates-module/pot-detailed-documentation)), and activate/deactivate the Dai Savings Rate to start earning savings on a pool of Dai in a single function call. Let us begin:

1. Become knowledgeable of the DSR
   - [What is DSR?](#what-is-dsr)
2. Understand at a high level how to integrate the DSR (read only the introduction)
   - [How to integrate DSR](#how-to-integrate-dsr)
3. Integrate with the DsrManager
   - [How to integrate with the DsrManager](#how-to-integrate-dsr-using-dsrmanager)
4. Learn how rates and savings are calculated in the Pot contract
   - [How to calculate rates and savings](#how-to-calculate-rates-and-savings)
5. Calculate the savings for each user while operating a single wallet
   - [Calculating user earnings on a pool of Dai in DSR](#calculating-user-earnings-on-a-pool-of-dai-in-dsr)
6. Incorporate design patterns to handle Emergency Shutdown. Under extreme circumstances, such as prolonged market irrationality, governance attacks, or severe vulnerabilities, the Maker Protocol will go through Emergency Shutdown. It’s of paramount importance to ensure your systems can handle Dai in the DSR contract after Emergency shutdown has been triggered.
   - [Emergency Shutdown Design Guide](https://github.com/makerdao/developerguides/blob/master/mcd/emergency-shutdown-design-patterns/emergency-shutdown-design-patterns.md)

#### Miscellaneous recommendations

- Consider automatically depositing Dai into the DSR contract either as soon as it’s deposited into the exchange or after a User action to “activate” the DSR.
- Both joining and exiting from the `DsrManager` can direct ownership of the Dai deposit and withdrawal between accounts. Although private key management may differ across exchanges, we suggest joining with the hot wallet and transferring ownership of the Dai activated in the DSR to the cold wallet; similarly, we recommend exiting with the cold wallet and transferring the Dai principle + savings amount to the hot wallet, where it can be later transferred to a user wishing to withdrawal Dai from the exchange. Presented in another way:
  - Calling `join(<cold address>, <Dai amount>)` from the Hot wallet
  - Calling `exit(<hot address>, <Dai amount>)` from the Cold wallet

## Summary

In this guide, we covered the basics of DSR, and how to properly integrate DSR, by either using core contracts, proxy contracts or the Dai.js library.

## Additional Resources

- [https://github.com/makerdao/dss](https://github.com/makerdao/dss)

- [https://docs.makerdao.com/](https://docs.makerdao.com/)

## Need help

- Contact Integrations team - [integrate@makerdao.com](mailto:integrate@makerdao.com)

- Rocket chat - #dev channel
