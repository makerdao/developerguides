# Dai Token

**Level**: Beginner

**Estimated Time**: 30 - 60 minutes

## Overview

Dai is a decentralized stablecoin currently live on the Ethereum network. The Dai Credit System incentivizes users to increase or decrease the Dai token supply based on supply and demand and ensures its value stays pegged to 1 USD.

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

Dai is available on the Ethereum mainnet at [0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359](https://etherscan.io/token/0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359) and the Kovan testnet at [0xc4375b7de8af5a38a93548eb8453a498222c4ff2](https://kovan.etherscan.io/token/0xc4375b7de8af5a38a93548eb8453a498222c4ff2).

#### Details

The *symbol* field is set to ‘DAI’ and the *name* field is currently set to ‘Dai Stablecoin v1.0’. A key difference to note between Dai and most other popular ERC20 tokens is that both these fields use ‘bytes32’ instead of the ‘string’ type.[3]

Token precision field *decimals* is set to 18 like most other ERC20 tokens.

#### Token stats

Dai has been live on the Ethereum mainnet since December 17, 2017 and its current total supply can be viewed on [MakerScan](https://makerscan.io/). Supply varies constantly as new tokens are generated or removed every time a user creates new debt or pays their existing debt off on their [Collateralized Debt Position](https://makerdao.com/en/whitepaper/#collateralized-debt-position-smart-contracts)(CDP). You can also see additional stats of the token updated real-time on [mkr.tools](https://mkr.tools/tokens/dai). Note that MakerScan or mkr.tools are websites maintained by the community and may not always produce accurate data.

The system internally uses 1 USD as the target price of Dai when it issues new debt or removes existing debt from a CDP but the market price of the token could vary based on a variety of conditions like exchange liquidity, trading pair etc.

Care should be taken before using the price of Dai directly reported by sources like [CoinMarketCap](https://coinmarketcap.com/currencies/dai/), because exchange bugs may produce unreasonable price data. In many scenarios, such as displaying the value of Dai in a wallet, it is perfectly fine to hard code the price of a token to 1 USD.

### Getting Dai

#### Mainnet

Dai can be purchased with Ether on many popular exchanges, [https://coinmarketcap.com/currencies/dai/#markets](https://coinmarketcap.com/currencies/dai/#markets). It is also available on many decentralized exchanges like [Eth2Dai](https://eth2dai.com), [KyberSwap](https://kyberswap.com/), and [Uniswap](https://uniswap.exchange/).

You can also create your own Dai by opening a CDP with [https://cdp.makerdao.com](https://cdp.makerdao.com/).

#### Testnet

The best method to get Kovan Dai is to open a testnet CDP using Kovan ETH and create your required amount of Dai from it. The lowest collateralization ratio will give you the most bang for the buck!  Another option is to buy Kovan Dai with Kovan ETH on [Eth2Dai](https://eth2dai.com) if there is sufficient liquidity available.

### Token Contract

#### DSToken

Dai token is deployed using the [DSToken](https://github.com/dapphub/ds-token) codebase from [Dappsys](https://dapp.tools/dappsys/). It implements all functions and events as defined in the ERC20 token standard. The codebase at commit [e637e3f](https://github.com/dapphub/ds-token/tree/e637e3f3aff929ca4e72966015c16df0b235ea2a) was used for deployments on both networks.

Binary approval can be given to addresses by token holders using *approve(address)* which sets the approved token amount to *MAX_UINT*.

DSToken implements additional mint and burn functions to increase/decrease the total token supply under certain conditions. Permission checks are delegated to an authority contract which checks whether the caller is authorized to execute these protected functions or not.

Tokens are created when a user adds collateral to their CDP and creates new Dai from it. Tokens are destroyed when the same user pays back the same amount of Dai they’ve previously issued for the system to remove them from the supply and return their locked collateral back.

[Tub](https://etherscan.io/address/0x448a5065aebb8e423f0896e6c5d525c040f59af3) and [Tap](https://etherscan.io/address/0xbda109309f9fafa6dd6a9cb9f1df4085b27ee8ef) contracts in the Dai Credit System process calls to the Dai token which can increase or decrease the total supply. Tub contract stores all CDP records and has ownership over all the active collateral in the system. Tap contract facilitates liquidation by taking ownership over collateral ceased from an unsafe CDP, creates a negative debt record on the *sin *token, and allows external [Keeper](https://github.com/makerdao/pymaker#introduction) interactions to buy collateral and pay off the debt that an unsafe CDP owed to the system.

#### Mint

Mint has the function signature: *mint(address guy, uint wad)*. It increases the total supply of the token as well as the *guy’s* token balance by the *wad* amount. This generates an event with the signature: *Mint(address indexed guy, uint wad)*. All calls to *mint()* originate from the *draw()* function on the [Tub](https://etherscan.io/address/0x448a5065aebb8e423f0896e6c5d525c040f59af3) contract.

#### Burn

Burn has the function signature: *burn(address guy, uint wad)*. It decreases the total supply of the token as well as the *guy*’s token balance by the *wad* amount. It also generates an event with the signature: *Burn(address indexed guy, uint wad).*

Calls to *burn()* originate from *wipe()* function on the [Tub](https://etherscan.io/address/0x448a5065aebb8e423f0896e6c5d525c040f59af3) contract and *heal()* on the [Tap](https://etherscan.io/address/0xbda109309f9fafa6dd6a9cb9f1df4085b27ee8ef) contract.

Other functions which are not currently active but have permissions to call mint and burn are,

*drip()* on Tub uses [mint](https://github.com/makerdao/sai/blob/0dd0a799e4746ac1955b67898762cff9b71aea17/src/tub.sol#L225) to assess CDP owners an additional fee and distribute it to PETH holders, but it is not used right now as [*tax*](https://github.com/makerdao/sai/blob/0dd0a799e4746ac1955b67898762cff9b71aea17/src/tub.sol#L51) isn't activated in the live system.

*mock()* and *cash()* on Tap are authorized to call [mint](https://github.com/makerdao/sai/blob/0dd0a799e4746ac1955b67898762cff9b71aea17/src/tap.sol#L128) and [burn](https://github.com/makerdao/sai/blob/0dd0a799e4746ac1955b67898762cff9b71aea17/src/tap.sol#L123) respectively only after emergency shutdown.



#### Authority

Owner variable in the contract has been set to the 0x0 address after deployment. Token holder functions like *transferFrom()*, and *approve()* are fully open for existing token holders to call.

The entire Dai Credit system comprises of a modular set of contracts that each perform one specific action. They use a common [DSGuard](https://dapp.tools/dappsys/ds-guard.html) authority, which has been [instantiated](https://etherscan.io/address/0x315cbb88168396d12e1a255f9cb935408fe80710#events) during the initial deployment, with an [access control list](https://github.com/makerdao/sai/blob/0dd0a799e4746ac1955b67898762cff9b71aea17/src/fab.sol#L172)(ACL) to track contracts that are permitted to call functions on others. Permissions on this ACL cannot be updated, as both its owner and authority are also set to 0x0.

On the Dai token contract, Tub is permitted to both mint and burn Dai balance of any token holder. Tap is allowed to mint and burn Dai balance of a token holder, and also burn its own Dai balance.

A stop modifier is present on all functions: Transfers, Approvals, Mint, and Burn, but they still cannot be stopped because the current authority does not permit anyone to call it, and this cannot be changed in the future too.

#### Emergency Shutdown

MKR holders through their governance contract can vote to shut down the system by executing the *cage()* function on the [Top](https://etherscan.io/address/0x9b0ccf7c8994e19f39b2b4cf708e0a7df65fa8a3#code) contract. Under normal conditions, this is only intended to be used after a majority of the CDP and Dai users have migrated to a new version, like Multi-Collateral Dai. It is a last layer of protection that sacrifices the stability of the Dai token to preserve its value for its token holders.

After emergency shutdown, all DAI holders are allowed to claim collateral for each token at the last price reported by price feed oracles. Two functions- *cash()* and *mock()*, are activated in Tap. *Cash()* allows token holders to redeem Dai for ETH at the exchange ratio set at emergency shutdown. *Mock()* allows users to create Dai at the fixed ETH exchange ratio to avoid a supply crunch if other contracts and applications still need volatile Dai for their operations.

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
