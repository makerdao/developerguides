---
title: Auction Keeper Bot Setup Guide
description: Learn how to setup an auciton keeper bot
parent: keepers
tags:
  - keepers
  - auction
  - bot
  - setup guide  
slug: auction-keeper-bot-setup-guide
contentType: guides
root: false
---

# Auction Keeper Bot Setup Guide

**Level:** Intermediate  
**Estimated Time:** 60 minutes  
**Audience:** Developers

- [Auction Keeper Bot Setup Guide](#auction-keeper-bot-setup-guide)
  - [Overview](#overview)
    - [Learning Objectives](#learning-objectives)
    - [Guide Agenda](#guide-agenda)
  - [1.Introduction](#1introduction)
  - [Auction Keeper Architecture](#auction-keeper-architecture)
  - [The Purpose of Auction Keepers](#the-purpose-of-auction-keepers)
  - [2. Bidding Models](#2-bidding-models)
  - [Starting and Stopping Bidding Models](#starting-and-stopping-bidding-models)
  - [**Communicating with *bidding models***](#communicating-with-bidding-models)
  - [Glossary (Bidding Models)](#glossary-bidding-models)
  - [3. Setting up the Auction Keeper Bot (Installation)](#3-setting-up-the-auction-keeper-bot-installation)
    - [Prerequisite](#prerequisite)
  - [Getting Started](#getting-started)
    - [Installation from source](#installation-from-source)
    - [Potential Errors](#potential-errors)
  - [4. Running your Keeper Bot](#4-running-your-keeper-bot)
    - [The Kovan version runs on the Kovan Release 1.0.2](#the-kovan-version-runs-on-the-kovan-release-102)
    - [1. Creating your bidding model (an example detailing the simplest possible bidding model)](#1-creating-your-bidding-model-an-example-detailing-the-simplest-possible-bidding-model)
    - [2. Setting up an Auction Keeper for a Collateral (Flip) Auction](#2-setting-up-an-auction-keeper-for-a-collateral-flip-auction)
    - [3. Passing the bidding the model as an argument to the Keeper script](#3-passing-the-bidding-the-model-as-an-argument-to-the-keeper-script)
    - [Auction Keeper Arguments Explained](#auction-keeper-arguments-explained)
  - [Auction Keeper Limitations](#auction-keeper-limitations)
  - [5. Accounting](#5-accounting)
  - [Getting Kovan MCD DAI, MKR and other Collateral tokens](#getting-kovan-mcd-dai-mkr-and-other-collateral-tokens)
    - [1. Getting MCD K-DAI (K-MCD 0.2.12 Release)](#1-getting-mcd-k-dai-k-mcd-0212-release)
    - [2. Getting MCD K-MKR (K-MCD 1.0.2 Release)](#2-getting-mcd-k-mkr-k-mcd-102-release)
    - [3. Getting MCD Collateral Tokens](#3-getting-mcd-collateral-tokens)
  - [6. Testing your Keeper](#6-testing-your-keeper)
  - [7. Support](#7-support)
  - [Disclaimer](#disclaimer)

## Overview

**NOTE!: For an out of the box working Keeper, [see this repository instead](https://github.com/makerdao/dockerized-auction-keeper). This guide will go more into detail on how to build your own keeper, and is not aimed for out of the box functionality.**

The Maker Protocol, which powers Multi Collateral Dai (MCD), is a smart contract based system that backs and stabilizes the value of Dai through a dynamic combination of Vaults, autonomous feedback mechanisms, and incentivized external actors. To keep the system in a stable financial state, it is important to prevent both debt and surplus from building up beyond certain limits. This is where Auctions and Auction Keepers come in. The system has been designed so that there are three types of Auctions in the system: Surplus Auctions, Debt Auctions, and Collateral Auctions. Each auction is triggered as a result of specific circumstances.

Auction Keepers are external actors that are incentivized by profit opportunities to contribute to decentralized systems. In the context of the Maker Protocol, these external agents are incentivized to automate certain operations around the Ethereum blockchain. This includes:

- Seeking out opportunities and starting new auctions
- Detect auctions started by other participants
- Bid on auctions by converting token prices into bids

More specifically, Keepers participate as bidders in the Debt and Collateral Auctions when Vaults are liquidated and auction-keeper enables the automatic interaction with these MCD auctions. This process is automated by specifying bidding models that define the decision making process, such as what situations to bid in, how often to bid, how high to bid etc. Note that bidding models are created based on individually determined strategies.

### Learning Objectives

This guide's purpose is to provide a walkthrough of how to use `auction-keeper` and interact with a Kovan deployment of the Multi Collateral Dai (MCD) smart contracts. More specifically, the guide will showcase how to set up and run an Auction Keeper bot for yourself. After going through this guide, you will achieve the following:

- Learn about Auction Keepers and how they interact with the Maker Protocol
- Understand bidding models
- Get your own auction keeper bot running on the Kovan testnet

### Guide Agenda

This guide will show how to use the auction-keeper to interact with the Kovan deployment of the MCD smart contracts. More specifically, the guide will showcase how to go through the following stages of setting up and running an Auction Keeper bot:

1. Introduction
2. Bidding Models
    - Starting and stopping bidding models
    - Communicating with bidding models
3. Setting up the Keeper Bot (Flip Auction Keeper)
    - Prerequisites
    - Installation
4. Running your Keeper Bot (Usage)
    - Keeper Limitations
5. Accounting
    - Getting MCD K-DAI
    - Getting MCD K-MKR
    - Getting MCD Collateral Tokens
6. Testing
7. Support


## 1.Introduction

Auction Keepers participate in auctions as a result of liquidation events and thereby acquire collateral at attractive prices. An `auction-keeper` can participate in three different types of auctions:

1. [Collateral Auction (`flip`)](https://github.com/makerdao/dss/blob/master/src/flip.sol)
2. [Surplus Auction (`flap`)](https://github.com/makerdao/dss/blob/master/src/flap.sol)
3. [Debt Auction (`flop`)](https://github.com/makerdao/dss/blob/master/src/flop.sol)

Auction Keepers have the unique ability to plug in external *bidding models*, which communicate information to the Keeper on when and how high to bid (these types of Keepers can be left safely running in the background). Shortly after an Auction Keeper notices or starts a new auction, it will spawn a new instance of a *bidding model* and act according to its specified instructions. Bidding models will be automatically terminated by the Auction Keeper the moment the auction expires.

**Note:**

Auction Keepers will automatically call `deal` (claiming a winning bid / settling a completed auction) if the Keeper's address won the auction.

## Auction Keeper Architecture

As mentioned above, Auction Keepers directly interact with `Flipper`, `Flapper` and `Flopper` auction contracts deployed to the Ethereum mainnet. All decisions which involve pricing details are delegated to the *bidding models*. The Bidding models are simply executable strategies, external to the main `auction-keeper` process. This means that the bidding models themselves do not have to know anything about the Ethereum blockchain and its smart contracts, as they can be implemented in basically any programming language. However, they do need to have the ability to read and write JSON documents, as this is how they communicate/exchange with `auction-keeper`. It's important to note that as a developer running an Auction Keeper, it is required that you have basic knowledge on how to properly start and configure the auction-keeper. For example, providing startup parameters as keystore / password are required to setup and run a Keeper. Additionally, you should be familiar with the MCD system, as the model will receive auction details from auction-keeper in the form of a JSON message containing keys such as lot, beg, guy, etc.

**Simple Bidding Model Example:**

A simple bidding model could be a shell script which echoes a fixed price (further details below).

## The Purpose of Auction Keepers

**The main purpose of Auction Keepers are:**

- To discover new opportunities and start new auctions.
- To constantly monitor all ongoing auctions.
- To detect auctions started by other participants.
- To Bid on auctions by converting token prices into bids.
- To ensure that instances of *bidding model* are running for each auction type as well as making sure the instances match the current status of their auctions. This ensure that Keepers are bidding according to decisions outlined by the bidding model.

The auction discovery and monitoring mechanisms work by operating as a loop, which initiates on every new block and enumerates all auctions from `1` to `kicks`. When this occurs, even when the *bidding model* decides to send a bid, it will not be processed by the Keeper until the next iteration of that loop. It's important to note that the `auction-keeper` not only monitors existing auctions and discovers new ones, but it also identifies and takes opportunities to create new auctions.

## 2. Bidding Models

## Starting and Stopping Bidding Models

Auction Keeper maintains a collection of child processes, as each *bidding model* is its own dedicated process. New processes (new *bidding model* instances) are spawned by executing a command according to the `--model` command-line parameter. These processes are automatically terminated (via `SIGKILL`) by the keeper shortly after their associated auction expires. Whenever the *bidding model* process dies, it gets automatically re-spawned by the Keeper.

**Example:**

`bin/auction-keeper --model '../my-bidding-model.sh' [...]`

## **Communicating with *bidding models***

Auction Keepers communicate with *bidding models* via their standard input/standard output. Once the process has started and every time the auction state changes, the Keeper sends a one-line JSON document to the **standard input** of the *bidding model.*

A sample JSON message sent from the keeper to the model looks like the:

```JSON
{
    "id": "6",
    "flapper": " 0xf0afc3108bb8f196cf8d076c8c4877a4c53d4e7c ",
    "bid": "7.142857142857142857",
    "lot": "10000.000000000000000000",
    "beg": "1.050000000000000000",
    "guy": "    0x00531a10c4fbd906313768d277585292aa7c923a ",
    "era": 1530530620,
    "tic": 1530541420,
    "end": 1531135256,
    "price": "1400.000000000000000028"
}
```

## Glossary (Bidding Models)

- `id` - auction identifier.
- `flipper` - Ethereum address of the `Flipper` contract (only for `flip` auctions).
- `flapper` - Ethereum address of the `Flapper` contract (only for `flap` auctions).
- `flopper` - Ethereum address of the `Flopper` contract (only for `flop` auctions).
- `bid` - current highest bid (will go up for `flip` and `flap` auctions).
- `lot` - amount being currently auctioned (will go down for `flip` and `flop` auctions).
- `tab` - bid value (not to be confused with the bid price) which will cause the auction to enter the `dent` phase (only for `flip` auctions).
- `beg` - minimum price increment (`1.05` means minimum 5% price increment).
- `guy` - Ethereum address of the current highest bidder.
- `era` - current time (in seconds since the UNIX epoch).
- `tic` - time when the current bid will expire (`None` if no bids yet).
- `end` - time when the entire auction will expire (end is set to `0` if the auction is no longer live).
- `price` - current price being tendered (can be `None` if price is infinity).

---

*Bidding models* should never make an assumption that messages will be sent only when auction state changes. It is perfectly fine for the `auction-keeper` to periodically send the same message(s) to *bidding models*.

At the same time, the `auction-keeper` reads one-line messages from the **standard output** of the *bidding model* process and tries to parse them as JSON documents. It will then extract the two following fields from that document:

- `price` - the maximum (for `flip` and `flop` auctions) or the minimum (for `flap` auctions) price the model is willing to bid.
- `gasPrice` (optional) - gas price in Wei to use when sending a bid.

An example of a message sent from the Bidding Model to the Auction Keeper may look like:

```JSON
{
    "price": "150.0",
    "gasPrice": 7000000000
}
```

In the case of when Auction Keepers and Bidding Models communicate in terms of prices, it is the MKR/DAI price (for `flap` and `flop` auctions) or the collateral price expressed in DAI for `flip` auctions (for example, OMG/DAI).

Any messages written by a Bidding Model to **stderr** (standard error) will be passed through by the Auction Keeper to its logs. This is the most convenient way of implementing logging from Bidding Models.

## 3. Setting up the Auction Keeper Bot (Installation)

### Prerequisite

- Git
- [Python v3.6.6](https://www.python.org/downloads/release/python-366/)
- [virtualenv](https://virtualenv.pypa.io/en/latest/)
  - This project requires *virtualenv* to be installed if you want to use Maker's python tools. This helps to ensure that you are running the right version of python as well as check that all of the pip packages that are installed in the [install.sh](http://install.sh) are in the right place and have the correct versions.
- [X-code](https://apps.apple.com/ca/app/xcode/id497799835?mt=12) (for Macs)
- [Docker-Compose](https://docs.docker.com/compose/install/)

## Getting Started

### Installation from source

**1. Clone the `auction-keeper` repository:**

```bash
git clone https://github.com/makerdao/auction-keeper.git
```

**2. Switch into the `auction-keeper` directory:**

```bash
cd auction-keeper
```

**3. Install required third-party packages:**

```bash
git submodule update --init --recursive
```

**4. Set up the virtual env and activate it:**

```bash
python3 -m venv _virtualenv
source _virtualenv/bin/activate
```

**5. Install requirements:**

```bash
pip3 install -r requirements.txt
```

### Potential Errors

- Needing to upgrade pip version to 19.2.2:
- Fix by running `pip install --upgrade pip`.

For other known Ubuntu and macOS issues please visit the [pymaker](https://github.com/makerdao/pymaker) README.

## 4. Running your Keeper Bot

### The Kovan version runs on the [Kovan Release 1.0.2](https://changelog.makerdao.com/releases/kovan/1.0.2/index.html)

To change to your chosen version of the kovan release, copy/paste your preferred contract addresses in `kovan-addresses.json` in `lib/pymaker/config/kovan-addresses.json`

### 1. Creating your bidding model (an example detailing the simplest possible bidding model)

The stdout (standard output) provides a price for the collateral (for `flip` auctions) or MKR (for `flap` and `flop` auctions). The `sleep` locks the price in place for a minute, after which the keeper will restart the price model and read a new price (consider this your price update interval).

The simplest possible *bidding model* you can set up is when you use a fixed price for each auction. For example:

```bash
#!/usr/bin/env bash
echo "{\"price\": \"150.0\"}" # put your desired fixed price amount here
sleep 60 # locking the price for a 60 seconds period
```

Once you have created your bidding model, save it as `model-eth.sh` (or whatever name you feel seems appropriate).

### 2. Setting up an Auction Keeper for a Collateral (Flip) Auction

Collateral Auctions will be the most common type of auction that the community will want to create and operate Auction keepers for. This is due to the fact that Collateral auctions will occur much more frequently than Flap and Flop auctions.

**Example (Flip Auction Keeper):**

- This example/process assumes that the user has an already existing shell script that manages their environment and connects to the Ethereum blockchain and that you have some Dai and Kovan ETH in your wallet. If you don't have any balance, check the section below on how to get some.

An example on how to set up your environment: as `my_environment.sh`

```bash
SERVER_ETH_RPC_HOST=https://your-ethereum-node
SERVER_ETH_RPC_PORT=8545
ACCOUNT_ADDRESS=0x16Fb96a5f-your-eth-address-70231c8154saf
ACCOUNT_KEY="key_file=/Users/username/Documents/Keeper/accounts/keystore,pass_file=/Users/username/Documents/keeper/accounts/pass"
```

`SERVER_ETH_RPC_HOST` - Should not be an infura node, as it doesn't provide all the functionality that the python script needs
`ACCOUNT_KEY` - Should have the absolute path to the keystore and password file. Define the path as shown above, as the python script will parse through both the keystore and password files.  

```bash
#!/bin/bash
dir="$(dirname "$0")"

source my_environment.sh  # Set the RPC host, account address, and keys.
source _virtualenv/bin/activate # Run virtual environment

# Allows keepers to bid different prices
MODEL=$1

bin/auction-keeper \
    --rpc-host ${SERVER_ETH_RPC_HOST:?}:${SERVER_ETH_RPC_PORT:?} \
    --rpc-timeout 30 \
    --eth-from ${ACCOUNT_ADDRESS:?} \
    --eth-key ${ACCOUNT_KEY:?} \
    --type flip \
    --ilk ETH-A \
    --from-block 14764534 \
    --vat-dai-target 1000 \
    --model ${dir}/${MODEL} \
    2> >(tee -a -i auction-keeper-flip-ETH-A.log >&2)
```

Once finalized, you should save your script to run your Auction Keeper as `flip-eth-a.sh` (or something similar to identify that this Auction Keeper is for a Flip Auction).
In addition, make sure to verify the above copy+pasted script doesn't create extra spaces or characters on pasting+saving in your editor. You will notice an error when running it later below otherwise.

**Notes on dynamic gas pricing:**

If you want to use a dynamic gas price, for example to ensure the Keeper can still post transaction during network congestion, you can pass on an ETH Gas Station API key to the keeper using `--ethgasstation-api-key` in the config above. You can get a free API key by signing up at <https://data.concourseopen.com/>

**Important Note about Running Auction Keepers on the Ethereum Mainnet:**

- If you get to the point where the auction keeper bot is not accepting mainnet as a valid argument, this is because there is no `network` parameter. To fix this, just omit that parameter.

**Other Notes:**

- All Collateral types (`ilk`'s) combine the name of the token and a letter corresponding to a set of risk parameters. For example, as you can see above, the example uses ETH-A. Note that ETH-A and ETH-B are two different collateral types for the same underlying token (WETH) but have different risk parameters.
- For the MCD addresses, you simply pass `--network kovan` in and it will load the required JSON files bundled within auction-keeper (or pymaker).

### 3. Passing the bidding the model as an argument to the Keeper script

1. Confirm that both your bidding model (model-eth.sh) and your script (flip-eth-a.sh) to run your Auction Keeper are saved.
2. The next step is to `chmod +x` both of them.
3. Lastly, run `flip-eth-a.sh model-eth.sh` to pass your bidding model into your Auction Keeper script.

Example of a working keeper:
After running the `./flip-eth-a.sh model-eth.sh` command you will see an output like this:

```bash
019-10-31 13:33:08,703 INFO     Keeper connected to RPC connection https://parity0.kovan.makerfoundation.com:8545
2019-10-31 13:33:08,703 INFO     Keeper operating as 0x16Fb96a5fa0427Af0C8F7cF1eB4870231c8154B6
2019-10-31 13:33:09,044 INFO     Executing keeper startup logic
2019-10-31 13:33:09,923 INFO     Sent transaction DSToken('0x1D7e3a1A65a367db1D1D3F51A54aC01a2c4C92ff').approve(address,uint256)('0x9E0d5a6a836a6C323Cf45Eb07Cb40CFc81664eec', 115792089237316195423570985008687907853269984665640564039457584007913129639935) with nonce=1257, gas=125158, gas_price=default (tx_hash=0xc935e3a95e5d0839e703dd69b6cb2d8f9a9d3d5cd34571259e36e771ce2201b7)
2019-10-31 13:33:12,964 INFO     Transaction DSToken('0x1D7e3a1A65a367db1D1D3F51A54aC01a2c4C92ff').approve(address,uint256)('0x9E0d5a6a836a6C323Cf45Eb07Cb40CFc81664eec', 115792089237316195423570985008687907853269984665640564039457584007913129639935) was successful (tx_hash=0xc935e3a95e5d0839e703dd69b6cb2d8f9a9d3d5cd34571259e36e771ce2201b7)
2019-10-31 13:33:13,152 WARNING  Insufficient balance to maintain Dai target; joining 91.319080635247876480 Dai to the Vat
2019-10-31 13:33:13,751 INFO     Sent transaction <pymaker.dss.DaiJoin object at 0x7fa6e91baf28>.join('0x16Fb96a5fa0427Af0C8F7cF1eB4870231c8154B6', 91319080635247876480) with nonce=1258, gas=165404, gas_price=default (tx_hash=0xcce12af8d27f9d6185db4b359b8f3216ee783250a1f3b3921256efabb63e22b0)
2019-10-31 13:33:16,491 INFO     Transaction <pymaker.dss.DaiJoin object at 0x7fa6e91baf28>.join('0x16Fb96a5fa0427Af0C8F7cF1eB4870231c8154B6', 91319080635247876480) was successful (tx_hash=0xcce12af8d27f9d6185db4b359b8f3216ee783250a1f3b3921256efabb63e22b0)
2019-10-31 13:33:16,585 INFO     Dai token balance: 0.000000000000000000, Vat balance: 91.319080635247876480133691494546726938904901298
2019-10-31 13:33:16,586 INFO     Watching for new blocks
2019-10-31 13:33:16,587 INFO     Started 1 timer(s)
```

Now the keeper is actively listening for any action. If it sees an undercollateralized position, then it will try to bid for it.

### Auction Keeper Arguments Explained

To participate in all auctions, a separate keeper must be configured for `flip` of each collateral type, as well as one for `flap` and another for `flop`.

1. `--type` - the type of auction the keeper is used for. In this particular scenario, it will be set to `flip`.
2. `--ilk` - the type of collateral.  
3. `--addresses` - .json of all of the addresses of the MCD contracts as well as the collateral types allowed/used in the system.
4. `--vat-dai-target` - the amount of DAI which the keeper will attempt to maintain in the Vat, to use for bidding. It will rebalance it upon keeper startup and upon `deal`ing an auction.
5. `--model` - the bidding model that will be used for bidding.  
6. `--from-block` to the block where the first urn was created to instruct the keeper to use logs published by the vat contract to bulid a list of urns, and then check the status of each urn.

Call `bin/auction-keeper --help` for a complete list of arguments.

## Auction Keeper Limitations

- If an auction starts before the auction Keeper has started, the Keeper will not participate in the auction until the next block has been mined.
- Keepers do not explicitly handle global settlement (`End`). If global settlement occurs while a winning bid is outstanding, the Keeper will not request a `yank` to refund the bid. The workaround is to call `yank` directly using `seth`.
- There are some Keeper functions that incur gas fees regardless of whether a bid is submitted. This includes, but is not limited to, the following actions:
- Submitting approvals.
- Adjusting the balance of surplus to debt.
- Biting a CDP or starting a flap or flop auction, even if insufficient funds exist to participate in the auction.
- The Keeper will not check model prices until an auction officially exists. As such, it will `kick`, `flap`, or `flop` in response to opportunities regardless of whether or not your DAI or MKR balance is sufficient to participate. This imposes a gas fee that must be paid.
- After procuring more DAI, the Keeper must be restarted to add it to the `Vat`.

## 5. Accounting

The Auction contracts exclusively interact with DAI (for all auctions types) and collateral (for `flip` auctions) in the `Vat`. More explicitly speaking:

- The DAI that is used to bid on auctions is withdrawn from the `Vat`.
- The Collateral and surplus DAI won at auction end is placed in the `Vat`.

By default, all the DAI and collateral within your `eth-from` account is `exit`'ed from the Vat and added to your account token balance when the Keeper is shut down. Note that this feature may be disabled using the `keep-dai-in-vat-on-exit` and `keep-gem-in-vat-on-exit` switches, respectively. The use of an `eth-from` account with an open CDP is discouraged, as debt will hinder the auction contracts' ability to access your DAI, and the `auction-keeper`'s ability to `exit` DAI from the `Vat`.

When running multiple Auction Keepers using the same account, the balance of DAI in the `Vat` will be shared across all of the Keepers. If using this feature, you should set `--vat-dai-target` to the same value for each Keeper, as well as sufficiently high in order to cover total desired exposure.

**Note:**

MKR used to bid on `flap` auctions is directly withdrawn from your token balance. The MKR won at `flop` auctions is directly deposited to your token balance.

## Getting Kovan MCD DAI, MKR and other Collateral tokens

### 1. Getting MCD K-DAI (K-MCD 0.2.12 Release)

**Contract address**: `0xb64964e9c0b658aa7b448cdbddfcdccab26cc584`

1. Log into your MetaMask account from the browser extension. Add or confirm that the custom MCD K-DAI token is added to your list of tokens.
    - This done by selecting "Add Token" and then by adding in the details under the "Custom token" option.

2. Head to Oasis Borrow [here](https://oasis.app/borrow/?network=kovan).
   - Confirm that you are in fact on the Kovan Network before proceeding.

3. Connect your MetaMask account.

4. Approve the MetaMask connection.

5. Below the "Overview" button, find and select the plus sign button to start setting up your CDP.

6. Select the collateral type you want to proceed with and click "Continue".
   - e.g. ETH-A
7. Deposit your K-ETH and generate K-DAI by selecting and inputing an amount of K-ETH and the amount of K-DAI you would like to generate. To proceed, click "Continue".
   - e.g. Deposit 0.5 K-ETH and generate 100 DAI.

8. Click on the checkbox to confirm that you have read and accepted the **Terms of Service** then click the "Create CDP" button.

9. Approve the transaction in your MetaMask extension.

10. Click the "Exit" button and wait for your CDP to be created.

After all of these steps have been completed, you will have the generated MCD K-DAI  and it will be present within your wallet. You can easily payback your DAI or generate more.

### 2. Getting MCD K-MKR (K-MCD 1.0.2 Release)

**Contract address:** `0xaaf64bfcc32d0f15873a02163e7e500671a4ffcd`

This requires familiarity with Seth as well as having the tool set up on your local machine. If unfamiliar, use [this](https://github.com/makerdao/developerguides/blob/master/devtools/seth/seth-guide-01/seth-guide-01.md) guide to install and set it up.

**Run the following command in Seth:**

```bash
seth send 0xcbd3e165ce589657fefd2d38ad6b6596a1f734f6 'gulp(address)' 0xaaf64bfcc32d0f15873a02163e7e500671a4ffcd
```

**Address information:**

- The `0x94598157fcf0715c3bc9b4a35450cce82ac57b20` address is the faucet that issues 1 MKR per request.
- The `0xaaf64bfcc32d0f15873a02163e7e500671a4ffcd` address is that of the MCD K-MKR token. It will issue 1 MKR.

**Important Note:** The faucet address and token addresses often change with each dss deployment. The current addresses displayed above are from the **0.2.12 Release**. Please visit [https://changelog.makerdao.com/](https://changelog.makerdao.com/) for the most updated release version.

Please refer to this [guide](https://github.com/makerdao/developerguides/blob/master/mcd/mcd-seth/mcd-seth-01.md#getting-tokens) to obtain collateral test tokens for Kovan.

### 3. Getting MCD Collateral Tokens

## 6. Testing your Keeper

To help with the testing of your Auction Keeper, there is a collection of python and shell scripts herein that may be used to test `auction-keeper`, `pymaker`'s auction facilities, and relevant smart contracts in `dss`. For more information about testing your Auction Keeper with your own testchain visit [tests/manual/README](https://github.com/makerdao/auction-keeper/blob/master/tests/manual/README.md).

## 7. Support

Questions or concerns about the Auction Keepers are welcome in the [#keeper](https://chat.makerdao.com/channel/keeper) channel in the Maker Chat.

## Disclaimer

You (meaning any individual or entity accessing, using or both the software included in this Github repository) expressly understand and agree that your use of the software is at your sole risk. The software in this Github repository is provided “as is”, without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement. In no event shall the authors or copyright holders be liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the software or the use or other dealings in the software. You release authors or copyright holders from all liability for you having acquired or not acquired content in this GitHub repository. The authors or copyright holders make no representations concerning any content contained in or accessed through the service, and the authors or copyright holders will not be responsible or liable for the accuracy, copyright compliance, legality or decency of material contained in or accessed through this GitHub repository.
