# Add a new collateral type to DCS - Kovan

**Level**: Advanced

**Estimated Time**: 90 - 120 minutes

- [Add a new collateral type to DCS - Kovan](#add-a-new-collateral-type-to-dcs---kovan)
  - [Overview](#overview)
  - [Learning Objectives](#learning-objectives)
  - [Pre-requisites](#pre-requisites)
  - [Guide](#guide)
    - [Setup](#setup)
    - [Collateral Type](#collateral-type)
    - [Setup Spell](#setup-spell)
    - [Price Feeds](#price-feeds)
    - [Deploy Adapter](#deploy-adapter)
    - [Deploy Collateral Auction contract](#deploy-collateral-auction-contract)
    - [Calculate Risk Parameters](#calculate-risk-parameters)
    - [Deploy Spell](#deploy-spell)
    - [Governance actions](#governance-actions)
    - [Execute Spell](#execute-spell)
    - [Test Collateral Type](#test-collateral-type)
  - [Troubleshooting](#troubleshooting)
  - [Summary](#summary)
  - [Additional resources](#additional-resources)
  - [Next Steps](#next-steps)
  - [Help](#help)

## Overview

Dai Credit System(DCS) deployed to the Kovan testnet now supports multiple collateral types. You can now add a new token as a collateral type, and allow users and developers to test various aspects of this integration. This guide covers the steps involved in setting up various contracts to initialize a new collateral type on the testnet. Adding it to the mainnet deployment will be handled by risk teams and those steps won't be covered in this guide.

## Learning Objectives

After going through this guide you will get a better understanding of,

- Configuring core DCS contracts
- Additional contracts required: Price Feed, Auction, Adapter.
- Governance steps to initialize the new collateral type.

## Pre-requisites

You will need a good understanding of these concepts to be able to work through this guide,

- [MCD 101](https://github.com/makerdao/developerguides/blob/master/mcd/mcd-101/mcd-101.md).
- Collateralized Debt Positions(CDP).
- Risk parameters of a collateral type.
- Solidity.
- Dapptools - Dapp, Seth.

## Guide

*Before starting this guide please install [dapptools](https://dapp.tools) and [setup seth](https://github.com/makerdao/developerguides/blob/master/devtools/seth/seth-guide-01/seth-guide-01.md) for use with the Kovan testnet.*

The guide below is updated for the [0.2.10](https://changelog.makerdao.com/releases/0.2.10/index.html) release of DCS on Kovan.

For this tutorial you will want to set the gas limit to 3,000,000
```bash
export ETH_GAS=3000000
```

### Setup

Execute these commands to initialize environment variables with addresses of the core DCS contracts.

```bash
export MCD_VAT=0x5ce1e3c8ba1363c7a87f5e9118aac0db4b0f0691
export MCD_CAT=0xfd5db7bd95c6a53f805dc2c631e62803e17de609
export MCD_JUG=0x1ff7cb4126d7690daaa1c0f1ba58bab06d53d4b8
export MCD_SPOT=0xcf68a9dc1e17a0d56ffedfb7e96ed6bf7e84458a
export MCD_PAUSE=0x8fe4f004ed32c0d11d00de9f7aa65a37815211ae
export MCD_PAUSE_PROXY=0xd8439f40a308964666800c03fb746e32901eb0e8
export MCD_ADM=0x03358a3959247ae8de50a52c7919b88ab5989b85
export MCD_END=0xc6cd35939523d258d5c28febf6017635a4ea858d
export MCD_JOIN_DAI=0xe70a5307f5132ee3a6a056c5efb7d5a53f3cdbd7
```

Set a variable with the address of the token going to be used for the collateral type. This guide will use the Kovan MKR token as an example.

```bash
export TOKEN=0xaaf64bfcc32d0f15873a02163e7e500671a4ffcd
```

### Collateral Type

Set the `ILK` variable with a name for the collateral type. Each ethereum token in DCS can have multiple collateral types and each one can be initialized with a different set of risk parameters. Affixing an alphabetical letter to the token symbol will help users differentiate these collateral types.

```bash
export ILK="$(seth --to-bytes32 "$(seth --from-ascii "MKR-A")")"
```

### Setup Spell

Initializing a collateral type involves making changes to various core DCS contracts using `file()` functions, and updating authorization permissions among contracts using `rely()`. A set of changes to be made at a time are captured in a `Spell` smart contract. Once a Spell is deployed, governance can elect its address as an authority which then lets it execute the changes in DCS. Although it is strictly not required, spells currently are designed to be used once and will lock up after they are executed.

Spell contracts can be built for various purposes, we will use an existing spell template to create a new collateral type.

Download the `dss-add-ilk-spell` repo and build it locally using the commands below. Please ensure you have `dapp` setup prior to executing this step. The build process is going to take a while!

```bash
git clone https://github.com/makerdao/dss-add-ilk-spell.git
cd dss-add-ilk-spell
dapp update
dapp build --extract
```

### Price Feeds

Off-chain oracles get the pricing data of a token from various exchange APIs and they then submit these updates to an on-chain median contract which computes a median value. The Oracle Security Module(OSM) introduces a delay before the system accepts the newly reported price to give users a chance to add more collateral if their CDP is about to become unsafe, and also for governance to trigger emergency shutdown if compromised oracles have input a malicious price value.

Instead of deploying the full set of these contracts, we will only deploy a single `DSValue` contract without a price feed delay for our testing purposes. You can retain admin permissions over it to update the price value manually using a seth command. For example, the command below sets the price of each token to 9000 USD.

```bash
dapp create DSValue
export PIP=0xf7cea7c74b42eb97f0a57503f5f0713ef6aed2fc
seth send $PIP 'poke(bytes32)' $(seth --to-uint256 "$(seth --to-wei 9000 ETH)")
```

### Deploy Adapter

Vat does not make calls to any external contracts, including tokens. Instead it maintains internal `gem` balances of users for each collateral type. Users deposit tokens into the corresponding adapter contract using `join()` to get this internal `gem` balance.

You can use the `GemJoin1` adapter contract without making any modifications if it conforms to the ERC20 token standard, has simple transfer mechanics, and no known issues. Consider making changes to this contract if you need to perform additional checks to validate the token transfers a user makes to the adapter contract. 

Examples of some non-standard adapters are available [here](https://github.com/makerdao/dss-deploy/blob/master/src/join.sol) for your reference.

Execute this command to create a new `GemJoin1` contract and initialize a variable with it's address.

```bash
export JOIN=$(dapp create GemJoin1 "$MCD_VAT" "$ILK" "$TOKEN")
```

### Deploy Collateral Auction contract

Deploy a new collateral auction contract(Flip) for the token.
Permit `Pause Proxy` address to make changes to the Flip contract using `rely()`, and remove permissions for your own address to make further changes using `deny()`.

```bash
export FLIP=$(dapp create Flipper "$MCD_VAT" "$ILK")
seth send "$FLIP" 'rely(address)' "$MCD_PAUSE_PROXY"
seth send "$FLIP" 'deny(address)' "$ETH_FROM"
```

### Calculate Risk Parameters

All collateral types need risk parameters to set bounds for issuing Dai debt. We'll set the new collateral type with some starting parameters and they can also be updated later by governance through executive votes.

Debt ceiling sets the maximum amount of Dai that can be issued against CDPs of this collateral type. Calculate the uint256 value using the first command to initialize the LINE variable with `5 Million`.

```bash
seth --to-uint256 $(echo "5000000"*10^45 | bc)
export LINE=000000000000000000000d5d238a4abe9806872a4904598d6d88000000000000
```

Collateralization ratio sets the amount of over-collateralization required for the collateral type.
Calculate the uint256 value using the first command to initialize the MAT variable with `150%`.

```bash
seth --to-uint256 $(echo "150"*10^25 | bc)
export MAT=000000000000000000000000000000000000000004d8c55aefb8c05b5c000000
```

Total stability fee accumulated for each collateral type inside its `rate` variable is calculated by adding up DSR `base` which is equal across all collateral types and the Risk Premium `duty` which is specific to each one.
Calculate the uint256 value using the first command to initialize the DUTY variable with an annual rate of `1%`.

```bash
seth --to-uint256 1000000000315522921573372069
export DUTY=0000000000000000000000000000000000000000033b2e3ca43176a9d2dfd0a5
```

*Note: We'll cover how the number `1000000000315522921573372069` corresponds to a `1%` annual rate in a future guide and link it here.*

A liquidation penalty is imposed on a CDP by increasing it's debt by a percentage before a collateral aucion is kicked off. This penalty is imposed to prevent [Auction Grinding Attacks](https://github.com/livnev/auction-grinding/blob/master/grinding.pdf).
Calculate the uint256 value using the first command to initialize the CHOP variable with an additional `10%`.  We pass `110%` here because when we start an auction we want it to be for the amount of the outstanding debt plus `10%`.

```bash
seth --to-uint256 $(echo "110"*10^25 | bc)
export CHOP=0000000000000000000000000000000000000000038de60f7c988d0fcc000000
```

Since the size of CDPs of a collateral type can vary wildly, collateral auctions can be inefficient if even large CDPs are auctioned off with a single Flip auction. CDPs with locked collateral amounts greater than liquidation quantity of their collateral type are processed with multiple collateral auctions. Only one collateral auction is required if the amount of collateral locked in a CDP is below the liquidation quantity.

Calculate and initialize the LUMP variable with `1000`.

```bash
seth --to-uint256 $(echo "1000"*10^18 | bc)
export LUMP=00000000000000000000000000000000000000000000003635c9adc5dea00000
```

### Deploy Spell

We have everything setup to deploy a new spell contract that captures the steps that need to be executed to initialize a new collateral type.

Execute the command below to deploy this spell and capture its address in a variable.

```bash
export SPELL=$(seth send --create out/DssAddIlkSpell.bin 'DssAddIlkSpell(bytes32,address,address[8] memory,uint256[5] memory)' $ILK $MCD_PAUSE ["${MCD_VAT#0x}","${MCD_CAT#0x}","${MCD_JUG#0x}","${MCD_SPOT#0x}","${MCD_END#0x}","${JOIN#0x}","${PIP#0x}","${FLIP#0x}"] ["$LINE","$MAT","$DUTY","$CHOP","$LUMP"])
```

### Governance actions

Executing this spell requires control over a majority of the MKR deposited in the governance contract Chief.

Execute this command to add weight to this spell with your MKR deposited in the Chief.

```bash
seth send "$MCD_ADM" 'vote(address[] memory)' ["${SPELL#0x}"]
```

Please notify the [Maker Foundation Integrations team](mailto:integrate@makerdao.com) who can help you garner a majority of votes for this spell before it can be executed.

### Execute Spell

Once your spell reveives a majority of votes in Chief, execute this command to elect it as a `hat`.

```bash
seth send "$MCD_ADM" 'lift(address)' "${SPELL#0x}"
```

Once lifted as an authority, execute this command to schedule the spell for execution.

```bash
seth send "$SPELL" 'schedule()'
```

A Governance Delay is imposed on all new executive proposals before they go live to ensure there is enough time for emergency shutdown to be triggered before a malicious proposal which could potentially steal collateral from users gets executed. This is currently set to 300 seconds on the testnet deployment.

Execute the previously scheduled spell with the `cast()` function after this delay is over with this command.

```bash
seth send "$SPELL" 'cast()'
```

### Test Collateral Type

A collateral type is now initialized and ready for users to open CDPs. Let's test this process to ensure everything was setup correctly.

Deposit tokens into the adapter to receive an internal `gem` balance, and verify this balance.

```bash
seth send $TOKEN 'approve(address,uint256)' $JOIN $(seth --to-uint256 $(seth --to-wei 1000 eth))
seth --from-wei $(seth --to-dec $(seth call $TOKEN 'allowance(address, address)' $ETH_FROM $JOIN)) eth
```

CDPs of a collateral type are identified by the address of the owner itself. Set the `urn` variable to your ethereum address.

```bash
export urn=$ETH_FROM
```

Calculate and set the `wad` variable to deposit 20 tokens into the token adapter.

```bash
export wad=$(seth --to-uint256 $(seth --to-wei 20 eth))
```

Deposit tokens in the adapter contract and verify it by checking your `gem` balance of the collateral type in Vat.

```bash
seth send $JOIN "join(address, uint)" $ETH_FROM $wad

export ilk=$(seth --to-bytes32 $(seth --from-ascii "MKR-A"))
seth --from-wei $(seth --to-dec $(seth call $MCD_VAT 'gem(bytes32,address)(uint256)' $ilk $ETH_FROM)) eth
```

Calculate and set the `dink` variable to lock up 18 tokens in the CDP, and set the `dart` variable to generate 35 Dai from it.

```bash
export dink=$(seth --to-uint256 $(seth --to-hex $(seth --to-wei 18 eth)))
export dart=$(seth --to-uint256 $(seth --to-hex $(seth --to-wei 35 eth)))
```

Call `frob()` directly on Vat to open a CDP by locking up collateral and generating Dai.

```bash
seth send $MCD_VAT "frob(bytes32,address,address,address,int256,int256)" $ilk $ETH_FROM $ETH_FROM $ETH_FROM $dink $dart
```

Execute the command below to withdraw 10 Dai from the internal balance in Vat and receive ERC-20 Dai tokens using the Dai token adapter.

```bash
export wad=$(seth --to-word $(seth --to-wei 10 eth))
seth send $MCD_VAT "hope(address)" $MCD_JOIN_DAI
seth send $MCD_JOIN_DAI "exit(address, uint256)" $ETH_FROM $wad
```

You've now successfully generated Dai with the new collateral type.

## Troubleshooting

## Summary

In this guide we looked at setting up a new collateral type for a token and opened a CDP to generate Dai from it.

## Additional resources

1. [Drawing Dai from the Kovan MCD deployment using Seth](https://github.com/makerdao/developerguides/blob/master/mcd/mcd-seth/mcd-seth-01.md)

## Next Steps

## Help

- Contact Integrations team - integrate@makerdao.com
- Rocket chat - #dev channel
