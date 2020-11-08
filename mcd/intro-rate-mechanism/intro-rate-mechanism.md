---
title: Intro to the Rate Mechanism
description: Understand how the Maker Protocol Rate Mechanism works
parent: mcd
tags:
  - mcd
  - Rate Mechanism
  - Stability Fee
  - Dai Savings Rate (DSR)
slug: intro-to-the-rate-mechanism
contentType: guides
root: false
---

# Intro to the Rate mechanism

**Level**: Intermediate

**Estimated Time**: 45 - 60 minutes

- [Intro to the Rate mechanism](#intro-to-the-rate-mechanism)
  - [Overview](#overview)
  - [Learning Objectives](#learning-objectives)
  - [Pre-requisites](#pre-requisites)
  - [Guide](#guide)
    - [Compound Interest](#compound-interest)
    - [Math](#math)
      - [Fixed Point Numbers](#fixed-point-numbers)
      - [Exponentiation](#exponentiation)
    - [Rate Value](#rate-value)
    - [Rate Accumulator](#rate-accumulator)
    - [Tracking Balances](#tracking-balances)
    - [Multi Collateral Dai](#multi-collateral-dai)
      - [Stability Fees](#stability-fees)
      - [Dai Savings Rate](#dai-savings-rate)
    - [Single Collateral Dai](#single-collateral-dai)
  - [Troubleshooting](#troubleshooting)
  - [Summary](#summary)
  - [Help](#help)

## Overview

Maker governance votes on stability fee changes using annual rates, ex: `5.5%`, but the rate mechanism doesn't rely on annual rates in any form to track the interest accrued in Maker Vaults. As a dapp developer you won't be able to find this number stored in the smart contracts but instead you will run into a number like `1000000001697766583380253701`. In this guide, we'll help you understand how the stored rate value corresponds to the annual number, how multiple changes in both rates and debt levels over the lifetime of a Vault are accounted for in the Maker protocol, and how the rate mechanism is used for tracking both stability fees and the Dai Savings Rate.

## Learning Objectives

After going through this guide you will get a better understanding of,

- Rate Mechanism
- Stability fee calculation
- Dai Savings Rate calculation

## Pre-requisites

You will need a good understanding of these concepts to be able to work through this guide,

- [MCD 101](https://github.com/makerdao/developerguides/blob/master/mcd/mcd-101/mcd-101.md).
- Solidity.

## Guide

### Compound Interest

Investopedia defines compound interest as- “Compound interest (or compounding interest) is interest calculated on the initial principal, which also includes all of the accumulated interest of previous periods of a deposit or loan. Thought to have originated in 17th century Italy, compound interest can be thought of as “interest on interest,” and will make a sum grow at a faster rate than simple interest, which is calculated only on the principal amount.”

The formula for calculating compound interest is:

Compound Interest = Total amount of Principal and Interest in future (or Future Value) less Principal amount at present (or Present Value)

= $[P (1 + i)^n ] - P$

(Where P = Principal, i = nominal annual interest rate in percentage terms, and n = number of compounding periods.)

Please read this article to get a quick refresher on how compound interest works, [https://www.mathsisfun.com/money/compound-interest.html](https://www.mathsisfun.com/money/compound-interest.html)

### Math

#### Fixed Point Numbers

Three different types of fixed point decimal numbers are used throughout the Maker protocol,

- a `wad` type (18 decimal fixed point number) is used to track ERC20 token [balances](https://github.com/makerdao/dss/blob/17be7db1c663d8069308c6b78fa5c5f9d71134a3/src/dai.sol#L82).
- a higher precision `ray` type (27 decimal fixed point number) is used to track [interest rates](https://github.com/makerdao/dss/blob/17be7db1c663d8069308c6b78fa5c5f9d71134a3/src/vat.sol#L37) accrued in Vaults and the Dai Savings Rate contract over time.
- a `rad` type(45 decimal fixed point number) is used to store all internal dai [balances](https://github.com/makerdao/dss/blob/17be7db1c663d8069308c6b78fa5c5f9d71134a3/src/vat.sol#L50) within the Vat contract. This is to ensure no precision is lost when storing the result of a `wad` and `ray` multiplication (18 + 27 = 45).

All these numbers are stored as a `uint256` type within smart contracts and it's easy to miss their fixed-point decimal number type when performing a multiplication if care is not taken. Regular integer multiplication functions available in Solidity add orders of magnitude when applied to these fixed-point decimal numbers.

This issue is illustrated very clearly in the documentation of the [DSMath](http://github.com/dapphub/ds-math) library which implements math functions for wad and ray numbers.

```text
1.1 * 2.2 == 2.42

//Regular integer arithmetic adds orders of magnitude:
110 * 220 == 24200

// Wad arithmetic does not add orders of magnitude:
wmul(1.1 ether, 2.2 ether) == 2.42 ether
```

You also have to be careful when using external safe math libraries whose functions may not deal with these number types correctly. All the Maker protocol smart contracts that use these number types have special math functions (usually the multiplication operation) to calculate the correct result.

#### Exponentiation

Exponentiation operation is used to calculate the compound interest accrued over a number of time periods. The [rpow](<https://github.com/makerdao/dss/blob/effdda3657f71fd6efc3465dc661b375d1bacc3e/src/jug.sol#L40>) function implements exponentiation in Solidity and is used to raise a `ray` to the n^th power and return a new `ray` with the correct precision.

### Rate Value

The Maker protocol does not impose any restrictions on the duration a Vault should be open which allows a user to open or close their Vault anytime as long as it stays over-collateralized and safe. The stability fee rate set by Maker governance changes often and it is common for a single Vault to be charged different rates while its open.

To precisely account for the stability fees accrued over the lifetime of a Vault with these constraints, a time period of 1 second is used for all compound interest calculations in the Maker protocol which means that all the rates stored in the system are also for a second instead of a year.

Let's fire up a Python console and enter the following commands to calculate the annual rate that corresponds to the per-second rate stored here in the [fee](https://etherscan.io/address/0x448a5065aebb8e423f0896e6c5d525c040f59af3#readContract) variable. Let's use `31536000` as the number of seconds in a year and add a decimal point for the rate input.

```python
$python
>>> principal=1
>>> rate=1.000000001697766583380253701
>>> seconds=31536000
>>> principal*(rate**seconds)-principal
0.05500000035258168
>>> 0.05500000035258168*100
5.500000035258168
>>>
```

We can now see that the stored rate compounds to a value of `5.5%` over a year.

### Rate Accumulator

Calculating the stability fee owed by the Vault owner would be a simple calculation if the rate applied to it never changes during its lifetime. Since rates are updated frequently in the system and Vaults need to be charged fees accurately, an additional rate accumulator variable is used to track the fee owed.

A function, typically named `drip` in various contracts, is executed to update the value of a rate accumulator over time. It reads the time elapsed in seconds since the last rate accumulator update, and the current rate value stored to calculate the new increased value.

Rate accumulators are able to track the total fee owed by a Vault taking into account all the previous rate changes but the history of the rate changes themselves and the stability fees owed during the previous periods by the Vault are only available through event logs and cannot be retrieved from the smart contract.

### Tracking Balances

Maintaining a rate accumulator to accurately track a balance that increases over time requires frequent drip calls. The Maker protocol makes this process efficient by using a shared rate accumulator to track balances for all Vaults of the same collateral type.

This requires any user balance tied to a rate to be normalized before its stored in lieu of the actual balance. The actual balance at any point in time can be computed by multiplying a normalized balance with the current value of the shared rate accumulator.

Ex: A user deposits collateral and draws `100` dai in debt from a Vault and the rate accumulator of the collateral type currently has the value `1.00083`.

Dividing the actual balance 100 by current the value of the rate accumulator which gives us the result `99.917068832868719`. This is now stored as the normalized balance which will initialize the Vault debt with the principal amount. As the shared rate accumulator continues to increase when `drip` is executed in the future, the debt balance of this Vault will also increase.

Now that we've understood the rate mechanism used by the Maker protocol to maintain user balances that change over time based on a rate, we'll see what the rate mechanism is used for in both [Multi-Collateral Dai](https://github.com/makerdao/dss) and [Single Collateral Dai](https://github.com/makerdao/sai).

### Multi Collateral Dai

Rate mechanisms are used in Multi Collateral Dai (MCD) for maintaining stability fee balances of Vaults and the Dai Savings Rate (DSR) balances of users who've locked dai in the DSR contract.

#### Stability Fees

Vaults with outstanding debt are charged a stability fee by the Maker protocol. The accounting for stability fees: tracking rates, and rate accumulators for all collateral types, are done in the [Jug](https://github.com/makerdao/dss/blob/master/src/jug.sol) and [Vat](https://github.com/makerdao/dss/blob/master/src/vat.sol) contracts. All Vaults in the system are charged the [base](https://github.com/makerdao/dss/blob/17be7db1c663d8069308c6b78fa5c5f9d71134a3/src/jug.sol#L31) rate equally. Each collateral type is charged an additional [duty](https://github.com/makerdao/dss/blob/17be7db1c663d8069308c6b78fa5c5f9d71134a3/src/jug.sol#L24) rate which is called the risk premium. Both the rates `base` and `duty` are accumulated together in a single rate accumulator [rate](https://github.com/makerdao/dss/blob/17be7db1c663d8069308c6b78fa5c5f9d71134a3/src/vat.sol#L37) for each collateral type in the `Vat` contract when [drip](https://github.com/makerdao/dss/blob/17be7db1c663d8069308c6b78fa5c5f9d71134a3/src/jug.sol#L100) is executed for the collateral type.

The debt of a Vault can be calculated anytime by multiplying `art` which is the normalized debt value and `rate` of the collateral type, both stored in the Vat contract. Every time `drip` is executed it increases the value of the rate accumulator which results in additional debt recorded for all Vaults of the collateral type. The dai generated by increasing the debt of all Vaults is collected as surplus first in the [Vow](https://github.com/makerdao/dss/blob/master/src/vow.sol) contract which kicks off a [surplus auction](https://github.com/makerdao/dss/blob/17be7db1c663d8069308c6b78fa5c5f9d71134a3/src/vow.sol#L130) `flap` later once the surplus exceeds a certain threshold. The rate mechanism thus allows the system to continuously collect stability fees from Vaults every block.

Normalized debt values are also maintained for the [total debt](https://github.com/makerdao/dss/blob/17be7db1c663d8069308c6b78fa5c5f9d71134a3/src/vat.sol#L36) of a collateral type `Art` and multiplying it with the same rate accumulator `rate` of the collateral type will give the total debt issued.

#### Dai Savings Rate

MCD introduces a new mechanism which pays dai holders additional dai over time based on a rate called the Dai Savings Rate (DSR). This is a rate with no additional risk because the dai is not lent again to other users. Maker governance uses this rate to increase demand by making it attractive for users to purchase and hold dai.

The DSR contract [Pot](https://github.com/makerdao/dss/blob/master/src/pot.sol) uses the same rate mechanism with one variable to store the savings rate `dsr` and a rate accumulator `chi` to track the rewards that dai holders receive. Currently the savings rate is not natively integrated into the ERC20 DAI token. Ethereum external accounts or smart contracts have to execute a `join` transaction in Pot to earn the savings rate on their dai.

Normalized balances of users are stored in the `pie` variable and the real dai balance of users can be calculated by multiplying `pie` and `chi` anytime.

Rate accumulator `chi` value increases when `drip` function in the Pot contract is called which increases the balance of all locked dai holders. The Pot contract generates additional dai by recording bad debt first in Vow which will most likely get cancelled with surplus that is also being collected continuously as stability fees from Vaults.

The `join` function expects the caller to calculate and input the normalized balance instead of the amount of dai being deposited by the user. It also requires `drip` to be executed to ensure the current dai being deposited doesn't earn additional dai for past time before the actual deposit. These details are handled for you if the [join proxy script](https://github.com/makerdao/dss-proxy-actions/blob/7821a2329bd58f7d94a2de77d75f2371aa2d8342/src/DssProxyActions.sol#L866) is used instead of `join` directly. You can learn more about DSProxy and Proxy Scripts in the [Working with DSProxy](/devtools/working-with-dsproxy/working-with-dsproxy.md) guide.

### Single Collateral Dai

Single Collateral Dai (SCD) uses the rate mechanism for collecting stability fees from Collateralized Debt Position (CDP) owners. Technically there are two different rate mechanisms present in the [Tub](https://github.com/makerdao/sai/blob/master/src/tub.sol) contract to collect two types of fees from CDP owners: governance fee `fee` (sent to MKR holders), and stability fee `tax` (sent to PETH holders). Normalized debt units for `fee` and `tax` are `ire` and `art`, and their rate accumulators are `_rhi` and `_chi` respectively.

One operational fact that you have to consider is that only the governance fee `fee` is activated by Maker governance but it is colloquially referred to by everybody as the stability fee. The technical stability fee `tax` in the system has always been dormant with its rate set to `1` ray. We'll also refer to the governance fee as stability fee for the rest of this guide.

Stability fees are accounted for in dai but collected in MKR when a CDP owner pays back some of their debt at the price reported by the MKR/USD price feed. Some frontend interfaces have automated this MKR payment for users by integrating with decentralized exchange contracts to buy the necessary amount of MKR using DAI or ETH for the address before wiping debt from the CDP. This MKR is immediately sent to the burner contract [Pit](https://etherscan.io/token/0x9f8f72aa9304c8b593d555f12ef6589cc3a579a2?a=0x69076e44a9c70a67d5b79d95795aba299083c275) which removes it from circulation. It can also be removed from total supply when Pit is authorized by the MKR token.

The `drip` call is added to functions that CDP owners execute periodically in SCD to update everyones' stability fees, while in MCD, Maker governance is responsible for executing drip periodically to update the stability fee owed by Vaults instead of Vault owners themselves.

PETH holders receive their compensation through liquidation penalties levied on unsafe CDPs which is a completely different mechanism.

## Troubleshooting

*Exponentiation calculation taking too long?*
Check for a missing decimal point in rate if your python script takes too long to perform the exponentiation calculation.

## Summary

In this guide we reviewed the general rate mechanism and how its used to track the Stability fee and the Dai Savings Rate in the Maker protocol.

## Help

- Contact Integrations team - integrate@makerdao.com
- Rocket chat - #dev channel
