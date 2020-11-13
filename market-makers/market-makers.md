# Market Makers

- [Market Makers](#market-makers)
  - [Prerequisites](#prerequisites)
  - [Market Maker Keeper repos](#market-maker-keeper-repos)
    - [Market Maker Keeper](#market-maker-keeper)
    - [Market Maker Stats](#market-maker-stats)
    - [Pymaker](#pymaker)
  - [Additional source code and developer docs](#additional-source-code-and-developer-docs)
  - [Need help](#need-help)

This document contains the necessary resources for partners to implement Keepers for Market Making.

## Prerequisites

This document assumes familiarity with Ethereum, and in-depth knowledge of the Maker platform.

## Market Maker Keeper repos

### [Market Maker Keeper](https://github.com/makerdao/market-maker-keeper)

This repository contains a set of Keepers that have been implemented to facilitate market making on a specific set of decentralized exchanges. While implemented specifically to work on specific exchanges, all Keepers in the repo share logic and operate similarly, as they all rely on creating a series of orders in preconfigured “bands”.

### [Market Maker Stats](https://github.com/makerdao/market-maker-stats)

Market Maker Stats provides a set of tools for visualizing market making data for a set of decentralized exchanges. These tools include:

- Trade chart tools for showing historical market prices and recent Keeper trades.
- Profitability calculation tools for calculating profitability of ETH/DAI or BTC/DAI keepers.
- Trade history dumping tools for exporting lists of recent trades.

### [Pymaker](https://github.com/makerdao/pymaker)

Pymaker is a Python API which provides endpoints to interact with the Maker smart contracts. It exposes most of the functionality of the Maker platform, but most importantly for this guide it can be used to create Keepers. This library can be used to create custom market making Keepers.

## Additional source code and developer docs

**More resources on Keepers:**

- <https://github.com/makerdao/developerguides/tree/master/keepers>

**Running a Keeper node:**

- [https://github.com/makerdao/keeper-node](https://github.com/makerdao/keeper-node)

**Current live Multi Collateral Dai:**

- Docs: [https://github.com/makerdao/dss/blob/master/DEVELOPING.md](https://github.com/makerdao/dss/blob/master/DEVELOPING.md)
- Wiki: [https://github.com/makerdao/dss/wiki](https://github.com/makerdao/dss/wiki)
- Source: [https://github.com/makerdao/dss](https://github.com/makerdao/dss)

**Single Collateral Dai credit system implementation:**

- Docs: [https://developer.makerdao.com/dai/1/api/](https://developer.makerdao.com/dai/1/api/)
- Docs: [https://github.com/makerdao/sai/blob/master/DEVELOPING.md](https://github.com/makerdao/sai/blob/master/DEVELOPING.md)
- Source: [https://github.com/makerdao/sai](https://github.com/makerdao/sai)

**DSToken (token standard for Maker tokens):**

- Docs: [https://dapp.tools/dappsys/ds-token.html](https://dapp.tools/dappsys/ds-token.html)
- Source: [https://github.com/dapphub/ds-token](https://github.com/dapphub/ds-token)

**Maker Protocol in general:**

- [Whitepaper](https://makerdao.com/whitepaper/)

## Need help

- Rocket chat - [#dev](https://chat.makerdao.com/channel/dev) channel
