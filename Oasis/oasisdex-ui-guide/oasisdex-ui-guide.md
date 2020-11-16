
# OasisDEX UI Building Guide

Level: Intermediate

Estimated Time: 45 minutes

## Overview

As a complement to the OasisDEX Protocol Taker Guide and Maker Guide, this guide covers how you can integrate common OasisDEX Protocol functions in a UI.

The OasisDEX protocol can easily be integrated into a user interface using common frameworks. This guide goes through the primary components of a trading page, and explains how to build them using the OasisDEX protocol.

Examples are provided for every component, and the reader can use them in its own integration. For reference, we provide a working exchange page.


## Learning Objectives

-   Familiarize yourself with the OasisDEX contracts typically used for user interfaces.
    
-   Learn about optimization strategies.
 

## Prerequisites

-   You will need a [high-level understanding of the OasisDEX protocol](https://oasisdex.com/docs/guides/introduction#high-level-overview).
    
-   Knowledge of Dai.js
    
-   Experience with the React framework.
    

## Guide

### Regarding the examples

All the examples in this guide are built using [next-daijs-dai-ui-example](https://github.com/makerdao/nextjs-daijs-dai-ui-example), a boilerplate package that bundles Next.js with the Dai.js and [dai-ui](https://github.com/makerdao/dai-ui/) libraries. This allows the quick creation of a web application that interacts with the Maker Protocol and other Ethereum smart contracts.

Links to a [full working example](https://github.com/makerdao/simpledex-ui-example) of a simple DEX based on OasisDEX are included throughout the guide. This DEX allows only the trading of WETH and DAI, but could be easily expanded, which is left as an exercise to the reader.  

Typical DEX have the following components:

-   Account balances
    
-   Order book
    
-   Active orders
    
Our example has a single page, with a few individual components

-   pages/index.js
    
-   components/Balances.js
    
-   components/Wrap.js
    
-   components/Orders.js
    
-   components/MyOrders.js  

The SimpleDEX example that we reference lacks several features one would expect from a production DEX, like order validation and performance optimization, and has not been extensively tested. This guide makes some suggestions on potential improvements.

### Setting up Dai.js
Dai.js is a Javascript library that makes it easy to build applications on top of the Maker Protocol. Setting up Dai.js is relatively simple, and could be done with [a few lines of code](https://docs.makerdao.com/dai.js/getting-started), or by using a [boilerplate example](https://github.com/makerdao/nextjs-daijs-dai-ui-example).  

Dai.js supports browser wallets like Metamask and Brave and plugins are available for the support of several hardware and mobile wallets. Integrating Dai.js can considerably speed up the development of a Dapp.

### Account Balances

DEX users have to be able to know the current balance of the tokens they are trading, and ensure that ERC20 approval has been set.

ERC20 and ETH balance can be obtained by using [getBalance()](https://web3js.readthedocs.io/en/v1.2.0/web3-eth.html#getbalance) from web3.js or with balance() in Dai.js.

`maker.service('token').getToken(token).balance()`

The `next-daijs-dai-ui-example` boilerplate provides a convenient `fetchTokenBalance` that calls `getToken` which simplify the implementation:

```
const { maker, fetchTokenBalance  } = useMaker();
const ethBal = await fetchTokenBalance('ETH');
const wethBal = await fetchTokenBalance('WETH');
const daiBal = await fetchTokenBalance('DAI');
```
See it in [context](https://github.com/makerdao/simpledex-ui-example/blob/5ea11ad88a6b74fe71341f6f88b4398ad94e553a/components/Balances.js#L22).

### Approve an ERC20 for transaction

A particularity of ERC20 is that the token owner must authorize individual contracts in a separate transaction. DEX and Dapps often request users to allow an unlimited transfer, to simplify interactions and reduce the number of transactions. Again, Dai.js makes this simple using a built-in function:

`maker.service('token').getToken(token).approveUnlimited(MatchingMarket);`

See it in [context](https://github.com/makerdao/simpledex-ui-example/blob/5ea11ad88a6b74fe71341f6f88b4398ad94e553a/components/Balances.js#L17).

### Wrapping

OasisDEX works only with ERC20, which requires the native Ether to be wrapped inside a ERC20 contract. Dai.js makes this very simple with integrated `deposit` and `withdraw` functions:

`maker.service('token').getToken('WETH').deposit(wrapAmnt);`

See it in [context](https://github.com/makerdao/simpledex-ui-example/blob/5ea11ad88a6b74fe71341f6f88b4398ad94e553a/components/Wrap.js#L12).

## Listing the orders

Normally, querying offers directly OasisDEX order book would require making several calls to the contract to extract all the active orders. An alternative would be to cache this information on the server side, but we can also use a support contract to save on the number of queries.

The `MakerOtcSupportsMethods` contract provides an easy way to list all the pending orders in a single call, considerably speeding the request.

The `getOffers` method returns all the current orders using several arrays.
```
const supportMethods = maker.service('web3').web3Contract(abi,MakerOtcSupportMethods);
const offers = await supportMethods.methods.getOffers(MatchingMarket,props.give,props.get).call();
```
  
  

`offers` is an Object that contains:

-   `ids` (Array) the ids of the first 100 offers
    
-   `payAmts` (Array): Number of tokens the order offers to pay
    
-   `buyAmts` (Array): Number of tokens the orders want in exchange
    
-   `owners` (Array): Address of the owner of the offer
    
-   `timestamps` (Array): Date and time of the offer
    
These can easily get parsed in JavaScript, using a function similar to this one:

`const tableOffers = offers.ids.map( (v, i) => ( {id:v, payAmts: offers.payAmts[i], buyAmts:offers.buyAmts[i]} ) ).filter(v=>(v.id!=='0'));`

Here, `tableOffers` is an Array of objects, each with an `id`, `payAmts`, and `buyAmts` properties.

See it in [context](https://github.com/makerdao/simpledex-ui-example/blob/5ea11ad88a6b74fe71341f6f88b4398ad94e553a/components/Orders.js#L24).

## Posting an order

A transaction has to be generated to add an offer to the order book. It has to contain:

-   `pay_amt`: Number of tokens paid, in wei (e.g. amount multiplied by 1E18).
    
-   `pay_gem`: Address of the token being paid
    
-   `buy_amt`: Number of token to get in exchange, in wei
    
-   `buy_gem`: Address of the token to get
    

Note that the amounts must be provided as a BigNumber, wei, which can be done by multiplying the amounts by 10^18. Due to BN.js limitations, and the way that JavaScript represents large numbers, it is preferable to convert the amount to BN.js before converting to wei.

```
const matchingMarketContract = maker.service('web3').web3Contract(matchingMarketAbi,matchingMarketAddr);
const toBN = maker.service('web3')._web3.utils.toBN;

matchingMarketContract.methods.offer(
toBN(payAmnt*1E9).mul(toBN(1E9)),
props.give,
toBN(getAmnt*1E9).mul(toBN(1E9)),
props.get,
0,
true).send({from:maker.currentAddress()});
```
See it in [context](https://github.com/makerdao/simpledex-ui-example/blob/5ea11ad88a6b74fe71341f6f88b4398ad94e553a/components/Orders.js#L49).

It may be advisable to perform some verification on behalf of the user before posting the bid transaction to protect the user:

-   You may post a warning if the effective price of the bid is much higher or lower than the mid price.   

-   If the bid overlaps an existing bid, posting the bid will result in an immediate transaction. Make sure that this is well represented to the user.
    

## Taking an order

Taking an order from the order book is done by passing the order `id` and the `amount`. The `amount` parameter is used to request a partial fulfillment of the bid.

```
const matchingMarketContract = maker.service('web3').web3Contract(matchingMarketAbi,matchingMarketAddr);

matchingMarketContract.methods.buy(
id,
maker.service('web3')._web3.utils.toBN(amount),
).send({from:maker.currentAddress()});
```
See it in [context](https://github.com/makerdao/simpledex-ui-example/blob/5ea11ad88a6b74fe71341f6f88b4398ad94e553a/components/Orders.js#L62).

## Cancelling an order

An order made by the user is cancelled by providing its order `id`.
```
const matchingMarketContract = maker.service('web3').web3Contract(matchingMarketAbi,matchingMarketAddr);

matchingMarketContract.methods.cancel(
id).send({from:maker.currentAddress()});
```
See it in [context](https://github.com/makerdao/simpledex-ui-example/blob/5ea11ad88a6b74fe71341f6f88b4398ad94e553a/components/MyOrders.js#L56).

## Performance considerations

Building a DEX interface that interfaces with an Ethereum node presents several performance challenges. A large number of JSON RPC calls might be required, which can severely slow down the page loading time and responsiveness, while being potentially expensive if use a hosted Ethereum node provider. Several strategies are available to reduce the number of these queries and improve the user experience.

### Bundling queries

Care must be taken to parallelize the queries to accelerate page loads while preventing sending too many queries at the same time, which could be rate-limited by a node provider.

One approach is to use a specialized helper contract, like [MakerOtcSupportsMethods](https://github.com/daifoundation/maker-otc-support-methods), that turns several queries into a single one. Its function is to return several offers from the order book in a single call and avoid hundreds of back and forth between the web browser and the Ethereum node provider.

For a more general solution that doesn’t require deploying a smart contract, consider using [multicall](https://github.com/makerdao/multicall) and its [JavaScript library](https://github.com/makerdao/multicall.js) that allow bundling several contract calls into a single JSON RPC request.

### Fetch vs. subscribe

Design must take into consideration that order book state changes only on block changes, hence polling for data change between the blocks will be wasteful. Polling also introduces a sampling delay if its frequency is too small.

A better solution would be to subscribe to events corresponding to the mining of new blocks, and query only at that moment. To avoid querying stale data, the block number or hash of the new block should be specified in the query to avoid getting stale information, as not all nodes receive the block at the same time. The ideal solution is to subscribe to the OasisDEX events, like `LogTrade`, `LogMake`, `LogTake` and `LogKill` to dynamically update the local representation of the order book without requiring constant polling.

Not all state changes necessarily have matching events, and sometimes the events might not contain all the necessary information, so polling is difficult to completely eliminate, but it can be limited dramatically with the right design.

### Server

Ethereum Dapps usually aim to run independently from centralized servers, and have all back-end communication being directed to Ethereum nodes. This design goal can make performance challenging, and the above optimizations (subscriptions, helper contracts) may not be suitable for every application.

Using additional server components might optimize some aspect of a DEX, for example

-   Have a server maintain a representation of the order book in memory that can be requested in a single call by clients. After the initial load, clients can subscribe to on-chain events to an Ethereum node for updates.
    
-   Use an Ethereum querying layer, like VulcanizeDB or TheGraph, to run queries that would require the processing of a large amount of data, for example, average pricing information.
    
In all cases, it is preferable to make the use of servers optional. Basic, or performance-degraded functionality should still be available if the servers are not reachable and the client can only interact with Ethereum nodes.

## Summary

Building dapps for Ethereum can be challenging, and building a good DEX user experience is no exception. This guide presented the basic building blocks of a working DEX UI, but for the best user experience, developers should invest the effort to design a good interface, and take great care at optimizing performance.

## Ressources

-   [https://oasisdex.com/docs/guides/market-taker](https://oasisdex.com/docs/guides/market-taker)
    
-   [https://oasisdex.com/docs/guides/market-maker](https://oasisdex.com/docs/guides/market-maker)
    
-   [https://github.com/daifoundation/maker-otc-support-methods](https://github.com/daifoundation/maker-otc-support-methods)