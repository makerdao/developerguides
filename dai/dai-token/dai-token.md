# Dai Token

**Level**: Beginner

**Estimated Time**: 30 - 60 minutes

## Overview

Dai is a decentralized stablecoin currently live on the Ethereum network. The Maker Protocol incentivizes users to increase or decrease the Dai token supply based on supply and demand and ensures its value stays pegged to 1 USD.

The token contract conforms to the ERC20 token standard which allows wallets, exchanges, and other applications to easily integrate with minimal effort. This guide will be useful to developers integrating Dai in applications like wallets, exchanges, and smart contracts to get a better understanding of the token contract and its functionality.

## Learning Objectives

* You will learn basic information about the token.

* Understand the additional functions supported by the token contract.

* Deploy your own token to an Ethereum testnet.

* Integrate the Dai token effectively with your application.

## Pre-requisites

* Knowledge of the [ERC20](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md) token standard.

* Ability to send ethereum transactions from your preferred dev environment.

## Guide

* [Token Info](#token-info)

* [Getting Dai](#getting-dai)

* [Token contract](#token-contract)

* [Deploy a DSToken](#deploy-a-dstoken)

### Token Info

#### Addresses

Dai is available on the Ethereum mainnet at [0x6b175474e89094c44da98b954eedeac495271d0f](https://etherscan.io/token/0x6b175474e89094c44da98b954eedeac495271d0f) and the Kovan testnet at [0x4f96fe3b7a6cf9725f59d353f723c1bdb64ca6aa](https://kovan.etherscan.io/token/0x4f96fe3b7a6cf9725f59d353f723c1bdb64ca6aa).

#### Details

The *symbol* field is set to ‘DAI’ and the *name* field is currently set to ‘Dai Stablecoin’.

Token precision field *decimals* is set to 18 like most other ERC20 tokens.

#### Token stats

Multi Collateral Dai has been live on the Ethereum mainnet since November 18, 2019 and its current total supply can be viewed on [DaiStats](https://daistats.com/).

Sai (legacy Dai) has been live on the Ethereum mainnet since December 17, 2017 and its current total supply can be viewed on [MakerScan](https://makerscan.io/). Supply varies constantly as new tokens are generated or removed every time a user creates new debt or pays their existing debt off on their [Collateralized Debt Position](https://makerdao.com/en/whitepaper/#collateralized-debt-position-smart-contracts)(CDP). You can also see additional stats of the token updated real-time on [mkr.tools](https://mkr.tools/tokens/dai). Note that MakerScan or mkr.tools are websites maintained by the community and may not always produce accurate data.

The system internally uses 1 USD as the target price of Dai when it issues new debt or removes existing debt from a Vault but the market price of the token could vary based on a variety of conditions like exchange liquidity, trading pair etc.

Care should be taken before using the price of Dai directly reported by sources like [CoinMarketCap](https://coinmarketcap.com/currencies/dai/), because exchange bugs may produce unreasonable price data. In many scenarios, such as displaying the value of Dai in a wallet, it is perfectly fine to hard code the price of a token to 1 USD.

### Getting Dai

#### Mainnet

Dai can be purchased with Ether on many popular exchanges, [https://coinmarketcap.com/currencies/multi-collateral-dai/markets/](https://coinmarketcap.com/currencies/multi-collateral-dai/markets/). It is also available on many decentralized exchanges like [Oasis](https://oasis.app/trade/), [KyberSwap](https://kyberswap.com/), and [Uniswap](https://uniswap.exchange/).

You can also create your own Dai by opening a Vault with [https://oasis.app/](https://oasis.app/).

#### Testnet

The best method to get Kovan Dai is to open a testnet Vault using Kovan ETH and create your required amount of Dai from it. The lowest collateralization ratio will give you the most bang for the buck!  Another option is to buy Kovan Dai with Kovan ETH on [Oasis](https://oasis.app/trade if there is sufficient liquidity available.

### Token Contract

#### DSToken

Dai token is deployed using the [DSToken](https://github.com/dapphub/ds-token) codebase from [Dappsys](https://dapp.tools/dappsys/). It implements all functions and events as defined in the ERC20 token standard. The codebase at commit [f22f681](https://github.com/makerdao/dss-deploy-scripts/commit/bad5e39ad7389a78e183234dc29bbdf00f88265a) was used for deployments on both networks.

Binary approval can be given to addresses by token holders using *approve(address)* which sets the approved token amount to *MAX_UINT*.

DSToken implements additional mint and burn functions to increase/decrease the total token supply under certain conditions. Permission checks are delegated to an authority contract which checks whether the caller is authorized to execute these protected functions or not.

Tokens are created when a user adds collateral to their Vault and creates new Dai from it. Tokens are destroyed when the same user pays back the same amount of Dai they’ve previously issued for the system to remove them from the supply and return their locked collateral back.

The [MCD_DAI_JOIN](https://etherscan.io/address/0x9759a6ac90977b93b58547b4a71c78317f391a28#code) adapter contract in the Maker Protocol process calls to the Dai token which can increase or decrease the total supply. 

#### Mint

Mint has the function signature: *mint(address guy, uint wad)*. It increases the total supply of the token as well as the *guy’s* token balance by the *wad* amount. This generates an event with the signature: *Mint(address indexed guy, uint wad)*. All calls to *mint()* originate from the *exit()* function on the [DaiJoin](https://etherscan.io/address/0x9759a6ac90977b93b58547b4a71c78317f391a28#code) contract.

#### Burn

Burn has the function signature: *burn(address guy, uint wad)*. It decreases the total supply of the token as well as the *guy*’s token balance by the *wad* amount. It also generates an event with the signature: *Burn(address indexed guy, uint wad).*

Calls to *burn()* originate from *join()* function on the [DaiJoin](https://etherscan.io/address/0x9759a6ac90977b93b58547b4a71c78317f391a28#code) contract.


#### Authority

Owner variable in the contract has been set to the 0x0 address after deployment. Token holder functions like *transferFrom()*, and *approve()* are fully open for existing token holders to call.

#### Emergency Shutdown

MKR holders through their governance contract can vote to shut down the system by executing the *cage()* function on the [ESM](https://etherscan.io/address/0x0581a0abe32aae9b5f0f68defab77c6759100085#code) contract. 

After emergency shutdown, all DAI holders are allowed to claim collateral for each token at the last price reported by price feed oracles. Two functions- *cash()* and *pack()*, are activated in END contract. *Cash()* allows token holders to redeem Dai for ETH at the exchange ratio set at emergency shutdown. 

The *transferFrom()* function has a few aliases available: *push*, *pull*, and *move*, both *mint* and *burn* functions also have aliases that automatically create or remove Dai of the *msg.sender*.

### Deploy a DSToken

You will need to install dapptools to finish this section. Installation instructions can be found here, [https://dapp.tools/](https://dapp.tools/) Initialize your `.sethrc` file with the right values for the env variables `SETH_CHAIN` and `ETH_FROM` as mentioned [here](https://github.com/dapphub/dapptools/tree/master/src/seth#example-sethrc-file). Seth will automatically search the default folder paths for Geth and Parity keystores, or your Ledger hardware wallet, for the address you've set.

Clone a local copy of the DSToken repo from this link, [https://github.com/dapphub/ds-token.git](https://github.com/dapphub/ds-token.git)

Run `dapp update` to initialize all the git submodules present in the repo. Run `dapp build` to build the codebase and generate the files required to deploy the token contract.

Run `dapp create DSTokenFactory` to deploy the DSTokenFactory contract, which we'll use to deploy a new token contract next. Copy the address of the factory to use in our next command.

Use seth to call *make()* on the factory contract with *symbol* and *name* as input to deploy a new DSToken. Bytes32 values in the following command will set the symbol to 'DAI' and name to 'Dai Stablecoin v1.0' on the deployed token contract.

```bash
seth send DSTokenFactoryAddress 'make(bytes32,bytes32)' 0x4441490000000000000000000000000000000000000000000000000000000000 0x44616920537461626c65636f696e2076312e3000000000000000000000000000
```

This command will deploy a new DSToken with your address set as the owner.

## Summary

In this guide, we briefly discussed the technical details of the Dai token contract as well as a quick summary of its role in the Dai Credit System. Please refer to the links embedded in the document as well as the additional resources section for more information. We also urge you to explore the various tools and services built on top of Dai by our partner ecosystem.

## Additional resources

1. [https://github.com/makerdao/sai](https://github.com/makerdao/sai)

2. [https://dapp.tools/dappsys/ds-auth.html](https://dapp.tools/dappsys/ds-auth.html)

3. [https://hackernoon.com/how-one-hacker-stole-thousands-of-dollars-worth-of-cryptocurrency-with-a-classic-code-injection-a3aba5d2bff0](https://hackernoon.com/how-one-hacker-stole-thousands-of-dollars-worth-of-cryptocurrency-with-a-classic-code-injection-a3aba5d2bff0)

## Help

* Contact Integrations team - integrate@makerdao.com

* Rocket chat - #dev channel
