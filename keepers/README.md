# Keepers

- [Keepers](#keepers)
  - [Prerequisites](#prerequisites)
  - [Multi Collateral Dai (MCD) Keepers](#multi-collateral-dai-mcd-keepers)
    - [Auction Keeper](#auction-keeper)
    - [Dockerized Auction Keeper](#dockerized-auction-keeper)
    - [Chief Keeper](#chief-keeper)
    - [Cage Keeper](#cage-keeper)
    - [Pymaker](#pymaker)
  - [OasisDex Keepers](#oasisdex-keepers)
    - [Simple Arbitrage Keeper](#simple-arbitrage-keeper)
  - [Additional source code and developer docs](#additional-source-code-and-developer-docs)
  - [Need help](#need-help)

This document contains the necessary resources to implement Keepers.

## Prerequisites

This document assumes familiarity with Ethereum, and in-depth knowledge of the Maker Protocol.

## Maker Protocol Keepers

### [Auction Keeper](https://github.com/makerdao/auction-keeper)

The `auction-keeper` enables automatic interaction with flip auctions, flap auctions, and flop auctions. You can read more about the different auction types [here](https://docs.makerdao.com/auctions/the-auctions-of-the-maker-protocol).

This is automated by specifying bidding models that define the decision making process, such as when to bid, how high to bid etc.

### [Dockerized Auction Keeper](https://github.com/makerdao/dockerized-auction-keeper)

The `dockerized-auction-keeper` contains a preconfigured `auction-keeper` that follows a simple  pricing model. With docker as the only prerequisite, this instance is well-suited for first-time auction keeper operators.

### [Chief Keeper](https://github.com/makerdao/chief-keeper)

The `chief-keeper` monitors and interacts with [DSChief](https://github.com/dapphub/ds-chief) and DSSSpells, which is the executive voting contract and a type of proposal object of the [Maker Protocol](https://github.com/makerdao/dss).

Its purpose is to lift the hat in DSChief as well as streamline executive actions.

### [Cage Keeper](https://github.com/makerdao/cage-keeper)

The `cage-keeper` is used to help facilitate [Emergency Shutdown](https://docs.makerdao.com/smart-contract-modules/shutdown/the-emergency-shutdown-process-for-multi-collateral-dai-mcd) of the [Maker Protocol](https://github.com/makerdao/dss).

### [Pymaker](https://github.com/makerdao/pymaker)

Pymaker is a Python API which provides endpoints to interact with the Maker Protocol smart contracts. It exposes most of the functionality of the Maker Protocol, but most importantly for this guide it can be used to create Keepers.

## OasisDex Keepers

### [Simple Arbitrage Keeper](https://github.com/makerdao/simple-arbitrage-keeper)

The Simple Arbitrage Keeper executes atomic multi-trade transactions between OasisDEX and Uniswap.

## Additional source code and developer docs

**Running a keeper node:**

- [Infrastructure required for an auction keeper (and most others)](https://github.com/makerdao/auction-keeper#infrastructure)

**Current Dai credit system implementation (Multi Collateral Dai):**

- Docs: [https://docs.makerdao.com/](https://docs.makerdao.com/)

- Source: [https://github.com/makerdao/dss](https://github.com/makerdao/dss)

**Single Collateral Dai:**

- Docs: [https://github.com/makerdao/sai/blob/master/DEVELOPING.md](https://github.com/makerdao/sai/blob/master/DEVELOPING.md)

- Source: [https://github.com/makerdao/sai](https://github.com/makerdao/sai)

**Python API:**

- Docs/source: [https://github.com/makerdao/pymaker](https://github.com/makerdao/pymaker)

**Maker platform in general:**

- [Whitepaper](https://makerdao.com/whitepaper/)

## Need help

- Rocket chat - [#dev](https://chat.makerdao.com/channel/dev) channel
