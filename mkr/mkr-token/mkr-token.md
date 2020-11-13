# MKR Token Guide

Level: Beginner  
Estimated Time: 30 minutes

- [MKR Token Guide](#mkr-token-guide)
  - [Overview](#overview)
  - [Learning objectives](#learning-objectives)
  - [Prerequisites](#prerequisites)
  - [Content / Sections](#content--sections)
  - [Token Info](#token-info)
    - [Addresses](#addresses)
    - [Details](#details)
  - [Getting Testnet MKR](#getting-testnet-mkr)
  - [Token Contract](#token-contract)
    - [DSToken](#dstoken)
    - [DSAuth](#dsauth)
    - [Mint and Burn](#mint-and-burn)
  - [Older MKR Tokens](#older-mkr-tokens)
    - [BitShares](#bitshares)
    - [First Ethereum Contact](#first-ethereum-contact)
  - [Summary](#summary)
  - [Next steps](#next-steps)
  - [Resources](#resources)

## Overview

The MKR token is the governance token of the Dai Stablecoin System. It is primarily used to vote on changes to its Risk Parameters. To vote, MKR owners must "lock up" their tokens into a [voting proxy contract](https://medium.com/makerdao/the-makerdao-voting-proxy-contract-5765dd5946b4) or the [DSChief contract directly](https://github.com/dapphub/ds-chief), and from there vote on the different proposals.

MKR is also the collateral of last resort in Multi-Collateral DAI: When the system is underwater, MKR is minted to replenish it. The risk of underwater CDPs for MKR holders is counterbalanced by the burning of a portion of CDP Stability Fees in MKR.

This guide will be useful to developers integrating MKR in applications like wallets, exchanges, and smart contracts to get a better understanding of the token contract and its functionality.

## Learning objectives

- You will learn basic information about the token.

- Understand the additional functions supported by the token contract.

## Prerequisites

- Knowledge of the ERC20 token standard.

- Ability to send Ethereum transactions from your preferred development environment.

- Optional: To run the examples, [seth](https://dapp.tools/seth/) configured with an account on Kovan testnet.

## Content / Sections

- Token Info
- Getting Testnet MKR
- Token Contract
- Older MKR Tokens

## Token Info

### Addresses

The MKR contract can be found on mainnet at address [0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2](https://etherscan.io/address/0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2) and on the Kovan testnet at [0xAaF64BFCC32d0F15873a02163e7E500671a4ffcD](https://kovan.etherscan.io/address/0xAaF64BFCC32d0F15873a02163e7E500671a4ffcD).

### Details

The MKR token is an ERC-20 token created using [DSToken](https://github.com/dapphub/ds-token). The symbol field is set to ‘MKR’ and the name field is currently set to ‘Maker’. A key difference to note between Dai and most other popular ERC20 tokens is that both these fields use ‘bytes32’ instead of the ‘string’ type.

Token precision field decimals is set to 18 like most other ERC20 tokens.

## Getting Testnet MKR

A faucet on Kovan can be used to obtain MKR: [0xCbd3e165cE589657feFd2D38Ad6B6596A1f734F6](https://kovan.etherscan.io/address/0xcbd3e165ce589657fefd2d38ad6b6596a1f734f6). The contract provides the function `gulp(address)` which, when called with the MKR token contract address, will send to the caller 1 MKR.

Example:

```bash
export FAUCET=0xCbd3e165cE589657feFd2D38Ad6B6596A1f734F6
export MKR=0xAaF64BFCC32d0F15873a02163e7E500671a4ffcD
seth send $FAUCET 'gulp(address)' $MKR
```

This faucet will send funds only once per address, so if you need more than one MKR, you will need to use multiple addresses.

## Token Contract

### DSToken

The MKR token contract is similar to most ERC20 token contracts, as it implements the same `Transfer`, `Approve` and `BalanceOf` functions. The contract is based on the [DSToken](https://github.com/dapphub/ds-token/) codebase, that extends the functionality of a simple ERC20 token, primarily by adding mint and burn functions.

### DSAuth

[DSAuth](https://github.com/dapphub/ds-auth) is used to authorize certain actions on the contract. In the case of a DSToken contract, the functions that are restricted by this method are:

- `mint`
- `burn`
- `setName`
- `setOwner` (inherited from DSAuth)
- `setAuthority` (inherited from DSAuth)

For these functions to be executable, one of the three conditions must be applicable:

- The caller is the contract owner
- The caller is the contract itself
- The caller has been granted permission by an authority contract

In the absence of an authority contract, only the contract owner is able to execute restricted functions. For the current mainnet deployment, the authority contract is set to the burn address (0x0) and the owner of the contract is the MakerDAO devfund multisig contract. In the future, the MKR Token will use the [mkr-authority](https://github.com/makerdao/mkr-authority) contract configured to allow minting and burning of MKR. The owner will then be set to the burn address (0x0) to permanently lock it down.

### Mint and Burn

As currently deployed, SCD doesn’t allow any minting or burning, except by a manual intervention of the Dev Fund Multisig. To date, no MKR has been formally burned, apart from the MKR placed in a [burner contract](https://etherscan.io/address/0x69076e44a9c70a67d5b79d95795aba299083c275), and a single minting event has happened, at contract creation.

In MCD, minting and burning are controlled by the [flap and the flop contracts](https://github.com/makerdao/developerguides/blob/master/mcd/mcd-101/mcd-101.md#system-stabilizer-module).

## Older MKR Tokens

The MKR Token went through a few iterations before its current form.

### BitShares

The first MKR Token was deployed on BitShares under the name [MKR](https://bitsharescan.com/asset/MKR) and [MKRCOIN](https://bitsharescan.com/asset/MKRCOIN). Current holders need to request a conversion to the ERC20 token in the #bobgate channel in [chat.makerdao.com](https://chat.makerdao.com/)

### First Ethereum Contact

A previous version of the MKR token is available on mainnet at [0xc66ea802717bfb9833400264dd12c2bceaa34a6d](https://etherscan.io/token/0xc66ea802717bfb9833400264dd12c2bceaa34a6d). This contract was upgraded prior to Single-Collateral DAI launch in 2017 and old-MKR holders are required to upgrade their tokens at [https://makerdao.com/redeem/](https://makerdao.com/redeem/) if they want to use it in SCD, MCD or participate to MakerDAO Governance.

## Summary

In this guide, we provided the basic token information for Mainnet and Kovan MKR deployments, and explained some of the differences between the MKR Token contract and the typical ERC-20 tokens.

## Next steps

- [The MakerDAO Voting Proxy Contract](https://medium.com/makerdao/the-makerdao-voting-proxy-contract-5765dd5946b4)
- [Vote Proxy Setup: Air-gapped Machine](https://github.com/makerdao/developerguides/blob/master/governance/vote-proxy-setup-airgapped-machine/vote-proxy-setup-airgapped-machine.md)
- [Dai Token](https://github.com/makerdao/developerguides/blob/master/dai/dai-token/dai-token.md)

## Resources

- [https://github.com/dapphub/seth](https://github.com/dapphub/seth)
- [https://github.com/dapphub/ds-token/](https://github.com/dapphub/ds-token/)
- [https://github.com/dapphub/ds-auth](https://github.com/dapphub/ds-auth)
- [https://github.com/dapphub/ds-guard/](https://github.com/dapphub/ds-guard/)
