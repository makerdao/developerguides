---
title: Dai Token
description: Learm about Dai and integrate it into applications
parent: dai
tags:
  - dai
	- ERC20 contract
slug: dai-token
contentType: guides
root: false
---

# Dai Token

**Level**: Beginner

**Estimated Time**: 30 - 60 minutes

- [Dai Token](#dai-token)
  - [Overview](#overview)
  - [Learning Objectives](#learning-objectives)
  - [Pre-requisites](#pre-requisites)
  - [Guide](#guide)
    - [Token Info](#token-info)
      - [Addresses](#addresses)
      - [Details](#details)
      - [Token stats](#token-stats)
    - [Getting Dai](#getting-dai)
      - [Mainnet](#mainnet)
      - [Testnet](#testnet)
    - [Token Contract](#token-contract)
      - [Permit](#permit)
      - [Mint and Burn](#mint-and-burn)
      - [Aliases](#aliases)
      - [Authority](#authority)
    - [DaiJoin Adapter](#daijoin-adapter)
    - [**Emergency Shutdown**](#emergency-shutdown)
    - [Deploy on testnet](#deploy-on-testnet)
  - [Summary](#summary)
  - [Additional resources](#additional-resources)
  - [Help](#help)

## Overview

Dai is a decentralized, unbiased, collateral-backed cryptocurrency soft-pegged to the US Dollar. Resistant to hyperinflation due to its low volatility, Dai offers economic freedom and opportunity to anyone, anywhere.

The token contract conforms to the ERC20 token standard which allows wallets, exchanges, and other applications to easily integrate with minimal effort. This guide will be useful to developers integrating Dai in applications like wallets, exchanges, and smart contracts to get a better understanding of the token contract and its functionality.

## Learning Objectives

- You will learn basic information about the token.

- Understand the additional functions supported by the token contract.

- Deploy your own token to an Ethereum testnet.

- Integrate the Dai token effectively with your application.

## Pre-requisites

- Knowledge of the [ERC20](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md) token standard.

- Ability to send ethereum transactions from your preferred dev environment.

## Guide

### Token Info

#### Addresses

Dai is available on the:

- _Ethereum mainnet_ at [0x6B175474E89094C44Da98b954EedeAC495271d0F](https://etherscan.io/token/0x6B175474E89094C44Da98b954EedeAC495271d0F)
- _Kovan testnet_ at [0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa](https://kovan.etherscan.io/token/0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa)

Other deployments are listed on [changelog.makerdao.com](https://changelog.makerdao.com).

#### Details

The *symbol* field is set to ‘DAI’ and the *name* field is currently set to ‘Dai Stablecoin’.

Token precision field *decimals* is set to 18 like most other ERC20 tokens.

In addition, the contract has the `version` field set to 1. This field is a constant, so once the contract is deployed, this field cannot be changed. This field is added for use in the `permit()` function in the contract. And this variable is part of the [EIP-712]([https://eips.ethereum.org/EIPS/eip-712](https://eips.ethereum.org/EIPS/eip-712)) signing standard. Read more on the `permit()` function below.

#### Token stats

Multi Collateral Dai has been live on the Ethereum mainnet since November 18, 2019 and its current total supply can be viewed on [DaiStats](https://daistats.com/).

The system internally uses 1 USD as the target price of Dai when new Dai is generated or burned through the Maker Vaults, but the market price of the token could vary based on a variety of conditions like exchange liquidity, trading pair etc.

Care should be taken before using the price of Dai directly reported by sources like [CoinMarketCap](https://coinmarketcap.com/currencies/dai/), because exchange bugs may produce unreasonable price data. In many scenarios, such as displaying the value of Dai in a wallet, it is perfectly fine to hard code the price of a token to 1 USD.

### Getting Dai

#### Mainnet

Dai can be purchased with Ether on many popular exchanges, which many are listed on [https://coinmarketcap.com/currencies/multi-collateral-dai/markets/](https://coinmarketcap.com/currencies/multi-collateral-dai/markets/). It is also available on many decentralized exchanges like [Oasis](https://oasis.app/trade/), [KyberSwap](https://kyberswap.com/), and [Uniswap](https://uniswap.exchange/).

You can also generate Dai by opening a Vault with [https://oasis.app/](https://oasis.app/).

#### Testnet

There are no Dai faucet on testnets, but you can generate your own Dai on the major Ethereum testnets: Goerli, Kovan, Rinkeby and Ropsten. After having obtained testnet-ETH, you can head over to [Oasis](%5B%3Chttps://oasis.app/?network=kovan%3E%5D(%3Chttps://oasis.app/?network=kovan%3E)) and open a Vault. Make sure to change the `?network=<networkName>` parameter to your preferred network

Alternatively, if you're more comfortable with cli-tools, then you can the [seth guide](%5B%3Chttps://github.com/makerdao/developerguides/blob/master/mcd/mcd-seth/mcd-seth-01.md%3E%5D(%3Chttps://github.com/makerdao/developerguides/blob/master/mcd/mcd-seth/mcd-seth-01.md%3E)).

Another option is to buy Kovan Dai with Kovan ETH on [Oasis Trade](https://oasis.app/trade) if there is sufficient liquidity available.

### Token Contract

The codebase at commit [6fa5581](https://github.com/makerdao/dss/blob/6fa55812a5fcfcfa325ad4d9a4d0ca4033c38cab/src/dai.sol) was used for deployments on mainnet.

The Dai token contract, follows the [ERC-20 standard](%5B%3Chttps://eips.ethereum.org/EIPS/eip-20%3E%5D(%3Chttps://eips.ethereum.org/EIPS/eip-20%3E)) with some additional features. The added features are

- The `permit()` function that uses the [EIP-712 signing standard](%5B%3Chttps://eips.ethereum.org/EIPS/eip-712%3E%5D(%3Chttps://eips.ethereum.org/EIPS/eip-712%3E)) as defined by [EIP-2612 (draft](https://github.com/ethereum/EIPs/blob/8a34d644aacf0f9f8f00815307fd7dd5da07655f/EIPS/eip-2612.md)).
- The `mint()` and `burn()` functions that the Maker Protocol is authorised to use.

#### Permit

The EIP-712 signing standard allows to sign structured typed data instead of just byte strings. This allows in the creation of the `permit()` function. The `permit()` function allows the user to send Dai without paying gas. This works as follows:

- User signs a `permit` message allowing a `destination` address to withdraw an amount of Dai from his wallet.
- This message is read by a relayer that takes the signed message and processes it by paying the transaction fee for the user. This relayer then takes a Dai cut from the user for processing the transaction.
- The user can send Dai by paying for the transaction fee with Dai, while a relayer in the backend is doing the processing.

Check [https://stablecoin.services/](https://stablecoin.services/) and [https://gasless.mosendo.com/](https://gasless.mosendo.com/) for live examples. The EIP for this functionnality is currently in [draft](https://github.com/ethereum/EIPs/blob/8a34d644aacf0f9f8f00815307fd7dd5da07655f/EIPS/eip-2612.md).

#### Mint and Burn

Tokens are created when a user adds collateral to their Vault and generates new Dai from it. Tokens are burned, when the same user pays back the same amount of Dai they’ve previously issued for the system to remove them from the supply to free  their locked collateral back. Also `mint` and `burn` functions are used when user deposits and withdraws Dai from the Dai Savings Rate contract.

The [MCD_DAI_JOIN](https://etherscan.io/address/0x9759a6ac90977b93b58547b4a71c78317f391a28#code) adapter contract in the Maker Protocol is authorized to calls the mint and burn functions of Dai token which to increase or decrease the total supply.

- `mint` has the function signature: `mint(address guy, uint wad)`. It increases the total supply of the token as well as the `guy`’s token balance by the `wad` amount. All calls to `mint()` originate from the `exit()` function on the [DaiJoin](https://etherscan.io/address/0x9759a6ac90977b93b58547b4a71c78317f391a28#code) contract.
- `burn` has the function signature: `burn(address guy, uint wad)`. It decreases the total supply of the token as well as the `guy`’s token balance by the `wad` amount. Calls to `burn()` originate from `join()` function on the [DaiJoin](https://etherscan.io/address/0x9759a6ac90977b93b58547b4a71c78317f391a28#code) contract. Contrary to Mint, Burn is not restricted to DaiJoin, this means that any user if he intends to do so, can burn his Dai. This however is not recommended.

#### Aliases

The `transferFrom()` function has a few aliases available: `push`, `pull`, and `move`. These are available if function caller doesn't want to specify `msg.sender` parameter in the function call.

#### Authority

Some functions in the Dai contract can only be called by an authorized address. This address can be an externally owned account (EOA) or a contract address. In the Dai contract, the only authorized address is the [DaiJoin Adapter](%5B%3Chttps://etherscan.io/address/0x9759A6Ac90977b93B58547b4A71c78317f391A28#code%3E%5D(%3Chttps://etherscan.io/address/0x9759A6Ac90977b93B58547b4A71c78317f391A28#code%3E)) that is part of the Maker Protocol. As such, only the DaiJoin Adapter is able to call the `mint` function.

The Dai contract uses a simplified authority for its functions, where only addresses known as `wards` are authorized by the `rely` function, and deauthorized by `deny`. Because `rely` and `deny` can be called only by members of `wards`, and the only address in wards is the DaiJoin adapter, which does not contain instructions to call `rely` or `deny`, the `wards` list is effectively frozen and cannot be modified on the mainnet deployment. The only occasion where rely and deny is expected to be used is during deployment.

### DaiJoin Adapter

The ERC20 Dai Token contract does not represent all Dai supply, as Dai can be in the form of internal balances to the Maker Protocol contracts. For a rundown of the different types of Dai, and the relation between them, please see the guide [Tracking Dai Supply](https://github.com/makerdao/developerguides/blob/master/dai/dai-supply/dai-supply.md)

The DaiJoin Adapter is used to convert internal Dai to a ERC20 token usable by wallets and exchanges. Typically, contracts and users deposit their internal Dai into the DaiJoin Adapter and obtain ERC20 tokens in exchange. Any holder of a ERC20 Dai token can also withdraw internal Dai from the contract by burning ERC20 Dai.

- `exit(address usr, uint wad)`: Transfers an internal Dai balance of the amount `wad` from address `usr` to the DaiJoin contract, and mint new ERC20 in favor of `usr`.
- `join(address usr, uint wad)`: Burns `wad` Dai from address `usr` and transfer the equivalent internal Dai in its favor. Note that join is possible only if the DaiJoin contract is approved.

### **Emergency Shutdown**

MKR holders can through the governance contract vote to shut down the system by executing the `cage()` function on the [ESM](https://etherscan.io/address/0x0581a0abe32aae9b5f0f68defab77c6759100085#code) contract.

After emergency shutdown, all DAI holders are allowed to claim collateral for each token at the last price reported by price feed oracles. Two functions `cash()` and `pack()`, are activated in [END](https://etherscan.io/address/0xaB14d3CE3F733CACB76eC2AbE7d2fcb00c99F3d5#code) contract. `cash()` allows token holders to redeem Dai for ETH at the exchange ratio set at emergency shutdown.

More information about the Emergency Shutdown can be found in the [Emergency Shutdown Guide](https://github.com/makerdao/developerguides/blob/master/mcd/emergency-shutdown/emergency-shutdown-guide.md).

### Deploy on testnet

Dai and the associated MCD contracts are deployed on [various testnets](https://changelog.makerdao.com), but you may want do deploy your own version of the Dai contract to test your ERC20 or `permit` integrations. The following instructions require a working configuration of [dapp.tools](https://dapp.tools), including `dapp` (tested with v0.27.0) and `seth` (v0.8.4) and a provisionned test account with its associated keys.

1. `git clone`[https://github.com/makerdao/dss](https://github.com/makerdao/dss)
2. `cd dss`
3. `dapp update`
4. `dapp build`
5. `export SETH_CHAIN=kovan` :
Change kovan for your prefered chain
6. `export ETH_KEYSTORE=~/keys` : Define where your keys are store
7. `export ETH_FROM=<address>` : Set your test account
8. `export ETH_RPC_URL=<RPC URL>` : Set the URL for a testnet RPC node (Infura or other)
9. `export chainid= $(seth --to-uint256 42)`:  Deploying the contract requires passing the chain id, for use with the permit function. For Kovan, the id is 42.
10. `dapp create Dai $chainid` : To deploy the contract. If successful, this will return the address of your new contract.

If you want to verify your contract on Etherscan, use the output of

`hevm flatten --source-file src/dai.sol --json-file out/dapp.sol.json`

and specify the content of `$chainid` as the ABI formatted constructor.

Once deployed, you may test your contract

1. `export DAIK=<deployed contract address>`
2. `seth call $DAIK 'wards(address)' $ETH_FROM`:  Should return 1 because the adress that deployed the contract is part of wards by default.
3. `seth send $DAIK 'mint(address,uint256)' $ETH_FROM $(seth --to-uint256 $(seth --to-wei 100000000 eth))`: Will mint yourself 100,000,000 test-DAI
4. `seth --from-wei $(seth --to-dec $(seth call $DAIK 'balanceOf(address)' $ETH_FROM))`: To see your test-Dai balance

## Summary

In this guide, we briefly discussed the technical details of the Dai token contract as well as a quick summary of its role in the Maker Protocol. Please refer to the links embedded in the document as well as the additional resources section for more information. We also urge you to explore the various tools and services built on top of Dai by our partner ecosystem.

## Additional resources

1. [https://github.com/makerdao/dss/blob/master/src/dai.sol](https://github.com/makerdao/dss/blob/master/src/dai.sol)
2. [Using Dai in smart contracts](https://github.com/makerdao/developerguides/blob/master/dai/dai-in-smart-contracts/README.md)
3. [Emergency Shutdown Guide](https://github.com/makerdao/developerguides/blob/master/mcd/emergency-shutdown/emergency-shutdown-guide.md)
4. [Tracking Dai Supply](https://github.com/makerdao/developerguides/blob/master/dai/dai-supply/dai-supply.md)

## Help

- Contact Integrations team - integrate@makerdao.com
- Rocket chat - #dev channel
