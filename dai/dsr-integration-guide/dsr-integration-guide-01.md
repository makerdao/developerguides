# DSR Integration Guide
Level: Intermediate

Intended Audience: Developers/Technical teams

Time: 30-60 minutes

## Overview

This guide will explain the Dai Savings Rate and how to integrate DSR into your platform.

### Learning Objectives

-   Understand the concept of DSR

-   Understand the functionality of the DSR contract

-   How to best integrate DSR


### Contents of this guide

-   [What is DSR?](#what-is-dsr)

	-   [How to activate DSR](#how-to-activate-dsr)

-   [How to integrate DSR](#how-to-integrate-dsr)

	-   [How to integrate DSR through the core](#how-to-integrate-dsr-through-the-core)

	-   [How to integrate with proxy contracts](#how-to-integrate-with-proxy-contracts)

	-   [How to integrate with Dai.js](#how-to-integrate-with-daijs)

-   [How to calculate rates and savings](#how-to-calculate-rates-and-savings)

	-   [Calculating user earnings on a pool of Dai in DSR](#calculating-user-earnings-on-a-pool-of-dai-in-dsr)


### Pre-requisites
-   [Working with DSProxy](https://github.com/makerdao/developerguides/blob/master/devtools/working-with-dsproxy/working-with-dsproxy.md)

-   [Working with Dai.js SDK](https://docs.makerdao.com/building-on-top-of-the-maker-protocol/dai.js-wiki)

-   [Working seth](https://docs.makerdao.com/clis/seth)

## What is DSR?
Dai Savings Rate (DSR) is an addition to the Maker Protocol that allows any Dai holder to earn risk-free savings in Dai. The savings paid out to Dai holders are financed by a fraction of the stability fee that Vault owners pay for borrowing Dai. The DSR is adjustable by MKR holders, and acts as a tool to manipulate demand of Dai, and thus ensuring the peg. At the time of writing the DSR is set to 7.75 % APY, but will change over time depending on MKR governance, just like the stability fee on borrowing Dai.

### How to activate DSR
Dai does not automatically earn savings, rather you must activate the DSR by interacting with the DSR contract [pot](https://etherscan.io/address/0x197e90f9fad81970ba7976f33cbd77088e5d7cf7#code) of the Maker Protocol. This means transferring Dai from your wallet to the Maker Protocol. It is important to note that the Dai is never locked and can always be redeemed immediately (within a block), as there are no liquidity constraints, and can ONLY be retrieved to the depositing account. Activating DSR is therefore completely safe and adds no further risk, than the risk of holding Dai in the first place. Consequently, you should ALWAYS activate Dai Savings Rate on any Dai that is being held in custody, and simply deactivate DSR (by effectively retrieving Dai to your wallet) when you need to transfer Dai, or use Dai in dapps.
DSR
Therefore any centralized exchange or custodian of Dai should integrate functionality to activate the DSR on Dai in their custody. Similarly, any decentralized exchange, wallet or dapp in general can enable anyone to earn the DSR by integrating the functionality as well, by exposing it as a simple “enable” button click.

## How to integrate DSR
There are different ways to integrate the DSR, the three main ones being either to integrate directly with the core smart contracts of the Maker Protocol, integrate through proxy smart contracts, or to use the Dai.js library - the Maker Javascript library.

-   If you are running a smart contract system, or are already integrated with other protocols at a smart contract level, then it makes sense to interact directly with the Maker smart contracts, either by interacting directly with the core or through proxy contracts depending on the use case.

	-   If you just need to enable DSR on a pool of Dai, then it makes sense to integrate with the core.

	-   If you need to integrate with multiple features of the Maker protocol, and want to carry over the proxy identity of users that are reflected in Maker front ends (i.e. be able to automatically show vaults, earned savings etc. in a UI), then it makes sense to integrate with the proxy contracts that the Maker Foundation uses.

-   If you custody Dai, but are not otherwise integrated directly with the smart contract layer of Ethereum, then it makes sense to use Dai.js, as the heavy plumbing of calling the smart contracts have been done for you. In the following, both approaches will be detailed.

### Smart contract addresses and ABIs
The contract addresses and ABIs of the Maker Protocol can be found here: [https://changelog.makerdao.com/releases/mainnet/1.0.2/index.html](https://changelog.makerdao.com/releases/mainnet/1.0.2/index.html)

The contracts you need to work with are:

-   [Dai](https://github.com/makerdao/dss/blob/master/src/dai.sol) - [0x6b175474e89094c44da98b954eedeac495271d0f](https://etherscan.io/address/0x6b175474e89094c44da98b954eedeac495271d0f#code)

-   [DaiJoin](https://github.com/makerdao/dss/blob/master/src/join.sol) - [0x9759a6ac90977b93b58547b4a71c78317f391a28](https://etherscan.io/address/0x9759a6ac90977b93b58547b4a71c78317f391a28#code)

-   [Pot](https://github.com/makerdao/dss/blob/master/src/pot.sol) - [0x197e90f9fad81970ba7976f33cbd77088e5d7cf7](https://etherscan.io/address/0x197e90f9fad81970ba7976f33cbd77088e5d7cf7#code)

-   [Vat](https://github.com/makerdao/dss/blob/master/src/vat.sol) - [0x35d1b3f3d7966a1dfe207aa4514c12a259a0492b](https://etherscan.io/address/0x35d1b3f3d7966a1dfe207aa4514c12a259a0492b#code)

-   [DssProxyActionsDsr](https://github.com/makerdao/dss-proxy-actions/blob/master/src/DssProxyActions.sol#L891) - [0x07ee93aeea0a36fff2a9b95dd22bd6049ee54f26](https://etherscan.io/address/ o0x07ee93aeea0a36fff2a9b95dd22bd6049ee54f26#code)


You can find ABIs here: [https://changelog.makerdao.com/releases/mainnet/1.0.2/abi/index.html](https://changelog.makerdao.com/releases/mainnet/1.0.2/abi/index.html)

### How to integrate DSR through the core

In order to integrate DSR by interacting directly with the core, you need to implement a smart contract that invokes functions in the `pot` contract.

`pot` is the Dai Savings Rate contract, and you can read [detailed documentation of the contract here](https://docs.makerdao.com/smart-contract-modules/rates-module/pot-detailed-documentation). In order to accrue savings on Dai, you must call the function [join](https://github.com/makerdao/dss/blob/master/src/pot.sol#L150) with the amount of Dai you want to accrue savings on. However, in order for this function call to succeed you must first call [drip](https://github.com/makerdao/dss/blob/master/src/pot.sol#L140) to update the state of the system, to ensure internal balances are calculated correctly. Therefore to activate savings on x amount of Dai, you must call `pot.drip()` and then `pot.join(x)`, where x is a `uint256` in the same transaction. In order to do this atomically you need to implement these calls in a smart contract that can carry out both function calls in a single transaction. If you use a smart contract to carry out these function calls, since the DSR contract uses msg.sender as the depositor, msg.sender will be the only one able to retrieve Dai from DSR. So, ensure that only you have access to withdraw Dai from the DSR contract by implementing the necessary access mappings.

A simple DSR example of how to interact with the Maker core can be found [here](https://github.com/makerdao/developerguides/blob/master/dai/dsr-integration-guide/dsr.sol). **NOTE: Make sure to not use this code in production, as it has not been audited**. In this example, you can see how to properly call the `pot.join(x)`, `pot.exit(x)` and `pot.exitAll()` functions. Give close attention to the helper math functions, as they convert the Dai ERC-20 token 18 decimal into the internal accounting 27 decimal numbers. This could be used as inspiration for services that have a pool of Dai interacting with the Dai Savings Rate. Again, it is important to note that **the former example is not production ready code, but only for inspiration**.

### How to integrate with proxy contracts

The Maker Protocol has been developed with formal verification in mind. Therefore, the core smart contracts only contains functions that carry out singular simple actions. Consequently, in order to carry out meaningful invocations on the protocol, you must string together a series of core function calls. Instead of having to send a series of transactions, Maker’s proxy contracts atomically invoke a series of function calls that are used to interact with the Maker core in a safe and easy way. This is done through using a proxy identity for the user called [DS-Proxy](https://github.com/dapphub/ds-proxy). This library is therefore only safe if you execute actions through this proxy identity, since the proxy manages access. Therefore, if you execute functions directly on the proxy library DSS-Proxy-Actions-DSR, and not through DS-Proxy, there will be no access management, and funds can therefore be lost, so it is very important you only execute functions through a DS-Proxy. The good thing is that anyone who integrates the DS-Proxy will be able to reflect the same user identity as in the Maker frontends, such as [oasis.app](http://oasis.app). So if you are building a similar product suite and you want to carry over existing users, and their vaults and access to DSR from the Maker frontends, you should integrate using DS-Proxy and the proxy libraries.

In the case of a DSR integration, we want to interact with the core DSR contract called `pot` ([detailed documentation here](https://docs.makerdao.com/smart-contract-modules/rates-module/pot-detailed-documentation)) by executing function calls on a proxy contract called `dss-proxy-actions-dsr` using the [ds-proxy](https://github.com/dapphub/ds-proxy) contract.

**IMPORTANT! You should be familiar with working with ds-proxy before you attempt this integration, so it is very important that you are [well acquainted with the concepts in this guide](https://github.com/makerdao/developerguides/blob/master/devtools/working-with-dsproxy/working-with-dsproxy.md) before you proceed to ensure that you do not risk funds.**

The main idea is that you use the [execute(address _target, bytes memory _data)](https://github.com/dapphub/ds-proxy/blob/master/src/proxy.sol#L53) function of `ds-proxy` by using the `dss-proxy-actions-dsr` contract address and the ABI encoded call data of the function you want to execute in that specific contract.

#### Activate Savings

In order to activate savings you must send Dai to the pot contract by invoking the dss-proxy-actions-dsr proxy contract. In order to do this, you must from a ds-proxy, invoke the function [join](https://github.com/makerdao/dss-proxy-actions/blob/master/src/DssProxyActions.sol#L892) of `dss-proxy-actions-dsr` which takes the address of the Dai adapter - `DaiJoin`, the address of the DSR contract `pot`, and the amount of Dai you would like to add to the DSR contract. In order to do this, the `ds-proxy` must have an allowance on the amount of Dai you want to enable savings on.

#### Retrieve Savings

In order to retrieve Dai and savings from the `pot` there are two options - either you can retrieve a specific amount of Dai, or all Dai that the ds-proxy has the rights to with the functions [exit](https://github.com/makerdao/dss-proxy-actions/blob/master/src/DssProxyActions.sol#L910) and [exitAll](https://github.com/makerdao/dss-proxy-actions/blob/master/src/DssProxyActions.sol#L936). In order to do this, you must from the `ds-proxy` invoke the `exit` or `exitAll` functions of the `dss-proxy-actions-dsr` contract.

### Example of how to interact with the proxy contracts

We’ll use the [0.2.17 MCD Kovan Deployment](https://changelog.makerdao.com/releases/kovan/0.2.17/index.html) to showcase how you could interact with DSR using the `seth` tool with the Proxy Actions DSR contract.

Before starting, you need to set up the right variables in your terminal. Save the below variables:

```
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

### How to integrate with Dai.js

Dai.js is a Javascript library that makes implementing the functionality of the Maker protocol into any application easy, enabling you to build powerful DeFi applications using just a few simple functions.

By using our in house library, you will have access to all the available functions of the Maker Protocol. This library can be used both for backend and frontend applications. The documentation of Dai.js can be found here: [https://github.com/makerdao/dai.js/wiki](https://github.com/makerdao/dai.js/wiki). The documentation will be updated to feature the new functionality of Multi-Collateral Dai soon. The specific functionality we will go over in this document is contained and documented in the Multi-Collateral Dai package [found here](https://github.com/makerdao/dai.js/tree/dev/packages/dai-plugin-mcd).

To install the library make sure to have [node.js](https://nodejs.org/en/) installed and then run the below command:

`npm install @makerdao/dai` and include the MCD package to work with the functions that will be covered in the following sections.

#### Earning Savings on Dai

To automatically earn savings on any Dai holdings is also a very simple integration. Using Dai.js, you can utilize the [join](https://github.com/makerdao/dai.js/blob/dev/packages/dai-plugin-mcd/src/SavingsService.js#L19) function to add a specified amount of Dai to the savings contract, which will instantly start earning savings. In the example of an exchange, any time Dai is deposited into the exchange, the `join` function should be called, so you will instantly start earning savings on the deposited Dai. The diagram below shows the flow for the user, having integrated DSR into the exchange. In this case, the flow of the user does not change, as he simply deposit Dai into the exchange and starts earning savings, while everything else is handled on the back end.

![](https://lh5.googleusercontent.com/gGI5nxHNdMnqDT8YHtUneF6Y7qw72vpwqVa1okKTH_FnXBthg1UaXm8Pm4Fx8bQSRlv5-AWjvMRCMvtaIZN78XQunIWhV5HHRn5Qc0I_ESkC2EpYnNFBCRI2Q92eXVnpsAaNjY8l)

#### Monitor Savings

In order to see the balance of a user’s Dai holdings in the savings contract, and thus how much savings he has earned, the function [balance](https://github.com/makerdao/dai.js/blob/dev/packages/dai-plugin-mcd/src/SavingsService.js#L53) can be used.
The function [getYearlyRate](https://github.com/makerdao/dai.js/blob/dev/packages/dai-plugin-mcd/src/SavingsService.js#L81) can be used to get the current savings rate.
User’s Dai balance with the exchange can be updated continuously by the exchange or in specified intervals.

#### Retrieve Accrued Savings

When a user wants to withdraw Dai, the function [exit](https://github.com/makerdao/dai.js/blob/dev/packages/dai-plugin-mcd/src/SavingsService.js#L31)  can be used to withdraw a specific amount of Dai from the savings contract. You can also invoke the [exitAll](https://github.com/makerdao/dai.js/blob/dev/packages/dai-plugin-mcd/src/SavingsService.js#L43) function, to retrieve all Dai for a user including accrued savings. Afterwards, the Dai can be withdrawn from the exchange itself. Therefore, when a user wants to withdraw Dai from the exchange, these function calls can simply be invoked first in that process, resulting in a seamless experience for the user. The diagrams below show the flow for the user, when he wants to withdraw Dai from the exchange.

![](https://lh4.googleusercontent.com/7ZbsR-yKqS6_eRyBuMs6QM7JR30jQ4vCQCI2RwptUQegF6xE0iS2BgUjNMhyRN2oVTisycBvCAM-43AQ0_-U4yINwfJbtqB_TC9tLDFkTFPBep771fR-nGMh7bQ-BGsJZRFw25oH)

![](https://lh3.googleusercontent.com/xDj03keC6jjql90Il4-mdFgN_ZXBO2F2HlR3X8rTSPKucXbPPPDTWL42_5JAsNPpYMtMp0MOZoG3ZPisI7h-Zs226-XbQuHiidR3aV6OQonDcofKodpyeheoQ5yOxZOTyuYeTUh_)

## How to calculate rates and savings

Whether you are integrating with the core, or the proxy contracts, you must interact directly with the core contract `pot` to retrieve the current status of the system, such as the current savings rate or the balance and accrued interest for a specific user.

The current savings rate is stored in the variable `dsr` which will return the accruing savings rate per second. At the time of writing this variable returns: 1.000000000627937192491029810 which is the savings % per second. To get the APR you simply have to uplift this number to the amount of seconds in a year: `dsr^(60*60*24*365)` - in this case this is `(1.000000000627937192491029810)^(60*60*24*365)=1.019999766` equal to 2 % APR.

The way interest is accrued on user balances deposited in `pot` is by using normalized balances and a rate accumulator. When you deposit Dai into `pot` the user balance is divided by the rate accumulator `chi`and stored in the normalized user balances map `pie`.

To calculate the normalized balance stored in pie you simply do the following equation:

`Normalized Balance = Deposited Dai / chi`

Everytime the system is updated by calling drip() the number `chi` grows according to the savings rate `dsr`. However the normalized balances in `pie` remain unchanged.

To retrieve current balance of a user in Dai, and therefore also accrued savings, you must retrieve the normalized balance and and multiply it with the number `chi` to calculate the amount of Dai the user can retrieve from the contract. This is thus the reverse calculation of the earlier deposit function.

Therefore to retrieve the balance of a user, you need to do the following calculation:

`Dai balance of a user = pie[usr_address] * chi`

The above equation makes it trivial to see that when `chi` grows, Dai balance of a user grows, so this is how the compounded savings are calculated.

You can read more about rates here:

-   [https://docs.makerdao.com/smart-contract-modules/rates-module#dai-savings-rate-accumulation](https://docs.makerdao.com/smart-contract-modules/rates-module#dai-savings-rate-accumulation)

-   [https://github.com/makerdao/developerguides/blob/master/mcd/intro-rate-mechanism/intro-rate-mechanism.md](https://github.com/makerdao/developerguides/blob/master/mcd/intro-rate-mechanism/intro-rate-mechanism.md)

### Calculating user earnings on a pool of Dai in DSR
If you are an exchange or some other type of custodian that holds funds on behalf of users, and you want to manage a pool of Dai with DSR activated, rather than a stack for each user, you need to do some internal accounting to keep track of how much Dai each user has earned and are allowed to withdraw from the pool.
In order to do this, any time a user activates DSR on an amount of Dai, you need to calculate a normalized balance, to calculate the compounding rate for each user.
The normalized balance is a balance that does not change, but resembles a fraction of Dai in the DSR. It is calculated by taking the amount of Dai a user wants to add to the DSR contract, and dividing it by the variable `chi`, which is the “rate accumulator” in the system. `chi` is a variable that increases in value at the rate of the DSR. So if the DSR is set to 4% APR, the chi value will grow 4% in a year. The rate is accumulated every second and is updated almost every block, why the number `chi` is a small number that grows slowly. The variable `chi` can be read from the Oasis API at https://api.oasis.app/v1/save/info, directly from the DSR smart contract [pot](https://github.com/makerdao/dss/blob/master/src/pot.sol#L61), or retrieved from the [integration libraries](https://github.com/makerdao/dai.js/blob/dev/packages/dai-plugin-mcd/src/SavingsService.js).

Therefore, when an amount of Dai of a user is added to the DSR contract, you simply need to store how much Dai they are supplying, and calculate and store what the normalized balance is at that time. So if Alice adds 10 Dai to your pool of Dai in DSR, you would record the following:

`Deposit 2020-01-08:    User: Alice,   Dai: 10,   Chi: 1.0002345,   Normalized Balance (Dai/Chi): 9.9976555`

In this case, at the time of deposit, `chi` is 1.0002345, which evaluates to a normalized balance of 9.9976555. In reality `chi` has 27 decimals, and in a production scenario it is beneficial to use all the decimals in order to achieve maximum precision, since `chi` accumulates the savings rate every second, and thus the number only grows a tiny bit every block.

3 days go by, and the `chi` value grows according to the DSR. Now `chi` is 1.0006789. Alice wants to know how much her savings has increased in value. To calculate her stack, you simply take

`Normalized Balance_Alice * chi`
`= 9.9976555 * 1.0006789 = 10.0044429 Dai`

Alice has thus earned 0.0044 Dai in 3 days, and can withdraw this amount + her original 10 Dai from the Dai pool in DSR. However Alice decides to add 10 Dai extra to the pool. Again, you simply need to record the amount she deposits, and the current `chi` value to calculate the normalized balance.

`Deposit 2020-01-11:    User: Alice,   Dai: 10,   Chi: 1.0006789,   Normalized Balance (Dai/Chi): 9.9932156`

Notice that since `chi` has gone up since the first deposit, this time Alice’s normalized balance is lower. This is how we can keep track on how much Dai deposits on different days have earned from the DSR.

3 days more go by, and now Alice wants to calculate how much her total amount of Dai in DSR is worth. Now `chi` is: 1.0011233.
This time, you must add the two normalized balances, and multiply it with `chi`. So the equation is:

`SUM(Normalized Balances)*chi`
`= (9.997655+9.9932156)*1.0011233 = 20.0133263 Dai`

Alice’s Dai holdings in DSR is now 20.0133 Dai, so she has in total earned 0.0133 Dai over the 6 days.

To sum up, in order to keep track of user holdings of Dai in a DSR pool, you must simply calculate and store the normalized balance of their Dai at that point in time their Dai is added to the pool, by dividing their Dai contribution with `chi`. When the user wants to retrieve all their Dai, you simply take their entire normalized balance and multiply it with `chi`, to calculate how much Dai he can retrieve.

## Summary

In this guide, we covered the basics of DSR, and how to properly integrate DSR, by either using core contracts, proxy contracts or the Dai.js library.

## Additional Resources

-   [https://github.com/makerdao/dss](https://github.com/makerdao/dss)

-   [https://docs.makerdao.com/](https://docs.makerdao.com/)


## Need help?

-   Contact Integrations team - [integrate@makerdao.com](mailto:integrate@makerdao.com)

-   Rocket chat - #dev channel
