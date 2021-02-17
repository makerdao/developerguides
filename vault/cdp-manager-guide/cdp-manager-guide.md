---
title: CDP Manager Guide
description: Learn about CDP Manager and use it to integrate with Maker Protocol
parent: vaults
tags:
  - vaults
  - CDP Manager  
slug: cdp-manager-guide
contentType: guides
root: false
---

# CDP Manager Guide

**Level**: Advanced  
**Estimated Time**: 30 minutes

This guide works under the [1.0.7](https://changelog.makerdao.com/releases/kovan/1.0.7/contracts.json) Kovan release of the system

- [CDP Manager Guide](#cdp-manager-guide)
  - [Overview](#overview)
  - [Learning Objectives](#learning-objectives)
  - [Pre-requisites](#pre-requisites)
  - [The Vault Lifecycle](#the-vault-lifecycle)
  - [Guide](#guide)
    - [Setup](#setup)
    - [Locking collateral into the system](#locking-collateral-into-the-system)
    - [Draw Dai](#draw-dai)
    - [Pay back Dai](#pay-back-dai)
    - [Unlock collateral from system](#unlock-collateral-from-system)

## Overview

The [DssCdpManager](https://github.com/makerdao/dss-cdp-manager), was created to enable a formalised process to interact with the Maker Protocol. The manager works by having a [dss](https://github.com/makerdao/dss) wrapper that allows users to interact with their Vaults in an easy way, treating them as non-fungible tokens (NFTs).

In addition to the [dss-proxy](https://github.com/makerdao/dss-proxy-actions)-actions, the CDP Manager is the recommended interface to engage with the Maker Protocol as it allows users to easily transfer their Vaults to each other if need be. In addition, each Vault created through this interface gets an ID, which can then be used for purposes such as tracking your Vault positions, or attaching this ID to another reference in your own system.

By using the Vault Manager directly, the msg.sender will be the direct owner of the Vault in comparison to using ds-proxy and dss-proxy-actions, where the ds-proxy address will be the owner of the Vaults and the user will be the owner of the proxy.

## Learning Objectives

This guide will help you understand the functions available in the CDP Manager by walking you through the lifecycle of a Vault.

The lifecycle being:

- Lock collateral in the system
- Draw Dai
- Pay back Dai
- Unlock collateral from system

## Pre-requisites

You will need to have a good understanding of these concepts and tools in order to follow along this guide

- [MCD 101](https://github.com/makerdao/developerguides/blob/master/mcd/mcd-101/mcd-101.md)
- Solidity
- [Seth](https://github.com/dapphub/dapptools/tree/master/src/seth)

## The Vault Lifecycle

The Vault life cycle involves the process of locking some collateral token that is [approved](https://forum.makerdao.com/t/about-the-collateral-onboarding-app-category/1982) by the MKR token holders into the system, drawing Dai against this token, [using Dai](https://makerdao.com/en/ecosystem)[,](https://github.com/makerdao/awesome-makerdao#use-your-dai) paying back Dai into the system and freeing back the locked collateral.

Below are the functions that will be called in the CDP Manager contract. Note that additional functions need to be called in the token adapter contracts for depositing and withdrawing BAT and Dai.

- **Opening a Vault, depositing collateral and generating Dai**
  - `CDP_MANAGER.open()` - Open a CDP with the type of collateral you want to borrow Dai against
  - `BAT.approve()`  - Approve BAT adapter to pull BAT from your wallet
  - `MCD_JOIN_BAT_A.join()` - Move BAT to BAT token adapter.
  - `CDP_MANAGER.frob()` - Lock BAT and create new Dai
  - `CDP_MANAGER.move()` - Move Dai from urn address to your wallet address, Dai is still in Vat.
  - `MCD_VAT.hope()` - Approve Dai token adapter in Vat to mint Dai
  - `MCD_JOIN_DAI.exit()` - Mint ERC-20 Dai to your wallet address  
- **Paying back Dai, and retrieving collateral**
  - `MCD_DAI.approve()` - Approve Dai token adapter to pull Dai from your wallet
  - `MCD_JOIN_DAI.join()` - Move Dai to Dai token adapter
  - `CDP_MANAGER.frob()` - Pay back Dai debt and unlock BAT tokens
  - `CDP_MANAGER.flux()` - Move BAT tokens to your wallet address
  - `MCD_JOIN_BAT_A.exit()` - Withdraw BAT tokens to your wallet address

## Guide

Before starting this guide please install [dapptools](https://dapp.tools/) and [setup seth](https://github.com/makerdao/developerguides/blob/master/devtools/seth/seth-guide-01/seth-guide-01.md) for use with the Kovan testnet.

### Setup

Execute these commands to initialise environment variables with addresses of the Maker Protocol contracts. In your terminal, execute:

```bash
export CDP_MANAGER=0x1476483dD8C35F25e568113C5f70249D3976ba21
export MCD_VAT=0xbA987bDB501d131f766fEe8180Da5d81b34b69d9
export BAT=0x9f8cFB61D3B2aF62864408DD703F9C3BEB55dff7
export MCD_JOIN_BAT_A=0x2a4C485B1B8dFb46acCfbeCaF75b6188A59dBd0a
export MCD_DAI=0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa
export MCD_JOIN_DAI=0x5AA71a3ae1C0bd6ac27A1f28e1415fFFB6F15B8c
export MCD_JUG=0xcbB7718c9F39d05aEEDE1c472ca8Bf804b2f1EaD
export ETH_GAS=2000000
```
You will use Kovan BAT tokens as the collateral in this guide. If you need to get some Kovan BAT tokens, follow [this guide.](https://github.com/makerdao/developerguides/blob/master/mcd/mcd-seth/mcd-seth-01.md#getting-tokens)

### Locking collateral into the system

As you use the CDP Manager for interacting with the system, first you will need to `open` an empty Vault.

Calling the `open` function, you will receive a `cdpId` of your Vault. When opening a Vault you have to specify the collateral type `(bytes32 ilk)` for the Vault. `address usr` is the address that will own the Vault.

In the CDP Manager code, a Vault is defined as an `urn`. The `urn` has an identifier address just like your wallet address. With this address the CDP Manager can handle the accounting of the urn. For example, when adding collateral to your Vault, the collateral is pulled from your wallet to the collateral token adapter and is registered under the urn address of your Vault. Each Vault has an urn address and an ID that can be easily identified.

Each Vault can only have one type of collateral. Hence, you as a user can open many Vaults with different or same collaterals. This approach gives you flexibility if you want to handle many Vaults.

An example where one would use this method of opening many Vaults, is custodial exchanges that want to integrate Vaults onto their platform. As the users don't have access to their keys to interact with the Vault, the exchange could open each user a Vault and link the cdpId to the userId.

Let's define the ilk before you call the open function.

```bash
export ilk=$(seth --to-bytes32 $(seth --from-ascii "BAT-A"))
```
  
Now let's call the open function.

```bash
seth send $CDP_MANAGER 'open(bytes32, address)' $ilk $ETH_FROM
```

To get the cdpId, execute:

```bash
export cdpId=$(seth --to-dec $(seth call $CDP_MANAGER 'last(address)' $ETH_FROM))
```

Besides the `cdpId`, you need to get the `urn` address as well. That's where ink(collateral balance) and art(outstanding stablecoin debt) is registered.

```bash
export urn=$(seth call $CDP_MANAGER 'urns(uint)(address)' $cdpId)
```

----------

After acquiring the `cdpId` and `urn` address, you can move to the next step. Locking your tokens into the system. This process has two steps:

- Approving MCD_JOIN_BAT_A adapter to withdraw BAT from your wallet
- Send BAT to the urn address.

Let's define the value of collateral that you will lock, `dink`, and the value of Dai that you'll draw, `dart`.

```bash
export dink=$(seth --to-uint256 $(seth --to-wei 300 eth))
export dart=$(seth --to-uint256 $(seth --to-wei 25 eth))
```
  
Approving `MCD_JOIN_BAT_A` adapter to withdraw `dink` BAT.

```bash
seth send $BAT 'approve(address,uint)' $MCD_JOIN_BAT_A $dink
```
  
Sending `dink` amount of BAT to the urn.

```bash
seth send $MCD_JOIN_BAT_A 'join(address,uint)' $urn $dink
```

Now you can lock your BAT into the system and draw Dai against it. You can do it all in one function.

```bash
seth send $CDP_MANAGER 'frob(uint,int,int)' $cdpId $dink $dart
```

Let's check the status of your `urn` by calling VAT.

```bash
seth call $MCD_VAT 'urns(bytes32,address)(uint256,uint256)' $ilk $urn
```
  
Output:

```bash
300000000000000000000
25000000000000000000
```
  
If converted to decimals you get this:  

```bash
300.000000000000000000 <- Dink  
25.000000000000000000 <- Dart
```

This tells us that your Vault has 300 BAT as collateral and 25 DAI as outstanding debt.

----------

### Draw Dai

What has been covered so far in this guide was the creation of Dai debt in the system. In short, you create a balance of your debt in the system. After, you need to add this balance to your wallet. Now, to actually withdraw it to your own address, you will need to do some functions calls:

```bash
CDP_MANAGER.move(uint,address,uint);
MCD_VAT.hope(address);
MCD_JOIN_DAI.exit(address,uint)
```
  
`CDP_MANAGER.move()` function moves the Dai from the `urn` to your `ETH_FROM`, your personal address. However, you still won't see the balance on your wallet. In order to see the balance, you'll need to approve the `MCD_JOIN_DAI` adapter in `MCD_VAT` from the system with the `MCD_VAT.hope()` function. After, you call the `MCD_JOIN_DAI.exit()` to finally move the DAI to your wallet. This looks a bit of a complicated process, but this just shows how the system operates.

Moving DAI from `urn` to `ETH_FROM`(your address).
You need to define rad, a high precision number as a variable that will be passed in the `move()` function. In VAT the debt balance is registered with a higher precision number than on your wallet. So to make sure to move all funds, you need to define a `rad` variable that has 45 decimal places.

```bash
export rad=$(seth --to-uint256 $(echo "25"*10^45 | bc))
seth send $CDP_MANAGER 'move(uint,address,uint)' $cdpId $ETH_FROM $rad
```

Approving `MCD_JOIN_DAI` to exit Dai in `MCD_VAT`.

```bash
seth send $MCD_VAT 'hope(address)' $MCD_JOIN_DAI
```
  
Exiting Dai to own wallet address.

```bash
seth send $MCD_JOIN_DAI 'exit(address,uint)' $ETH_FROM $dart
```
  
Finally, you have got your new Dai in your wallet. To check the balance, execute the below command.

```bash
seth --from-wei $(seth --to-dec $(seth call $MCD_DAI 'balanceOf(address)' $ETH_FROM))
```
  
----------

### Pay back Dai

Paying back Dai involves calling a set of functions as well. They are:

```bash
MCD_DAI.approve(address,uint);
MCD_JOIN_DAI.join(address,uint);
CDP_MANAGER.frob(uint,int,int)
```
  
The first one is to approve `MCD_JOIN_DAI` to take Dai from your wallet. Second, you send the Dai to your `urn`. Third, you pay back Dai in the VAT.

When borrowing from Maker Protocol, there's usually a rate that the Vault owner has to pay for borrowing Dai. When paying all debt back, the debt should consider the Dai + the accrued debt for the Dai that has been borrowed. Below, you calculate the debt and rate from the system:

```bash
export art=$(seth --from-wei $(seth call $MCD_VAT 'urns(bytes32,address)(uint256,uint256)' $ilk $urn | sed -n 2p))

export rate=$(seth --to-fix 27 $(seth call $MCD_VAT 'ilks(bytes32)(uint256,uint256,uint256,uint256,uint256)' $ilk | sed -n 2p))

export debt=$(bc<<<"$art*$rate")

export debtWadRound=$(seth --to-uint256 $(bc<<<"$art*$rate*10^18/1+1"))
```
  
Approving `MCD_JOIN_DAI` to take the Dai debt (debtWadRound) from your wallet:

```bash
seth send $MCD_DAI 'approve(address,uint)' $MCD_JOIN_DAI $debtWadRound
```

Sending Dai to your urn. By setting the address parameter to urn in join(address, uint) you skip the step of needing to use the move function in the CDP_MANAGER.

```bash
seth send $MCD_JOIN_DAI 'join(address,uint)' $urn $debtWadRound
```
  
Check if it all worked:

```bash
seth --to-fix 45 $(seth call $MCD_VAT 'dai(address)(uint256)' $urn)
```
  
Paying back Dai involves calling the `CDP_MANAGER.frob()` function with negative dink and dart values. In other words, you're just changing the balance to 0 in VAT. This of course involves sending the Dai to the system, which gets burned, and unlocking the collateral in your urn.

```bash
export nDink=$(seth --to-int256 $(seth --to-wei -300 eth))
export nDart=$(seth --to-int256 $(seth --to-wei -25 eth))
```
  
Calling `CDP_MANAGER.frob()`

```bash
seth send $CDP_MANAGER 'frob(uint, int, int)' $cdpId $nDink $nDart
```

----------

Alternative to pay back debt is to create the raw transaction data and pass it to the CDP_MANAGER contract. First you prepare all necessary data to transform it into raw data.

```bash
sig="frob(uint256,int256,int256)"

sigBytes=$(seth sig "$sig")

cdpId=$(seth --to-uint256 $cdpId)

cdpIdRaw=${cdpId:2}

nDinkRaw=${nDink:2}

nDartRaw=${nDart:2}

rawData=${sigBytes}${cdpIdRaw}${nDinkRaw}${nDartRaw}
```
  
Execute raw data:

```bash
seth send $CDP_MANAGER $rawData
```
  
### Unlock collateral from system

Now you need to take the collateral from the urn and have it sent back to your address.

```bash
seth send $CDP_MANAGER 'flux(uint,address,uint)' $cdpId $ETH_FROM $dink
```
  
Let's exit the collateral from the BAT adapter.

```bash
seth send $MCD_JOIN_BAT_A 'exit(address,uint)' $ETH_FROM $dink
```

To see if you got your collateral back in your wallet, just check your BAT balance:

```bash
seth --from-wei $(seth --to-dec $(seth call $BAT 'balanceOf(address)' $ETH_FROM))
```

Congratultaions! You have issued and paid back DAI through the CDP Manager.
