---
title: Monitoring Collateral Types and Vaults
description: Learn how to monitor Maker Protocol State
parent: vaults
tags:
  - vaults
  - protocol state
  - ratios
  - collateral price
slug: monitoring-collateral-types-and-vaults
contentType: guides
root: false
---

# Monitoring Collateral Types and Vaults

Level: Intermediate  
Estimated Time: 45 minutes

- [Monitoring Collateral Types and Vaults](#monitoring-collateral-types-and-vaults)
  - [Overview](#overview)
  - [Learning objectives](#learning-objectives)
  - [Pre-requisites](#pre-requisites)
  - [Guide](#guide)
    - [Collateral Types](#collateral-types)
      - [Example](#example)
    - [Vaults](#vaults)
    - [Use Maker Protocol parameters for calculations](#use-maker-protocol-parameters-for-calculations)
  - [Summary](#summary)
  - [Troubleshooting](#troubleshooting)
  - [Next steps](#next-steps)
  - [Resources](#resources)

## Overview

Monitoring part of the Maker Protocol state is an important part of servicing users of the protocol, such as Vault owners. Proactive monitoring is recommended and has the potential to save Vault owners from liquidation and high stability fees. This guide will highlight the locations of relevant data as implemented in smart contract Solidity code, so it is up to the reader to choose which API is used to access that data. Some notable APIs are Dai.js and Pymaker; more generalized Web3 libraries can be used, though without the valuable utility functions that are exposed in the former two APIs. Moreover, because they abstract away much of the complexity of data transformation, we strongly recommend trying to work with [Dai.js](https://docs.makerdao.com/dai.js) or [Pymaker](https://docs.makerdao.com/pymaker) before attempting to read the state directly.

## Learning objectives

After going through this guide, you will gain a better understanding of:

- How to monitor the state and health of a particular Vault
- How to monitor relevant risk parameters

## Pre-requisites

[Maker Protocol 101](https://github.com/makerdao/developerguides/blob/master/mcd/mcd-101/mcd-101.md), especially:

- Vault basics.
- Governance Risk parameters.

## Guide

Mainnet addresses to contracts mentioned below can be found in the [latest release](https://changelog.makerdao.com/) of the Maker Protocol. To see the contract solidity code, go to etherscan.io, click on the `Contract` tab, and finally select the `Code` card. When reading numeric values, remember to account for their magnitudes. Of the fixed point integers:

- `wad` - 18 decimal places
- `ray` - 27 decimal places
- `rad` - 45 decimal places

### Collateral Types

Every [Collateral type](https://github.com/makerdao/developerguides/blob/kenton_dev/vault/vault-integration-guide/vault-integration-guide.md#collateral-types) state is stored in the `Ilk` data structure in the [Vat](https://github.com/makerdao/dss/blob/master/src/vat.sol), the central accounting contract of the Maker Protocol.

```solidity
struct Ilk {
    uint256 Art;   // Total Normalised Debt     [wad]
    uint256 rate;  // Accumulated Rates         [ray]
    uint256 spot;  // Price with Safety Margin  [ray]
    uint256 line;  // Debt Ceiling              [rad]
    uint256 dust;  // Urn Debt Floor            [rad]
}
```

The state of a particular `Ilk` can be found through the `ilks` mapping:

```solidity
mapping (bytes32 => Ilk)                       public ilks;
```

On the mapping, the first argument is a `bytes32` representation of the [collateral type](https://github.com/makerdao/developerguides/blob/kenton_dev/vault/vault-integration-guide/vault-integration-guide.md#collateral-types).
Once you can read the `Ilk` struct in the Vat, you have access to most of its risk parameters. The other important risk parameters, such as the stability fee, liquidation penalty, and liquidation ratio, can be found in similar `Ilk` structs in the [Jug](https://github.com/makerdao/dss/blob/master/src/jug.sol), [Cat](https://github.com/makerdao/dss/blob/master/src/cat.sol), and [Spot](https://github.com/makerdao/dss/blob/master/src/spot.sol) contracts, respectively. Similar to the Vat, each contract has their own `ilks` mapping.

In the Jug:

```solidity
struct Ilk {
    uint256 duty;  // Collateral-specific, per-second stability fee contribution [ray]
    uint256  rho;  // Time of last drip [unix epoch time]
}
```

In the Cat:

```solidity
struct Ilk {
    address flip;  // Liquidator
    uint256 chop;  // Liquidation Penalty   [ray]
    uint256 lump;  // Liquidation Quantity  [wad]
}
```

In the Spot:

```solidity
struct Ilk {
    PipLike pip;  // Price Feed
    uint256 mat;  // Liquidation ratio [ray]
}
```

#### Example

Here's a non-exhaustive example of reading common risk parameters of a collateral type within the Maker Protocol. Data location is shown in pseudocode and follows this format: `Contract.function(...).variable`.

```bash
Collateral Type = Ilk = bytes32(`ETH-A`) = 0x4554482d41000000000000000000000000000000000000000000000000000000
```

The Maker Protocol pulls recent price data from the [Oracle Security Module (OSM)](https://docs.makerdao.com/smart-contract-modules/oracle-module) to properly value the assets it accepts as collateral. The sole purpose of the OSM is to delay price feed updates and protect the system from oracle attacks. Thus, the price used to evaluate a Vault’s state is delayed by a predetermined amount of time (e.g. 1 hour). Moreover, as was designed, the Liquidation Ratio, which is the minimum Vault Collateralization Ratio before liquidation, is baked into the price and stored in the Vat. As a result, the Collateral Price is delayed, has a “safety margin” that’s in size to the Liquidation Ratio, and is used directly when evaluating a Vault’s health.

```bash
Delayed Collateral Price price w/ safety margin = Vat.ilks(Ilk).spot = 150 x 10^27 ($150)

Liquidation Ratio = Spot.ilks(Ilk).mat = 1.50 x 10^27 (150%)

Delayed Collateral Price = Delayed Collateral Price w/ safety margin * Liquidation Ratio = 150 * 1.5 = 225 ETH / USD

Liquidation Penalty = Cat.ilks(Ilk).chop = 1.13 * 10^27 = 13%
```

All collateral types are charged a stability fee, which is the combination of two fee contributions: a collateral-specific fee and a global fee. The combination of the two results in a “debt multiplier” that when multiplied by a Vault’s normalized internal Dai (`urn.art`) gives the total amount of debt at any time. Each collateral type has a debt multiplier (`ilk.rate`) that continuously, but irregularly, updates in the Vat. This is one of the more important, fundamental mechanisms within the Maker Protocol, so if you have time, we recommend reading more on the [Rates Module](https://docs.makerdao.com/smart-contract-modules/rates-module).

```bash
Global, per-second stability fee contribution = Jug.base = 0.0000 x 10^27

Collateral-specific, per-second stability fee contribution  = Jug.ilks(Ilk).duty = 1.000000001847694957439350562 x 10^27
```

Although the total stability fee is the sum of the global and collateral specific fee, the latter (known as "duty") is currently the only contributing factor to the fee, as the global fee is set to 0.

```bash
Stability Fee per second = Global + Collateral-specific, per second stability fee contributions = 0.0000 x 10^27 + 1.000000001847694957439350562 x 10^27

Stability Fee per year = Stability Fee per second ^ 31536000 seconds in a year (365 days x 24 hours x 60 minutes x 60 seconds) = 1.06 or 6% per year
```

### Vaults

Similar to the Ilk, every Vault state is stored in the `Urn` data structure in the [Vat](https://github.com/makerdao/dss/blob/master/src/vat.sol).

```bash
struct Urn {
    uint256 ink;   // Locked Collateral  [wad]
    uint256 art;   // Normalised Debt    [wad]
}
```

Acting as an alias to Vault state, a particular `Urn` state can be found through the `urns` mapping:

```bash
mapping (bytes32 => mapping (address => Urn )) public urns;
```

On the mapping, the first argument is a `bytes32` representation of the [collateral type](https://github.com/makerdao/developerguides/blob/kenton_dev/vault/vault-integration-guide/vault-integration-guide.md#collateral-types), while the second argument is the user's Ethereum address.

You may notice that an Ethereum address only has access to a single `Urn` for each `Ilk` Collateral type. The CDP-Manager exists to circumvent this constraint. The [CDP-Manager](https://github.com/makerdao/dss-cdp-manager/blob/master/src/DssCdpManager.sol) manages a list of `UrnHandlers`, which is a simple contract that has a single goal of being owned by an Ethereum address and holds ownership of an `Urn`. In other words, with the CDP-Manager, one could own multiple `UrnHandlers` and thus `open(...)` multiple `urns` for each `Ilk`. Although CDP-Manager can be used manually, most interactions are conducted through a [DSProxy](https://github.com/makerdao/developerguides/blob/master/devtools/working-with-dsproxy/working-with-dsproxy.md), a proxy contract used to execute atomic transactions, and [DssProxyActions](https://github.com/makerdao/dss-cdp-manager), an atomic transaction library.

### Use Maker Protocol parameters for calculations

In order to calculate collateralization ratios for Vaults in the Maker Protocol, it is important to take the variable `par`, also known as the reference price of Dai, into consideration. Failure to do so, might result in incorrect calculation of collateralization ratios, which can result in unwanted liquidations.

To calculate the collateralization ratio of a collateral type (ilk), use the following formula:

`Collateralization Ratio = Vat.urn.ink * Vat.ilk.spot * Spot.ilk.mat / (Vat.urn.art * Vat.ilk.rate)`

`Vat`: Vault database contract

`Spot`: Collateral price contract (Interface between price oracles and core Maker contracts)

`urn`: Vault

`ink`: Amount of collateral tokens

`ilk`: Collateral type

`mat`: Liquidation ratio

`spot`: collateral price with safety margin, i.e. the maximum stablecoin allowed per unit of collateral. Uses par internally.

`art`: Normalized stablecoin debt

`rate`: Stability fee accumulator - (urn.art*ilk.rate = Dai debt for a Vault)

Note the difference between Spot the contract, and spot the variable.

Since `par` is being used in the [Spot.poke()](https://github.com/makerdao/dss/blob/master/src/spot.sol#L96) function, it will affect the `spot` value of the collateral type. See spot variable in the poke() function below.

```solidity
function poke(bytes32 ilk) external {
        (bytes32 val, bool has) = ilks[ilk].pip.peek();
        uint256 spot = has ? rdiv(rdiv(mul(uint(val), 10 ** 9), par), ilks[ilk].mat) : 0;
        vat.file(ilk, "spot", spot);
        emit Poke(ilk, val, spot);
    }
```

Since `spot` takes `par` into consideration, the formula for collateralization ratio above will work, even if `par` changes.

In order to ensure that your integration calculates the same collateralization ratio as the Maker Protocol, only parameters used in the Vat and Spot contracts should be utilized.

## Summary

In this guide, you were introduced to the locations of important data structures within the Maker Protocol, ranging from collateral types and their risk parameters to the state of Vaults.

## Troubleshooting

Run into an issue that’s not covered in this guide? Please find our contact information at the end of this guide, and we’ll add it above or to this section.

## Next steps

[Vault Integration Guide](https://github.com/makerdao/developerguides/blob/master/vault/vault-integration-guide/vault-integration-guide.md)

## Resources

[Rates Module Documentation](https://docs.makerdao.com/smart-contract-modules/rates-module)
[Guide: Intro to Rates Mechanism in the Maker Protocol](https://github.com/makerdao/developerguides/blob/master/mcd/intro-rate-mechanism/intro-rate-mechanism.md)
[Example: Compounding rates](https://docs.google.com/spreadsheets/d/1fDwooo9tVftgd9Q7dVbd857Ue8demLVukFnsakl8MHE/edit?usp=sharing)

- Rocket chat - [#dev](https://chat.makerdao.com/channel/dev) channel
