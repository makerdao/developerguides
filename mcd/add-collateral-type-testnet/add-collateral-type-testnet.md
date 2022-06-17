# Add a new collateral type to Maker Protocol - Goerli

**Level**: Advanced

**Estimated Time**: 90 - 120 minutes

<!-- vim-markdown-toc GFM -->

- [Overview](#overview)
- [Learning Objectives](#learning-objectives)
- [Pre-requisites](#pre-requisites)
- [Guide](#guide)
  - [Set up the environment](#set-up-the-environment)
  - [Deploy spell dependencies](#deploy-spell-dependencies)
    - [1. Set up the repo](#1-set-up-the-repo)
    - [2. Deploy the collateral token contract](#2-deploy-the-collateral-token-contract)
    - [3. Mint collateral tokens](#3-mint-collateral-tokens)
    - [4. Define the collateral type](#4-define-the-collateral-type)
    - [5. Create a dummy price feed](#5-create-a-dummy-price-feed)
    - [6. Deploy a token adapter](#6-deploy-a-token-adapter)
    - [7. Deploy a collateral auction contract](#7-deploy-a-collateral-auction-contract)
    - [8. Deploy a collateral auction pricing curve contract](#8-deploy-a-collateral-auction-pricing-curve-contract)
  - [Prepare the spell](#prepare-the-spell)
    - [0. Deploy the `DssExecLib`](#0-deploy-the-dssexeclib)
  - [1. Set up the Goeri spells repo](#1-set-up-the-goeri-spells-repo)
  - [Calculate Risk Parameters](#calculate-risk-parameters)
  - [Setup Spell](#setup-spell)
  - [Deploy Spell](#deploy-spell)
  - [Governance actions](#governance-actions)
  - [Execute Spell](#execute-spell)
  - [Test Collateral Type](#test-collateral-type)
- [Troubleshooting](#troubleshooting)
- [Summary](#summary)
- [Additional resources](#additional-resources)
- [Next Steps](#next-steps)
- [Help](#help)

<!-- vim-markdown-toc -->

## Overview

The Maker Protocol deployed to the Goerli testnet supports multiple collateral types. You can now add a new token as a
collateral type, and allow users and developers to test various aspects of this integration. This guide covers the steps
involved in setting up various contracts to initialize a new collateral type on the testnet. Adding it to the mainnet
deployment will be handled by risk teams and those steps will not be covered in this guide.

## Learning Objectives

After going through this guide you will get a better understanding of,

- Configuring core Maker Protocol contracts
- Additional contracts required: Price Feed, Auction, Adapter.
- Governance steps to initialize the new collateral type.

## Pre-requisites

You will need a good understanding of these concepts to be able to work through this guide,

- [Foundry 101](https://github.com/makerdao/developerguides/blob/master/foundry/foundry-guide/foundry-guide.md).
- [MCD 101](https://github.com/makerdao/developerguides/blob/master/mcd/mcd-101/mcd-101.md).
- Vaults
- Risk parameters of a collateral type
- Solidity
- Foundry - `forge`, `cast`

## Guide

_Before starting this guide please make sure to follow the Foundry 101 guide, set up a wallet and connect to the Goerli
testnet._

**⚠️ ATTENTION:** The guide below is updated for the [1.13.1](https://chainlog.makerdao.com/api/goerli/1.13.1.json)
release of Maker Protocol on Goerli. It **MAY** work for other versions, but there is no guarantee.

For this tutorial you will want to set the gas limit to at least 6,000,000 (6 million).

```bash
# Some foundry commands use the ETH_GAS env var, while others use FOUNDRY_GAS_LIMIT
export ETH_GAS=6000000
export FOUNDRY_GAS_LIMIT=$ETH_GAS
```

### Set up the environment

Execute these commands to initialize environment variables with addresses of the core Maker Protocol contracts.

```bash
export MCD_ADM=0x33Ed584fc655b08b2bca45E1C5b5f07c98053bC1
export MCD_CAT=0xd744377001FD3411d7d0018F66E2271CB215f6fd
export MCD_END=0xb82F60bAf6980b9fE035A82cF6Acb770C06d3896
export MCD_JOIN_DAI=0x6a60b7070befb2bfc964F646efDF70388320f4E0
export MCD_JUG=0xC90C99FE9B5d5207A03b9F28A6E8A19C0e558916
export MCD_PAUSE=0xefcd235B1f13e7fC5eab1d05C910d3c390b3439F
export MCD_SPOT=0xACe2A9106ec175bd56ec05C9E38FE1FDa8a1d758
export MCD_VAT=0xB966002DDAa2Baf48369f5015329750019736031
export MCD_PAUSE_PROXY=0x5DCdbD3cCF9B09EAAD03bc5f50fA2B3d3ACA0121
export JOIN_FAB=0x0aaA1E0f026c194E0F951a7763F9edc796c6eDeE
export CLIP_FAB=0xcfAab43101A01548A95F0f7dBB0CeF6f6490A389
export CALC_FAB=0x579f007Fb7151162e3095606232ef9029E090366
```

The addresses above can be obtained from the [official MCD Goerli chainlog](https://chainlog.makerdao.com/). Just make
sure you are connected to the Goerli network when using it.

**⚠️ ATTENTION:** If you deployed your own MCD using the [MCD Deployment Guide](../mcd-deplyoment/mcd-deployment.md), you
need to replace the addresses above with the respective contracts.

### Deploy spell dependencies

This guide will use the [`dss-onboard-ilk-helper`](https://github.com/clio-finance/dss-onboard-ilk-helper) repo.

#### 1. Set up the repo

```bash
git clone --recurse-submodules https://github.com/clio-finance/dss-onboard-ilk-helper
cd dss-onboard-ilk-helper
cp .env.example .env
# TODO: replace the values in `.env` accordingly
```

Then edit the `.env` file:

```bash
 # These are the parameters defined in the Foundry 101 guide.
export FOUNDRY_ETH_FROM=<YOUR_WALLET_ADDRESS>
export FOUNDRY_ETH_KEYSTORE_DIR="${HOME}/.ethereum/keystore"
export FOUNDRY_ETH_PASSWORD_FILE="${HOME}/.eth-password" # This is optional
```

#### 2. Deploy the collateral token contract

There is a simple ERC-20 token named `DummyToken` in this repo which can be deployed.

```bash
export TOKEN=$(scripts/forge-deploy.sh --verify DummyToken --constructor-args 'Dummy Token' 'DUMMY')
```

#### 3. Mint collateral tokens

`DummyToken`s are mintable by their owners:

```bash
scripts/cast-send.sh $TOKEN 'mint(address,uint)' $ETH_FROM $(cast --to-wei 1000 ETH)
```

#### 4. Define the collateral type

Set the `ILK` variable with a name for the collateral type. Each token in Maker Protocol can have multiple collateral
types and each one can be initialized with a different set of risk parameters. Affixing an alphabetical letter to the
token symbol will help users differentiate these collateral types.

```bash
export ILK="$(cast --from-ascii 'DUMMY-A' | cast --to-bytes32)"
```

#### 5. Create a dummy price feed

Off-chain oracles get the pricing data of a token from various exchange APIs, and they then submit these updates to an
on-chain median contract which computes a median value. The Oracle Security Module(OSM) introduces a delay before the
system accepts the newly reported price to give users a chance to add more collateral if their Vault is about to become
unsafe, and also for governance to trigger emergency shutdown if compromised oracles have input a malicious price value.

Instead of deploying the full set of these contracts, you will only deploy a single `DSValue` contract without a price
feed delay for testing purposes. You can retain admin permissions over it to update the price value manually . For
example, the command below sets the price of each token to 1000 USD.

```bash
export PIP=$(scripts/forge-deploy.sh --verify DSValue)
scripts/cast-send.sh $PIP 'poke(bytes32)' $(seth --to-wei 1000 ETH | seth --to-uint256)
```

You can verify that the value has been set.

```bash
cast call $PIP 'read()(uint)'
```

#### 6. Deploy a token adapter

The Vat does not make calls to any external contracts, including tokens. Instead, it maintains internal `gem` balances
of users for each collateral type. Users deposit tokens into the corresponding adapter contract using `join()` to get
this internal `gem` balance.

You can use the `GemJoin` adapter contract without making any modifications if it conforms to the ERC20 token standard,
has simple transfer mechanics, and no known issues. Consider making changes to this contract if you need to perform
additional checks to validate the token transfers a user makes to the adapter contract.

Examples of some non-standard adapters are available in
[`dss`](https://github.com/makerdao/dss/blob/master/src/join.sol) and
[`dss-deploy`](https://github.com/makerdao/dss-deploy/blob/master/src/join.sol) for reference.

There is actually an on-chain factory for the most common types of `GemJoin`s named `JOIN_FAB`.

**⚠️ ATTENTION:** The `JOIN_FAB` in this article is bound to the official MCD Goerli environment. If you are using this
guide in you own environment, you need to either deploy a [`JoinFab`](https://github.com/brianmcmichael/JoinFab) of your
own to use it or deploy a standalone [`GemJoin` contract](https://github.com/makerdao/dss/blob/master/src/join.sol) from
the main MCD repo. Don't forget to make the `MCD_PAUSE_PROXY` the owner of the `GemJoin`.

You can create a new `GemJoin` from the factory with:

```bash
export NEW_GEM_JOIN_TX=$(scripts/cast-send.sh $JOIN_FAB 'newGemJoin(address owner, bytes32 ilk, address gem)' $MCD_PAUSE_PROXY $ILK $TOKEN)
```

Next you can use some `jq` dark sorcery to obtain the created contract address from the transaction receipt. Notice that
this command is specific for the current version of the `JOIN_FAB` and might not work if the implementation changes. If
the following does not work, you can manually inspect the transaction on Etherscan to obtain the contract address.

```bash
export GEM_JOIN=$(cast --abi-decode 'x()(address)' $(cast receipt --json $NEW_GEM_JOIN_TX |\
    jq -r ".logs[] | select(.address == (\"${JOIN_FAB}\" | ascii_downcase)) | .topics[1]"))
```

#### 7. Deploy a collateral auction contract

Deploy a new collateral auction contract (`Clip`) for the token. There is actually an on-chain factory for `Clip`
contracts named `CLIP_FAB`. Contrary to the `JOIN_FAB`, the `CLIP_FAB` is not bound to any MCD environment, so you can
freely use it to deploy `Clip` instances.

```bash
export NEW_CLIP_TX=$(scripts/cast-send.sh $CLIP_FAB \
    'newClip(address owner, address vat, address spotter, address dog, bytes32 ilk)' $MCD_PAUSE_PROXY $MCD_VAT $MCD_SPOT $MCD_DOG $ILK)
```

Luckily the newly deployed `Clip` contract emit some events, so we can query the transaction receipt to get its address:

```bash
CLIP=$(cast receipt --json $NEW_CLIP_TX | jq -r '.logs[0].address')
```

#### 8. Deploy a collateral auction pricing curve contract

Since the events of [Black Thursday](htts://forum.makerdao.com/t/covid-crash-emergency-governance-summary/2437), which
led to the release of the [Liquidations 2.0](https://forum.makerdao.com/t/liquidations-2-0-technical-summary/4632)
module, MakerDAO performs Dutch Auctions for collateral tokens when vaults are liquidated.

Dutch Auctions requires oracles to provide the starting price for the asset and also a function over time to derive the
current price.

Such curve is provided by the `Abaci` module (a.k.a.: `ClipCalc`). There is also an on-chain factory for such contracts
named `CALC_FAB`, which is also not tied to any particular MCD environment.

The `CALC_FAB` has 3 methods:

1. `newExponentialDecrease`:
2. `newLinearDecrease`:
3. `newStairstepExponentialDecrease`:

Unless you have a specific reason, you probably want to stick with `newStairstepExponentialDecrease`, as it is the most
used across MCD.

```bash
NEW_CLIP_CALC_TX=$(scripts/cast-send.sh $CALC_FAB 'newStairstepExponentialDecrease(address owner)' $MCD_PAUSE_PROXY)
```

Luckily the newly deployed `ClipCalc` contract emit some events, so we can query the transaction receipt to get its
address:

```bash
CLIP_CALC=$(cast receipt --json $NEW_CLIP_CALC_TX | jq -r '.logs[0].address')
```

### Prepare the spell

The [Goerli Spells repo](https://github.com/makerdao/spells-goerli) contain all the pieces required to successfully cast
a MCD spell. You can clone the original repo locally in your machine or fork the repo.

#### 0. Deploy the `DssExecLib`

**⚠️ ATTENTION:** The next section is required only if you are trying to create spells for a different MCD environment.

The [`DssExecLib`](https://github.com/makerdao/dss-exec-lib/) can be seen as an implementation of the [Facade Design
Pattern](https://refactoring.guru/design-patterns/facade) on top of MCD. It aims to reduce the complexity of performing
common changes to the system.

However, there is a catch: `DssExecLib` cannot have any storage variables, so the chainlog address it requires needs to
be hard-coded. For that reason, there needs to be 1 instance of `DssExecLib` for each MCD environment.

First you need to clone the [`makerdao/dss-exec-lib`](https://github.com/makerdao/dss-exec-lib) repo:

```bash
git clone --recurse-submodules https://github.com/makerdao/dss-exec-lib
```

Next edit the `src/DssExecLib.sol` file. Look for a line containing:

```solidity
address constant public LOG = 0x...;
```

And replace the address with the one from the chainlog address of your environment.

Then deploy the modified contract. At the time of this writing, the `dss-exec-lib` repo depends on
[dapp.tools](https://dapp.tools), however you can still deploy it using Foundry's `forge`.

The convenience scripts you've been using so far are not available, so you have to provide the parameters manually:

```bash
# Currently `forge create` sends the logs to stdout instead of stderr.
# This makes it hard to compose its output with other commands, so here we are:
# 1. Duplicating stdout to stderr through `tee`
# 2. Extracting only the address of the deployed contract to stdout
RSPONSE=$(forge create DssExecLib --verify --json --gas-limit $FOUNDRY_GAS_LIMIT \
  --keystore "${HOME}/.ethereum/keystore/<YOUR_KEYSTORE_FILE>" \
  # If --password is omitted, forge will prompt you for the password
  --password $(cat "${HOME}/.eth-password") | \
  tee >(cat 1>&2))

export DSS_EXEC_LIB=$(jq -Rr 'fromjson? | .deployedTo' <<<"$RESPONSE")
```

### 1. Set up the Goeri spells repo

```bash
git clone --recurse-submodules https://github.com/makerdao/spells-goerli
cd spells-goerli
```

---

**⚠️ ATTENTION:** If you are casting spells to a different MCD environment and had to execute the previous section, you
need to replace the `DssExecLib` address in the file referencing it:

```bash
echo $DSS_EXEC_LIB > ./DssExecLib.address
```

---

<!-- TODO -->

### Calculate Risk Parameters

All collateral types need risk parameters to set bounds for issuing Dai debt. You'll set the new collateral type with some starting parameters and they can also be updated later by governance through executive votes.

Debt ceiling sets the maximum amount of Dai that can be issued against Vaults of this collateral type. Calculate the uint256 value using the first command to initialize the LINE variable with `5 Million`.

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

_Note: How the number `1000000000315522921573372069` corresponds to a `1%` annual rate is covered in [this guide](https://github.com/makerdao/developerguides/blob/master/mcd/intro-rate-mechanism/intro-rate-mechanism.md)_

A liquidation penalty is imposed on a Vault by increasing its debt by a percentage before a collateral aucion is kicked off. This penalty is imposed to prevent [Auction Grinding Attacks](https://github.com/livnev/auction-grinding/blob/master/grinding.pdf).
Calculate the uint256 value using the first command to initialize the CHOP variable with an additional `10%`. E.g. you can pass `110%` here so when you start an auction it will be for the amount of the outstanding debt plus `10%`.

```bash
seth --to-uint256 $(echo "110"*10^25 | bc)
export CHOP=0000000000000000000000000000000000000000038de60f7c988d0fcc000000
```

Vaults with locked collateral amounts greater than liquidation quantity of their collateral type are processed with multiple collateral auctions. Only one collateral auction is required if the amount of collateral locked in a Vault is below the liquidation quantity.

Calculate and initialize the LUMP variable with `1000`.

```bash
seth --to-uint256 $(echo "1000"*10^18 | bc)
export LUMP=00000000000000000000000000000000000000000000003635c9adc5dea00000
```

### Setup Spell

Initializing a collateral type involves making changes to various core Maker Protocol contracts using `file()` functions, and updating authorization permissions among contracts using `rely()`. A set of changes to be made at a time are captured in a `Spell` smart contract. Once a Spell is deployed, governance can elect its address as an authority which then lets it execute the changes in Maker Protocol. Although it is strictly not required, spells currently are designed to be used once and will lock up after they are executed.

Spell contracts can be built for various purposes, you will use an existing spell template to create a new collateral type.

Download the `makerdao/spells-goerli` repo and build it locally using the commands below. Please ensure you have `forge` setup prior to executing this step. The build process is going to take a while!

```bash
git clone --recurse-submodules https://github.com/makerdao/spells-goerli
cd spells-goerli
```

To start fresh, you can copy the `Goerli-DssSpell*` files from the `template/` directory into `src/`:

```bash
cp template/Goerli-DssSpell* src/
# answer yes to any prompts about overwriting existing files
```

### Deploy Spell

You have everything setup to deploy a new spell contract that captures the steps that need to be executed to initialize a new collateral type.

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

A collateral type is now initialized and ready for users to open Vaults. Let's test this process to ensure everything was setup correctly.

Deposit tokens into the adapter to receive an internal `gem` balance, and verify this balance.

```bash
seth send $TOKEN 'approve(address,uint256)' $JOIN $(seth --to-uint256 $(seth --to-wei 1000 eth))
seth --from-wei $(seth --to-dec $(seth call $TOKEN 'allowance(address, address)' $ETH_FROM $JOIN)) eth
```

Vaults of a collateral type are identified by the address of the owner itself. Set the `urn` variable to your ethereum address.

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

Calculate and set the `dink` variable to lock up 18 tokens in the Vault, and set the `dart` variable to generate 35 Dai from it.

```bash
export dink=$(seth --to-uint256 $(seth --to-hex $(seth --to-wei 18 eth)))
export dart=$(seth --to-uint256 $(seth --to-hex $(seth --to-wei 35 eth)))
```

Call `frob()` directly on Vat to open a Vault by locking up collateral and generating Dai.

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

In this guide you learned how to set up a new collateral type for a token and opened a Vault to generate Dai from it.

## Additional resources

1. [Drawing Dai from the Goerli MCD deployment using Seth](../mcd-seth/mcd-seth.md)

## Next Steps

## Help

- Discord - [#protocol-engineering-public](https://discord.com/channels/893112320329396265/897479589171986434)
