---
title: Working with DSProxy
description: Learn how DSProxy is used in Maker and apply it in your applications
parent: devtools
tags:
  - proxy contracts
  - dsproxy
  - aggregate transactions
slug: working-with-ds-proxy
contentType: guides
root: false
---

# Working with DSProxy

**Level**: Advanced  
**Estimated Time**: 90 - 120 minutes

- [Working with DSProxy](#working-with-dsproxy)
  - [Overview](#overview)
  - [Learning Objectives](#learning-objectives)
  - [Pre-requisites](#pre-requisites)
  - [Guide](#guide)
    - [Examples](#examples)
      - [Opening a Vault](#opening-a-vault)
      - [Automate vault deleveraging](#automate-vault-deleveraging)
    - [DSProxy](#dsproxy)
      - [Ownership](#ownership)
      - [Execute](#execute)
      - [Event Logs](#event-logs)
      - [Factory Contract](#factory-contract)
    - [Create a script](#create-a-script)
      - [Environment Setup](#environment-setup)
      - [Create a new dapp project](#create-a-new-dapp-project)
      - [Setup Delev.sol](#setup-delevsol)
      - [Add helper functions](#add-helper-functions)
      - [Setup `wipeWithEth` function](#setup-wipewitheth-function)
      - [Checks](#checks)
      - [Initialize variables](#initialize-variables)
      - [Remove the Eth from the vault](#remove-the-eth-from-the-vault)
      - [Market sell the Ether for Dai](#market-sell-the-ether-for-dai)
      - [Wipe Dai debt from the Vault](#wipe-dai-debt-from-the-vault)
    - [Deployment and Execution](#deployment-and-execution)
    - [Best Practices](#best-practices)
    - [Production Usage](#production-usage)
  - [Troubleshooting](#troubleshooting)
    - [Recovering ETH](#recovering-eth)
  - [Summary](#summary)
  - [Additional resources](#additional-resources)
  - [Next Steps](#next-steps)
  - [Help](#help)

## Overview

Whether you are a Keeper looking to integrate the Maker Protocol with a new source of liquidity, or an interface developer looking to cut down the number of transactions an end user has to sign, you can now implement your ideas by creating simple scripts that can atomically perform transactions across multiple contracts through DSProxy.

The Maker Protocol's approach to modularizing smart contracts and splitting logic into numerous tiny functions are great for security, but interface developers and end users interacting with them have to execute multiple transactions now to achieve a single goal. Instead of imposing the design constraints of good end-user ergonomics on the core smart contracts, it is moved to an additional compositional layer of smart contracts built with DSProxy and stateless scripts.

Keeping this functionality in a separate layer also allows developers to add additional scripts over time when new user needs emerge and better methods to compose new protocols are developed.

Understanding the DSProxy design pattern will help you quickly develop scripts that compose functionality of existing smart contracts in novel ways. Developing core smart contracts with this pattern in mind can increase their security without sacrificing usability, while reducing overall complexity, and preserving atomicity of transactions when simultaneously interacting with multiple smart contracts.

## Learning Objectives

In this guide you will,

- Understand how DSProxy and scripts work through examples
- Understand the features of a DSProxy contract
- Build and deploy a new script
- Look at best practices of developing a script
- Additional details to help with deploying a script to production

## Pre-requisites

- Understanding of the functions used to interact with Vaults
- Solidity development experience

## Guide

### Examples

#### Opening a Vault

Opening a Vault to generate Dai is a common action performed by users within the Maker Platform and they perform multiple transactions on the [WETH](https://etherscan.io/token/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2), [EthJoin](https://etherscan.io/address/0x2F0b23f53734252Bda2277357e97e1517d6B042A), [Vat](https://etherscan.io/address/0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B), and [DaiJoin](https://etherscan.io/address/0x9759a6ac90977b93b58547b4a71c78317f391a28#readContract) contracts to complete it.

Transactions to execute on the WETH token contract are,

- Convert ETH to WETH using the `mint` function.
- Approve the EthJoin contract to spend the user's WETH balance using the `approve` function.

Transactions to execute on the EthJoin contract are,

- Allocate the WETH to the vault using the `join` function.

Transactions to execute on the Vat contract are,

- Open the vault using the `open` function.
- Lock the WETH into the vault using the `frob` function.
- Draw Dai from the vault using the `frob` function.
- `move` the Dai out of the vault.
- `approve` the DaiJoin contract to access the user's Dai balance

Transactions to execute on DaiJoin

- Mint ERC20 Dai using the `exit` function, which in turns call the `mint` function of the ERC20 Dai contract.

[Oasis Borrow](https://oasis.app/borrow) uses a [script](https://github.com/makerdao/dss-proxy-actions/blob/master/src/DssProxyActions.sol#L608) to improve the user experience by executing the above steps atomically within a single transaction.

#### Automate vault deleveraging

A relatively common task for vault owner is to reduce its debt by selling collateral. This would normally involve multiple steps that could be done in a single atomic transaction:

- Draw collateral from the vault
- Sell the collateral for Dai
- Pay back the vault debt

### DSProxy

A user first deploys their own personal DSProxy contract and then uses it to call various scripts for the goals they wish to achieve. This DSProxy contract can also directly own digital assets long term since the user always has full ownership of the contract and it can be treated as an extension of the user's own ethereum address.

Scripts are implemented in Solidity as functions and multiple scripts are typically combined and deployed together as a single contract. A DSProxy contract can only execute one script in a single transaction. This section will focus on the features of a DSProxy contract and look at how scripts work in the next section.

#### Ownership

Ownership of a DSProxy contract is set to an address when it is deployed. There is support for authorities based on DSAuth if there is a need for ownership of the DSProxy contract to be shared among multiple users.

#### Execute

`execute(address target, bytes data)` function implements the core functionality of DSProxy. It takes in two inputs, an `address` of the contract containing scripts, and `data` which contains calldata to identify the script that needs to be executed along with it's input data.

`msg.sender` when the script is being executed will continue to be the user address instead of the address of the DSProxy contract.

`execute(bytes code, bytes data)` is an additional function that can be used when a user wants to deploy a contract containing scripts and then call one of the scripts in a single transaction. A `cache` registers the address of contract deployed to save gas by skipping deployment when other users call `execute` with the same bytecode later.

#### Event Logs

A DSProxy contract generates a event called `LogNote` with these values indexed when `execute()` is called,

- Function signature, `0x1cff79cd`
- Owner of the DSProxy contract, `msg.sender`
- Contract address which contains the script, `address`
- Calldata which contains function signature of script being executed and its input data, `data`

#### Factory Contract

The function `build` in the DSProxyFactory contract is used to deploy a personal DSProxy contract. Since proxy addresses are derived from the internal nonce of the DSProxyFactory, **it's recommended a 20 block confirmation time follows the `build` transaction**, lest an accidental address re-assignment during a block re-org. For production use cases on mainnet you can use a common factory contract that is already being used by existing projects to avoid deploying redundant DSProxy contracts for users who already have one. Please check the [Production Usage](#production-usage) section in this guide for more details.

### Create a script

You have seen an example earlier of how a script can help Vault owners to reduce their debt by selling collateral. Oasis exchange contracts are a good source of liquidity especially for buying small amounts of collateral. In this section, you will create a script that will allow users to draw Eth from their vault, sell it on Oasis and wipe debt from a Vault.

#### Environment Setup

You'll use `dapp` and `seth` while working through this section but you can also use your own tool of choice like the Remix IDE to execute these steps. Instructions to install both the tools can be found [here](https://dapp.tools/).

You have to create a `~/.sethrc` file and configure it with these values to work with the Kovan testnet,

- `export SETH_CHAIN=kovan`
- `export ETH_FROM=0xYourKovanAddressFromKeyStoreOrLedger`
- `export ETH_GAS=4000000`
- `export ETH_GAS_PRICE=2500000000`

It is usually recommended to configure `ETH_RPC_URL` to point an Infura endpoint or your own Kovan Ethereum node.

#### Create a new dapp project

Create a new folder and open it

```bash
mkdir delev && cd delev
```

Initialize a dapp project within it

```bash
dapp init
```

#### Setup Delev.sol

First you need to add the required interfaces to interact with functions on those contracts later in the script.

This contract will utilize the ERC20 contracts for WETH and DAI (`GemLike`), their adaptor contracts (`DaiJoinLike` and `GemJoinLike`), interact with the `vat` (`VatLike`), Oasis' MatchingMarket (`OasisLike`) and the `CDPManager` (`ManagerLike`):

```solidity
interface GemLike {
    function approve(address, uint) external;
    function transfer(address, uint) external;
    function transferFrom(address, address, uint) external;
    function deposit() external payable;
    function withdraw(uint) external;
}

interface DaiJoinLike {
    function vat() external returns (VatLike);
    function dai() external returns (GemLike);
    function join(address, uint) external payable;
    function exit(address, uint) external;
}


interface VatLike {
    function can(address, address) external view returns (uint);
    function ilks(bytes32) external view returns (uint, uint, uint, uint, uint);
    function dai(address) external view returns (uint);
    function urns(bytes32, address) external view returns (uint, uint);
    function frob(bytes32, address, address, address, int, int) external;
    function hope(address) external;
    function move(address, address, uint) external;
}

interface GemJoinLike {
    function dec() external returns (uint);
    function gem() external returns (GemLike);
    function join(address, uint) external payable;
    function exit(address, uint) external;
}

interface OasisLike {
    function sellAllAmount(address pay_gem, uint pay_amt, address buy_gem, uint min_fill_amount) external returns (uint);
}

interface ManagerLike {
    function cdpCan(address, uint, address) external view returns (uint);
    function ilks(uint) external view returns (bytes32);
    function owns(uint) external view returns (address);
    function urns(uint) external view returns (address);
    function vat() external view returns (address);
    function open(bytes32) external returns (uint);
    function give(uint, address) external;
    function cdpAllow(uint, address, uint) external;
    function urnAllow(address, uint) external;
    function frob(uint, int, int) external;
    function flux(uint, address, uint) external;
    function move(uint, address, uint) external;
    function exit(address, uint, address, uint) external;
    function quit(uint, address) external;
    function enter(address, uint) external;
    function shift(uint, uint) external;
}
```

#### Add helper functions

The `vat` records the individual vault debt balances by dividing the Dai amounts by the accrued `rate` for that ilk type. This facilitates the calculation of vault fees (For more details about rate accumulation, read this [guide](https://github.com/makerdao/developerguides/blob/master/mcd/intro-rate-mechanism/intro-rate-mechanism.md)). Here, we adapt a function from [`dss-proxy-actions`](https://github.com/makerdao/dss-proxy-actions/blob/master/src/DssProxyActions.sol#L164)

```solidity
    function _getWipeDart(
        address vat,
        uint dai,
        address urn,
        bytes32 ilk
    ) internal view returns (int dart) {
        // Gets actual rate from the vat
        (, uint rate,,,) = VatLike(vat).ilks(ilk);
        // Gets actual art value of the urn
        (, uint art) = VatLike(vat).urns(ilk, urn);

        // Uses the whole dai balance in the vat to reduce the debt
        dart = int(dai / rate);
        // Checks the calculated dart is not higher than urn.art (total debt), otherwise uses its value
        dart = uint(dart) <= art ? - dart : - int(art);
    }
```

#### Setup `wipeWithEth` function

Add a new function `wipeWithEth` which takes in the following inputs,

- Address of the [CDP Manager](https://github.com/makerdao/dss-cdp-manager) contract
- Address of the [MCD ETH Adapter](https://github.com/makerdao/dss/blob/master/src/join.sol#L62) (ethJoin)
- Address of the [MCD DAI Adapter](https://github.com/makerdao/dss/blob/master/src/join.sol#L137) (daiJoin)
- Address of the current [Oasis Matching Market](https://github.com/makerdao/maker-otc) contract
- Id of the CDP in decimals. Ex: 44
- Amount of Eth to be used

```text
function wipeWithEth(
    address manager,
    address ethJoin,
    address daiJoin,
    address oasisMatchingMarket,
    uint cdp,
    uint wadEth
)
    public
{
    // logic
}
```

#### Checks

Within the function body, ensure at least some Eth is being removed from the vault, using a require statement:

```solidity
require(wadEth > 0);
```

#### Initialize variables

Then you determine what is the `urn` address for our vault:

```solidity
address urn = ManagerLike(manager).urns(cdp);
```

#### Remove the Eth from the vault

First real step is withdraw the Ether from the vault. This is done by the `frob` function on the CDP Manager. After this is done, you need to move it from the `urn` address to our proxy and converting the internal WETH balance to an actual ERC20.

```solidity
//Remove the WETH from the vault
ManagerLike(manager).frob(cdp, -int(wadEth), int(0));
// Moves the WETH from the CDP urn to proxy's address
ManagerLike(manager).flux(cdp, address(this), wadEth);
// Exits WETH amount to proxy address as a token
GemJoinLike(ethJoin).exit(address(this), wadEth);
```

At this step, you have withdrawn the Ether from the vault. If remove that ether makes the vault undercollaterized, the transaction will fail here and revert.

#### Market sell the Ether for Dai

Oasis has a `sellAllAmount` method that market sells a ERC20 for another ERC20 token, here Weth and Dai. For this to work, make sure that the Kovan Oasis Trade has the required open orders.

```solidity
//Approve Oasis to obtain the WETH to be sold
GemJoinLike(ethJoin).gem().approve(oasisMatchingMarket,wadEth);
//Market order to sell the WETH for DAI
uint daiAmt = OasisLike(oasisMatchingMarket).sellAllAmount(
    address(GemJoinLike(ethJoin).gem()),
    wadEth,
    address(DaiJoinLike(daiJoin).dai()),
    uint(0)
);
```

In this naive implementation, you are market selling the Ether for Dai, irrespective of the on-chain price compared to the market. It could be possible to query an oracle to make sure there is no slippage or have the user specify a minimum amount of Dai to be received.

#### Wipe Dai debt from the Vault

You now wipe debt of the Vault with the Dai that you just acquired. You have to first `approve` the Dai Adapter to take our Dai and have it move it into the `urn` (using `join`):

```text
// Approves adapter to take the DAI amount
DaiJoinLike(daiJoin).dai().approve(daiJoin, daiAmt);
// Joins DAI into the vat
DaiJoinLike(daiJoin).join(urn, daiAmt);
```

To finally wipe the Dai, you have to calculate its art value in accordance to the current rate (so it takes into account fees) and finally wipe the debt using `frob`:

```solidity
// Calculate the amount of art corresponding to DAI (accumulated rates)
int dart = _getWipeDart(ManagerLike(manager).vat(), VatLike(ManagerLike(manager).vat()).dai(urn), urn, ManagerLike(manager).ilks(cdp));
// Pay back the art/dai in the vault
ManagerLike(manager).frob(cdp, int(0), dart);
```

Before you proceed to the next section of this guide, please ensure your code matches the `Delev` contract below

```solidity
contract Delev {

    function wipeWithEth(
        address manager,
        address ethJoin,
        address daiJoin,
        address oasisMatchingMarket,
        uint cdp,
        uint wadEth
    ) public {
        address urn = ManagerLike(manager).urns(cdp);
        require(wadEth > 0);

        //Remove the WETH from the vault
        ManagerLike(manager).frob(cdp, -int(wadEth), int(0));
        // Moves the WETH from the CDP urn to proxy's address
        ManagerLike(manager).flux(cdp, address(this), wadEth);
        // Exits WETH amount to proxy address as a token
        GemJoinLike(ethJoin).exit(address(this), wadEth);

        //Approve Oasis to obtain the WETH to be sold
        GemJoinLike(ethJoin).gem().approve(oasisMatchingMarket,wadEth);
        //Market order to sell the WETH for DAI
        uint daiAmt = OasisLike(oasisMatchingMarket).sellAllAmount(
            address(GemJoinLike(ethJoin).gem()),
            wadEth,
            address(DaiJoinLike(daiJoin).dai()),
            uint(0)
        );

        // Approves adapter to take the DAI amount
        DaiJoinLike(daiJoin).dai().approve(daiJoin, daiAmt);
        // Joins DAI into the vat
        DaiJoinLike(daiJoin).join(urn, daiAmt);
        // Calculate the amount of art corresponding to DAI (accumulated rates)
        int dart = _getWipeDart(ManagerLike(manager).vat(), VatLike(ManagerLike(manager).vat()).dai(urn), urn, ManagerLike(manager).ilks(cdp));
        // Pay back the art/dai in the vault
        ManagerLike(manager).frob(cdp, int(0), dart);
    }

    function _getWipeDart(
        address vat,
        uint dai,
        address urn,
        bytes32 ilk
    ) internal view returns (int dart) {
        // Gets actual rate from the vat
        (, uint rate,,,) = VatLike(vat).ilks(ilk);
        // Gets actual art value of the urn
        (, uint art) = VatLike(vat).urns(ilk, urn);

        // Uses the whole dai balance in the vat to reduce the debt
        dart = int(dai / rate);
        // Checks the calculated dart is not higher than urn.art (total debt), otherwise uses its value
        dart = uint(dart) <= art ? - dart : - int(art);
    }

}

```

### Deployment and Execution

Before you begin, ensure you have some Kovan ETH to pay gas for transactions and Kovan Dai on the address by following instructions on this [guide](https://github.com/makerdao/developerguides/blob/master/dai/dai-token/dai-token.md#testnet)

Build the `delev` project

```bash
dapp build --extract
```

Deploy the Delev contract

```bash
dapp create Delev
```

Make a note of the contract address returned after successful execution and store it as a variable

```bash
export DELEV=0x990f8388b5cb113e63d119d296e68590283e823e
```

Deploy your own DSProxy contract for your address using the factory contract present on Kovan

```bash
export PROXYREGISTRY=0x64a436ae831c1672ae81f674cab8b6775df3475c
seth send $PROXYREGISTRY 'build()'
```

This transaction might fail if you already have deployed a DSProxy contract before from this address. You can check if you have one now with this command

```bash
seth call $PROXYREGISTRY 'proxies(address)(address)' $ETH_FROM
```

Make a note of the returned DSProxy contract address and store it as a variable.

```bash
export MYPROXY=0xYourDSProxyAddress
```

You can prepare calldata to extract and sell 0.01 ETH from our vault #560 on Kovan using this command with the following inputs,

- Address of the CDP Manager contract
- Address of the MCD ETH Adapter (ethJoin)
- Address of the MCD DAI Adapter (daiJoin)
- Address of the current Oasis Matching Market contract
- Id of the CDP in decimals. (560)
- Amount of Eth to be used: 0.01

```bash
export CDP_MANAGER=0x1476483dD8C35F25e568113C5f70249D3976ba21
export ETH_JOIN=0x775787933e92b709f2a3C70aa87999696e74A9F8
export DAI_JOIN=0x5AA71a3ae1C0bd6ac27A1f28e1415fFFB6F15B8c
export OASIS=0xe325acB9765b02b8b418199bf9650972299235F4
CALLDATA=$(seth calldata 'wipeWithEth(address,address,address,address,uint,uint)' $CDP_MANAGER $ETH_JOIN $DAI_JOIN $OASIS $(seth --to-hexdata $(seth --to-uint256 560)) $(seth --to-uint256 $(seth --to-wei 0.01 eth)))
```

CALLDATA should look like this:

```bash
echo $CALLDATA
0xb46858180000000000000000000000001476483dd8c35f25e568113c5f70249d3976ba21000000000000000000000000775787933e92b709f2a3c70aa87999696e74a9f80000000000000000000000005aa71a3ae1c0bd6ac27a1f28e1415fffb6f15b8c000000000000000000000000e325acb9765b02b8b418199bf9650972299235f4000000000000000000000000000000000000000000000000000000000000023000000000000000000000000000000000000000000000000000038d7ea4c68000
```

Call execute on the DSProxy contract with these inputs,

- Address of the deployed `Delev` contract
- Calldata to execute the `wipeWithEth` script

```bash
seth send $MYPROXY 'execute(address,bytes memory)' $DELEV $CALLDATA
```

If the call worked correctly, you will see the Ether and Dai balances on the contract reduced by a small amount.

### Best Practices

Use `require` when using `transferFrom` within the script to ensure the transaction fails when a token transfer is unsuccessful

### Production Usage

Deploying a script to production involves creating user interfaces that can handle a DSProxy contract deployment for users who need one, and then facilitating their interactions with various deployed scripts through their deployed DSProxy contracts.

A common [Proxy Registry](https://github.com/makerdao/proxy-registry) can be used by all projects to deploy DSProxy contracts for users. The address of the deployed DSProxy contract is stored in the registry and can be looked up in the future to avoid creating a new DSProxy contract for users who already have one.

Proxy Registries are already available on these networks,

- Mainnet: `0x4678f0a6958e4d2bc4f1baf7bc52e8f3564f3fe4`
- Kovan: `0x64a436ae831c1672ae81f674cab8b6775df3475c`

## Troubleshooting

### Recovering ETH

[Proxy Recover Funds](https://proxy-recover-funds.surge.sh/) interface can be used to recover and transfer ETH back to their address if it gets stuck within the DSProxy contract after a failed transaction.

## Summary

Writing scripts can help you solve a variety of problems you encounter as a developer trying to improve the user experience for your users, or even as a power user interacting with ethereum protocols. The hope is this guide has covered all the relevant details to help you get started with DSProxy.

## Additional resources

1. [DSProxy](https://github.com/dapphub/ds-proxy)
2. [Sai Proxy](https://github.com/makerdao/sai-proxy)
3. [Oasis Direct Proxy](https://github.com/makerdao/oasis-direct-proxy)

## Next Steps

## Help

- Rocket chat - [#dev](https://chat.makerdao.com/channel/dev) channel
