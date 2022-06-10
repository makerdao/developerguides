---
title: How to deploy MCD Protocol
description: Learn how to deploy your own MCD
parent: mcd
tags:
  - deployment
  - mcd
slug: how-to-deploy-mcd
contentType: guides
root: false
---

# How to deploy MCD Protocol

**Level:** Intermediate  
**Estimated Time:** 30 - 45 min

- [How to deploy MCD Protocol](#how-to-deploy-mcd-protocol)
  - [Overview](#overview)
  - [Learning Objectives](#learning-objectives)
  - [Pre-requisites](#pre-requisites)
    - [Dependencies](#dependencies)
  - [Sections](#sections)
    - [Installation](#installation)
      - [Ethereum node](#ethereum-node)
    - [Tokens deplyoment (Optional)](#tokens-deplyoment-optional)
    - [Configuration](#configuration)
      - [Account configuration](#account-configuration)
      - [Chain configuration](#chain-configuration)
        - [Note](#note)
      - [Note](#note-1)
    - [MCD Deployment process](#mcd-deployment-process)
      - [Deploy on local testchain with default config file](#deploy-on-local-testchain-with-default-config-file)
      - [Deploy on Goerli with default config file](#deploy-on-goerli-with-default-config-file)
      - [Deploy on Mainnet with default config file](#deploy-on-mainnet-with-default-config-file)
      - [Deploy on any network passing a custom config file](#deploy-on-any-network-passing-a-custom-config-file)
      - [Output](#output)
      - [Helper scripts](#helper-scripts)
  - [Smart Contract Dependencies](#smart-contract-dependencies)
  - [Additional Resources](#additional-resources)

## Overview

This guide will walk you through deploying MCD protocol to your prefered network.

## Learning Objectives

Here you’ll learn how to deploy your own MCD protocol.

- MCD deployment configuration
- Deployment process

## Pre-requisites

Knowledge in:

- [dapp.tools](http://dapp.tools/)
- [makerdao/dss-deploy-scripts](https://github.com/makerdao/dss-deploy-scripts)
- Testnet ETH kovan/rinkeby/ropsten/goerli

### Dependencies

We need to have `nix` and `dapp.tools` installed on our machine.

- Install `nix`: You can use these [instructions](https://nixos.org/download.html)
- Install `dapp.tools`: ```curl https://dapp.tools/install | sh```

## Sections

### Installation

First of all we will need to clone `dss-deploy-script` repo:

```bash
git clone https://github.com/makerdao/dss-deploy-scripts.git
cd dss-deploy-scripts
```

The only way to install everything necessary to deploy MCD we need to run

```bash
nix-shell --pure
```

to drop into a Bash shell with all dependencies installed.

#### Ethereum node

You'll also need an Ethereum RPC node to connect to. Depending on your usecase, this could be a local node or a remote one.

### Tokens deplyoment (Optional)

To fully control the tokens that are used in `MCD`, it’s recommended that you deploy and set their prices manually with the help of:

- [dapphub/ds-token: A simple and sufficient ERC20 implementation](https://github.com/dapphub/ds-token) for token deployment
- [dapphub/ds-value: Set and get a value](https://github.com/dapphub/ds-value) for token price value definition

After all preferred tokens and their respective price contract are deployed, you can update the `<NETWORK>.json` file in [config](https://github.com/makerdao/dss-deploy-scripts) folder.

### Configuration

There are 2 main pieces of configuration necessary for a deployment:

- [Ethereum account configuration](#account-configuration)
- [Chain configuration](#chain-configuration)

#### Account configuration

`Seth` relies on the presence of environment variables to know which Ethereum account to use, which RPC server to talk to, etc.

If you're using `nix-shell`, these variables are set automatically for you in [shell.nix](https://github.com/makerdao/dss-deploy-scripts/blob/master/shell.nix).

But you can also configure the variables below variables manually:

- `ETH_FROM`: address of the deployer.
- `ETH_PASSWORD`: path of the account password file, if you don't set this, it will prompt you for your password every transaction.
- `ETH_KEYSTORE`: keystore directory, if you are using the default `~/.ethereum/keystore/`, you don't need to set it.
- `ETH_RPC_URL`: URL of the RPC node.

#### Chain configuration

Some networks have a default config file at `config/<NETWORK>.json`, which will be used if non custom config values are set. A config file can be passed via param with flag -f allowing to execute the script in any network (e.g. `dss-deploy testchain -f <CONFIG_FILE_PATH>`). As other option, custom config values can be loaded as an environment variable called `DDS_CONFIG_VALUES`. File passed by parameter overwrites the environment variable.

Below is the expected structure of such a config file:

```json
{
  "description": "",
  "omniaFromAddr": "<Address being used by Omnia Service (only for testchain)>",
  "omniaAmount": "<Amount in ETH to be sent to Omnia Address (only for testchain)>",
  "pauseDelay": "<Delay of Pause contract in seconds>",
  "vat_line": "<General debt ceiling in DAI unit>",
  "vow_wait": "<Flop delay in seconds>",
  "vow_sump": "<Flop fixed bid size in DAI unit>",
  "vow_dump": "<Flop initial lot size in MKR unit>",
  "vow_bump": "<Flap fixed lot size in DAI unit>",
  "vow_hump": "<Flap Surplus buffer in DAI unit>",
  "cat_box": "<Max total DAI needed to cover all debt plus penalty fees on active Flip auctions in DAI unit>",
  "dog_hole": "<Max total DAI needed to cover all debt plus penalty fees on active Clip auctions in DAI unit>",
  "jug_base": "<Base component of stability fee in percentage per year (e.g. 2.5)>",
  "pot_dsr": "<Dai Savings Rate in percentage per year (e.g. 2.5)>",
  "end_wait": "<Global Settlement cooldown period in seconds>",
  "esm_pit": "<Pit address to send MKR to be burnt when ESM is fired>",
  "esm_min": "<Minimum amount to trigger ESM in MKR unit>",
  "flap_beg": "<Minimum bid increase in percentage (e.g. 5.5)>",
  "flap_ttl": "<Max time between bids in seconds>",
  "flap_tau": "<Max auction duration in seconds>",
  "flop_beg": "<Minimum bid increase in percentage (e.g. 5.5)>",
  "flop_pad": "<Increase of lot size after `tick` in percentage (e.g. 50)>",
  "flop_ttl": "<Max time between bids in seconds>",
  "flop_tau": "<Max auction duration in seconds>",
  "flap_lid": "<Max amount of DAI that can be put up for sale at the same time in DAI unit (e.g. 1000000)>",
  "flash_max": "<Max DAI can be borrowed from flash loan module in DAI unit (e.g. 1000000)>",
  "flash_toll": "<Fee being charged from amount being borrow via flash loan module in percentage (e.g 0.1%)>",
  "import": {
    "gov": "<GOV token address (if there is an existing one to import)> note: make sure to mint enough tokens for launch",
    "authority": "<Authority address (if there is an existing one to import)> note: make sure to launch MCD_ADMIN",
    "proxyRegistry": "<Proxy Registry address (if there is an existing one to import)>",
    "faucet": "<Faucet address (if there is an existing one to import)>"
  },
  "tokens": {
    "<ETH|COL>": {
      "import": {
        "gem": "<Gem token address (if there is an existing one to import)>",
        "pip": "<Price feed address (if there is an existing one to import)>"
      },
      "gemDeploy": { // Only used if there is not a gem imported
        "src": "<REPO/CONTRACT (e.g. dss-gem-joins/GemJoin2)>",
        "params": [<Any params to be passed to the constructor of the token in its native form (e.g. amounts in wei or strings in hex encoding)>],
        "faucetSupply": "<Amount of token to be transferred to the faucet>",
        "faucetAmount": "<Amount of token to be obtained in each faucet gulp (only if a new faucet is deployed)>"
      },
      "joinDeploy": { // Mandatory always
        "src": "<GemJoin/GemJoin2/GemJoinX>",
        "extraParams": [<Any extra params to be passed to the constructor of the join in its native form (e.g. amounts in wei or strings in hex encoding)>]
      },
      "pipDeploy": { // Only used if there is not a pip imported
        "osmDelay": "<Time in seconds for the OSM delay>",
        "type": "<median|value>",
        "price": "<Initial oracle price (only if type == "value")>",
        "signers": [
            <Set of signer addreeses (only if type == "median")>
        ]
      },
      "ilks": {
        "A": {
          "mat": "<Liquidation ratio value in percentage (e.g. 150)>",
          "line": "<Debt ceiling value in DAI unit (won't be used if autoLine is > 0)>",
          "autoLine": "<Max debt ceiling value in DAI unit (for DssAutoLine IAM)>",
          "autoLineGap": "<Value to set the ceiling over the current ilk debt in DAI unit (for DssAutoLine IAM)>",
          "autoLineTtl": "<Time between debt ceiling increments (for DssAutoLine IAM)>",
          "dust": "<Min amount of debt a CDP can hold in DAI unit>"
          "duty": "<Collateral component of stability fee in percentage per year (e.g. 2.5)>",
          "flipDeploy": {
            "chop": "<Liquidation penalty value in percentage (e.g. 12.5)>",
            "dunk": "<Liquidation Quantity in DAI Unit>",
            "beg": "<Minimum bid increase in percentage (e.g. 5.5)>",
            "ttl": "<Max time between bids in seconds>",
            "tau": "<Max auction duration in seconds>"
          },
          "clipDeploy": { // Will be used only if there isn't a flipDeploy
            "chop": "<Liquidation penalty value in percentage (e.g. 12.5)>",
            "hole": "<Max DAI needed to cover debt+fees of active auctions per ilk (e.g. 100,000 DAI)>",
            "chip": "<Percentage of due to suck from vow to incentivize keepers (e.g. 2%)>",
            "tip": "<Flat fee to suck from vow to incentivize keepers (e.g. 100 DAI)>",
            "buf": "<Multiplicative factor to increase starting price (e.g. 125%)>",
            "tail": "<Time elapsed before auction reset in seconds>",
            "cusp": "<Percentage taken for the new price before auction reset (e.g. 30%)>",
            "calc": {
              "type": "LinearDecrease/StairstepExponentialDecrease/ExponentialDecrease",
              "tau":  "<Time after auction start when the price reaches zero in seconds (LinearDecrease)>",
              "step": "<Length of time between price drops in seconds (StairstepExponentialDecrease)>",
              "cut":  "<Percentage to be taken as new price per step (e.g. 99%, which is 1% drop) (StairstepExponentialDecrease/ExponentialDecrease)>"
            },
            "cm_tolerance": "<Percentage of previous price which a drop would enable anyone to be able to circuit break the liquidator via ClipperMom (e.g. 50%)>"
          }
        }
      }
    }
  }
}
```

##### Note

Make sure to launch `MCD_ADMIN` if you are providing it in `config.authority`.

```bash
sethSend "$MCD_GOV" 'mint(address,uint256)' $ETH_FROM $(seth --to-wei 1000000 ETH)
```

#### Note

Make sure to launch `MCD_ADMIN` if you are providing it in `config.authority`.

```bash
# lock enough MKR (80,000 MKR threshold)
sethSend "$MCD_GOV" "approve(address,uint256)" "$MCD_ADM" $(seth --to-wei 80000 ETH)
sethSend "$MCD_ADM" "lock(uint256)" $(seth --to-wei 80000 ETH)
sethSend "$MCD_ADM" "vote(address[])" "[0x0000000000000000000000000000000000000000]"
sethSend "$MCD_ADM" "launch()"
```

### MCD Deployment process

Currently, there are default config files for 3 networks:

- [Local testchain](https://github.com/makerdao/dss-deploy-scripts/blob/master/config/testchain.json)
- [Goerli](https://github.com/makerdao/dss-deploy-scripts/blob/master/config/goerli.json)
- [Mainnet](https://github.com/makerdao/dss-deploy-scripts/blob/master/config/main.json)

#### Deploy on local testchain with default config file

```bash
dss-deploy testchain
```

#### Deploy on Goerli with default config file

```bash
dss-deploy goerli
```

#### Deploy on Mainnet with default config file

```bash
dss-deploy main
```

#### Deploy on any network passing a custom config file

```bash
dss-deploy <NETWORK> -f <CONFIG_FILE_PATH>
```

#### Output

Successful deployments save their output to the following files:

- `out/addresses.json`: addresses of all deployed contracts
- `out/config.json`: copy of the configuration file used for the deployment
- `out/abi/`: JSON representation of the ABIs of all deployed contracts
- `out/bin/`: .bin and .bin-runtime files of all deployed contracts
- `out/meta/`: meta.json files of all deployed contracts
- `out/dss-<NETWORK>.log`: output log of deployment

#### Helper scripts

The `auth-checker` script loads the addresses from `out/addresses.json` and the config file from `out/config.json` and verifies that the deployed authorizations match what is expected.

## Smart Contract Dependencies

To update smart contract dependencies use dapp2nix:

```bash
nix-shell --pure
dapp2nix help
dapp2nix list
dapp2nix up vote-proxy <COMMIT_HASH>
```

To clone smart contract dependencies into working directory run:

```bash
dapp2nix clone-recursive contracts
```

## Additional Resources

- [dss-deploy repo](https://github.com/makerdao/dss-deploy)
- `dss` is documented in the [wiki](https://github.com/makerdao/dss/wiki) and in [DEVELOPING.md](https://github.com/makerdao/dss/blob/master/DEVELOPING.md)
