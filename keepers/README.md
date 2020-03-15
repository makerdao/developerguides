# Keepers
This document contains the necessary resources for partners to implement Keepers - programs that automatically monitor and interact with CDPs and the Dai Credit System.

## Prerequisites

This document assumes familiarity with Ethereum, and in-depth knowledge of the Maker platform.

## Multi Collateral Dai (MCD) Keepers

### [Auction Keeper](https://github.com/makerdao/auction-keeper)

The Auction Keeper program enables automatic interaction with CDP auctions - more specifically flip (collateral sale), flap (MKR buy and burn), and flop (MKR minting). You can read more about the different auction types [here](https://docs.makerdao.com/auctions/the-auctions-of-the-maker-protocol).

This is automated by specifying bidding models that define the decision making process, such as when to bid, how high to bid etc.

## Single Collateral Dai (SCD) Keepers

For the current implementation of Dai (SCD) you can utilize the following reference keepers for automation of interactions with the Dai Credit System.

### [Pymaker](https://github.com/makerdao/pymaker)

Pymaker is a Python API which provides endpoints to interact with the Maker smart contracts. It exposes most of the functionality of the Maker platform, but most importantly for this guide it can be used to create Keepers - programs that monitor CDPs, and liquidates undercollateralized positions to buy the collateral for arbitraging opportunities.

Based on this, a series of reference Keepers have been developed to carry out specific operations in the Maker system.

### [Bite Keeper](https://github.com/makerdao/bite-keeper)

The Bite Keeper is a very simple implementation which continuously monitors the Dai Credit System for unsafe CDPs, and executes the bite function (liquidation) the moment they become unsafe. This Keeper does not guarantee that you are able to buy the bitten collateral, and thus does not take into account profitability of biting a certain CDP in terms of gas price vs buying collateral.

### [Arbitrage Keeper](https://github.com/makerdao/arbitrage-keeper)

The Arbitrage Keeper monitors arbitrage opportunities in the Dai Credit System by exchanging between the tokens of the system: DAI, WETH and PETH.

### [CDP Keeper](https://github.com/makerdao/cdp-keeper)

The CDP Keeper can be used to automatically manage CDPs. Features include:

-   Automatic top up of collateral, if collateral value decreases, and the CDP approaches the liquidation ratio

-   Wiping debt instead of top-up

-   Managing Dai volume

## OasisDex Keepers

### [Simple Arbitrage Keeper](https://github.com/makerdao/simple-arbitrage-keeper)

The Simple Arbitrage Keeper profits from executing atomic multi-trade transactions between OasisDex and Uniswap.


## Additional source code and developer docs

**Running a keeper node**

-   [https://github.com/makerdao/keeper-node](https://github.com/makerdao/keeper-node)


**Multi Collateral Dai**

-   Docs: [https://github.com/makerdao/dss/blob/master/DEVELOPING.md](https://github.com/makerdao/dss/blob/master/DEVELOPING.md)

-   Wiki: [https://github.com/makerdao/dss/wiki](https://github.com/makerdao/dss/wiki)

-   Source: [https://github.com/makerdao/dss](https://github.com/makerdao/dss)


**Current Dai credit system implementation (Single Collateral Dai)**

-   Docs: [https://developer.makerdao.com/dai/1/api/](https://developer.makerdao.com/dai/1/api/)

-   Docs: [https://github.com/makerdao/sai/blob/master/DEVELOPING.md](https://github.com/makerdao/sai/blob/master/DEVELOPING.md)

-   Source: [https://github.com/makerdao/sai](https://github.com/makerdao/sai)


**Python API**

-   Docs/source: [https://github.com/makerdao/pymaker](https://github.com/makerdao/pymaker)


**Maker platform in general**

-   [Whitepaper](https://makerdao.com/whitepaper/)


## Need help?

Contact [integrate@makerdao.com](mailto:integrate@makerdao.com) or #dev channel on chat.makerdao.com
