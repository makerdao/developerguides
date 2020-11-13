---
title: How to use Oasis Direct Proxy on OasisDEX Protocol
description: Learn about Oasis Direct Proxy and how it is used in OasisDEX Protocol
parent: oasisdex
tags:
  - oasisdex
  - proxy contract
  - trade
  - decentralized  
slug: how-to-use-oasis-direct-proxy-on-oasisdex-protocol
contentType: guides
root: false
---

# How to use Oasis Direct Proxy on OasisDEX Protocol

**Level:** Intermediate  
**Estimated Time:** 30 minutes

- [How to use Oasis Direct Proxy on OasisDEX Protocol](#how-to-use-oasis-direct-proxy-on-oasisdex-protocol)
  - [Overview](#overview)
  - [Learning Objectives](#learning-objectives)
  - [Pre-requisites](#pre-requisites)
  - [Sections](#sections)
  - [Set up contract addresses in your terminal](#set-up-contract-addresses-in-your-terminal)
  - [Setting up or retrieve your proxy contract](#setting-up-or-retrieve-your-proxy-contract)
  - [Oasis Direct Proxy Functions](#oasis-direct-proxy-functions)
  - [Making a trade](#making-a-trade)
    - [Creating the calldata](#creating-the-calldata)
    - [Executing the function](#executing-the-function)
  - [Summary](#summary)
  - [Additional Resources](#additional-resources)
  - [Help](#help)
  
## Overview

Trading on decentralized marketplaces involves signing multiple transactions with your wallet. This leads to having higher chances of having failed transactions. Using a proxy simplifies this process by combining many transactions into one.

This guide will show you how to make trades on the OasisDEX Protocol through the [Oasis Direct Proxy](https://github.com/makerdao/oasis-direct-proxy). The Oasis Direct Proxy allows you to bundle together many function calls into a single transaction. So, when you have to trade some ERC-20 tokens, you will be able to do it all in one transaction.

This can be done through the DS-Proxy contract, which is a generic mechanism that allows for bundling transactions and having allowances setup once for different contracts, or by creating your own proxy contract that can interact with the Oasis Direct Proxy contract. Another example of a proxy contract is the one created by [https://instadapp.io/](https://instadapp.io/), which interacts with many services.

Using a proxy contract is beneficial for you as a user or as a developer that wants to build DApps. The most obvious use case is the front-end applications that interact with the protocol. A good example is the [oasis.app](https://oasis.app/) and the [Dai.js SDK](https://github.com/makerdao/dai.js).

## Learning Objectives

- Learn about the Oasis Direct Proxy functions
- Learn how to use the Oasis Direct Proxy on the OasisDEX Protocol

## Pre-requisites

- [Seth tools](https://github.com/dapphub/dapptools/tree/master/src/seth#installing) - command line tool to interact with the ethereum network
- [Understand how a DSProxy works](https://github.com/makerdao/developerguides/blob/master/devtools/working-with-dsproxy/working-with-dsproxy.md)
- [Understand the OasisDEX protocol](https://github.com/makerdao/developerguides/blob/master/Oasis/intro-to-oasis/intro-to-oasis-maker-otc.md)

## Sections

This guide will demonstrate how to use the Oasis Direct Proxy functions available on the GitHub repository [here](https://github.com/makerdao/oasis-direct-proxy). If you also want to learn the extra details of each function, please also read the README from the mentioned repository.

This guide works with the MCD Dai [0.2.17 Kovan Release](https://changelog.makerdao.com/releases/kovan/0.2.17/contracts.json). Here you will find all the necessary contract addresses.

## Set up contract addresses in your terminal

Export the below environmental variables in your terminal:

`export PROXY_REGISTRY=0x64a436ae831c1672ae81f674cab8b6775df3475c`
`export OASIS_DIRECT_PROXY=0xEE419971E63734Fed782Cfe49110b1544ae8a773`
`export WETH=0xd0a1e359811322d97991e03f863a0c30c2cf029c`
`export DAI=0x4f96fe3b7a6cf9725f59d353f723c1bdb64ca6aa`
`export OTC=0x4A6bC4e803c62081ffEbCc8d227B5a87a58f1F8F`
`export ETH_GAS=4000000`
`export ETH_GAS_PRICE=2500000000`

**Proxy Registry** - Is a map of proxy contracts and their owner addresses. Here you can check if you have a proxy

**Oasis Direct Proxy** - This is a contract with all the available functions that can be used to make a trade on the OasisDEX protocol.

**WETH** - Is the wrapped Ether contract that turns ETH into and ERC-20 compatible token.

**DAI** - Is the Multi-Collateral Dai token address from the [0.2.17 Kovan Deployment](https://changelog.makerdao.com/releases/kovan/0.2.17/contracts.json)

**OTC** - Is the OasisDEX protocol contract address

**ETH Gas** - Is the the gas limit

**ETH Gas Price** - Is the gas price

## Setting up or retrieve your proxy contract

There are many ways to interact with the Oasis Direct Proxy contract. You can:

- Directly call functions in the Oasis Direct Proxy
- Set up a proxy contract that would call functions on your behalf when interacting with the Oasis Direct contract

If you choose to interact directly with the Oasis Direct Proxy, then you’ll have to give allowance to this contract.  
If you choose to use DS-Proxy, then you give allowance only once and this contract can interact with any other proxy actions contract without having to give allowance again.

In this guide, we’ll use the DS-Proxy contract as your proxy that will interact with the Oasis Direct Proxy contract.

First you need to set up a DSProxy contract for your wallet. Or retrieve the address if you already have one.

Execute the command below to verify if you have a proxy contract:

`seth call $PROXY_REGISTRY 'proxies(address)(address)' $ETH_FROM`
  
If the output is an address (for instance `3704fa2f6234ad5f2da063121496003e999c5312`), then this address is your proxy contract. If you get an output like this: `0000000000000000000000000000000000000000` then you don’t have one.

In case you don’t have the proxy contract, you can set it up through the below command:

`seth send $PROXY_REGISTRY 'build()'`

Now to see your proxy contract address, execute the above command that verifies if you have a proxy address. After executing it. Store your proxy address in an env variable.

`export MYPROXY=$(seth call $PROXY_REGISTRY 'proxies(address)(address)' $ETH_FROM)`

## Oasis Direct Proxy Functions

These functions are used to make instant market orders on the marketplace. If you want to see a frontend example, check out the instant page on [oasis.app/trade/instant](https://oasis.app/trade/instant). If you want to make a simple limit order, then check the OasisDEX protocol [contract](https://github.com/makerdao/maker-otc).

The Oasis Direct Proxy covers 6 functions that you could use. These are:

- [sellAllAmount](https://github.com/makerdao/oasis-direct-proxy/blob/321f63bb33fb534c490e8c56680daeab10608bc1/src/OasisDirectProxy.sol#L27) - Triggering an ERC-20 for ERC-20 trade
- [sellAllAmountPayEth](https://github.com/makerdao/oasis-direct-proxy/blob/321f63bb33fb534c490e8c56680daeab10608bc1/src/OasisDirectProxy.sol#L36) - Triggering an ETH for ERC-20 token trade
- [sellAllAmountBuyEth](https://github.com/makerdao/oasis-direct-proxy/blob/321f63bb33fb534c490e8c56680daeab10608bc1/src/OasisDirectProxy.sol#L45) - Triggering an ERC-20 for ETH trade
- [buyAllAmount](https://github.com/makerdao/oasis-direct-proxy/blob/321f63bb33fb534c490e8c56680daeab10608bc1/src/OasisDirectProxy.sol#L54) - Triggering an ERC-20 for ERC-20 trade
- [buyAllAmountPayEth](https://github.com/makerdao/oasis-direct-proxy/blob/321f63bb33fb534c490e8c56680daeab10608bc1/src/OasisDirectProxy.sol#L65) - Triggering an ETH for ERC-20 token trade
- [buyAllAmountBuyEth](https://github.com/makerdao/oasis-direct-proxy/blob/321f63bb33fb534c490e8c56680daeab10608bc1/src/OasisDirectProxy.sol#L76) - Triggering an ERC-20 for ETH trade

If you want to understand each function in more detail, please do read the provided [README](https://github.com/makerdao/oasis-direct-proxy). For example, if you want to sell exactly 10 BAT for some amount of ETH, you can use sellAllAmountBuyEth(). If you want to sell at least 10 ZRX for some specified amount of DAI, you can use buyAllAmount() as you will be buying specific amount of DAI, paying for it with ZRX.

These functions will wrap/unwrap ETH (if necessary), check the on-chain liquidity (using getBuyAmount() and getPayAmount() OTC methods) and finally call OTC’s buyAllAmount/sellAllAmount() methods if the liquidity and price is within user’s supplied limits.

In addition, you will have to give allowance to the tokens you want to trade to the DS-Proxy contract in order for the trades to succeed. This is due to the majority of functions having a `pull` of funds method from your wallet in order to carry the trade.

So, in the case that you want to sell Dai or WETH, you will have to approve the tokens to DS-Proxy.  
Below is an example of how to do it:

**Approve Dai in MYPROXY:**

`seth send $DAI 'approve(address,uint256)' $MYPROXY $(seth --to-bytes32 $(mcd --to-hex -1))`

**Approve WETH in MYPROXY:**

`seth send $WETH 'approve(address,uint256)' $MYPROXY $(seth --to-bytes32 $(mcd --to-hex -1))`

With DS-Proxy you only have to approve the token contracts once in order to carry as many trades as you want. This is the benefit of using such contract.

## Making a trade

Note: Check the liquidity on the [marketplace](https://oasis.app/trade) on the Kovan network before doing any function calls. If there is no liquidity, then you will have failed transactions.

Let’s assume we want to buy exactly 3 Dai on the Oasis protocol. In order to process this trade, we can use the buyAllAmountPayEth function. In this function, we specify the exact amount of Dai we want to receive and send an approximate amount of ETH. Given that this function does not “pull” any tokens from your wallet, no additional token approval is necessary.

**buyAllAmountPayEth** function parameters are these:

- OasisDEX address (OTC)  
- DAI token address (DAI)
- buyAmt (uint256) - the amount that will be purchased
- wethToken (address) - address of WETH token

### Creating the calldata

Before executing the function to the proxy contract, you need to build the calldata with the function name and all its parameters. You can export all this calldata to an environment variable in the terminal.

**Set the buyAmt parameter to 3 Dai:**

`export buyAmt=$(seth --to-uint256 $(seth --to-wei 3 eth))`

‘eth’ in the `seth --to-wei 3 eth` command refers to the ETH conversion unit. It adds 18 zeros to 3. Converting it to the wei format.

**Set the calldata:**

`export calldata=$(seth calldata 'buyAllAmountPayEth(address,address,uint,address)' $OTC $DAI $buyAmt $WETH)`

### Executing the function

To execute the **buyAllAmountPayEth** function, you need to send a transaction to your proxy contract by calling the execute function and adding the Oasis Direct Proxy contract address and calldata as parameters. Depending on the function, you might send ETH as well. In our case, you are sending 0.05 ETH to the contract for purchasing Dai.

`seth send $MYPROXY 'execute(address, bytes memory)' $OASIS_DIRECT_PROXY $calldata --value $(seth --to-wei 0.05 eth)`

[This](https://kovan.etherscan.io/tx/0xd24d388f61b86d3a726df99231d71fae94e0b7c711a43b5f963ada5ba73cba6b) is an example of a successful transaction.  
If you look closely, you’ll notice that that the user sent more ETH than was necessary to the marketplace. For getting 3 Dai he paid 0.037974683544303797 ETH and the rest was returned back to his wallet. This is special to this marketplace function. You define the exact number of Dai you want to receive. Depending on the market liquidity, you might spend more or less ETH for the Dai. So, in your case he bought Dai at the ~ 79 ETH/DAI price.

As you observed, all this has been done through one transaction on the Ethereum blockchain. This leads to improved UX, and less transactions.

So, in order to interact with the OasisDEX protocol through the Oasis Direct Proxy functions you need to have your proxy contract setup through the proxy registry and execute the specific calldata according to your requirements.

## Summary

In this guide you have learned how to use your proxy contract to execute Oasis Direct Proxy actions on the OasisDEX protocol. Using a proxy contract can be beneficial for both the users and developers by limiting the amount of needed transactions, which results in a more seamless UX.

## Additional Resources

- Make sure to read the Oasis Direct Proxy Actions github [repo](https://github.com/makerdao/oasis-direct-proxy), as it explains in detail every function call.
- [OasisDEX Protocol](https://github.com/makerdao/maker-otc)

## Help

- If you need help reach out in the #dev channel in [https://chat.makerdao.com/channel/dev](https://chat.makerdao.com/channel/dev)
