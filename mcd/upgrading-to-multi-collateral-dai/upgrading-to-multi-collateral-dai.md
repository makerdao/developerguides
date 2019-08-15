# Upgrading to Multi-Collateral Dai

Level: Intermediate

Estimated Time: 60 minutes

Audience: Technical and commercial teams with partners and Dai holders

## Introduction

The upcoming version of the Maker system, Multi Collateral Dai, brings a lot of new and exciting features to the Ethereum ecosystem, such as new supported collateral types and Savings Dai. In order to support the new functionality, the whole Maker core of smart contracts has been rewritten, and be redeployed. Therefore, in order to make use of these new features, users and partners, who are using or are integrated with the SCD system must migrate their existing Single Collateral Dai tokens (Sai) to Multi Collateral Dai tokens (Dai) and CDPs to the new system. Additionally, companies or projects who are integrated with Sai and CDPs must update their codebases to point to the new smart contracts, and refactor their code to support the updated functions. This guide will focus on the Dai and CDP migration.

This guide gives a high level overview of the upgrade process for different actors in the Maker ecosystem.

The steps necessary to migrate from Single-Collateral Dai (SCD) to Multi-Collateral Dai (MCD) differ depending on your platform and use case for Dai, so the guide is split into sections for different user and partner types.

### Learning Objective

-   Knowledge on how migration to MCD will work
    
-   Best practices for migration for different users and partners
    
-   Where to find guides on specific migration scenarios
    

### Pre-requisites

-   Basic knowledge of the [MakerDAO: DAI and/or CDP system.](https://github.com/makerdao/awesome-makerdao)
    

### Sections

-   [Migration Portal](#migration-portal)
    
-   [Migration Contract](#migration-contract)
    

	-   [Functionality](#functionality)
    
	-   [Upgrading Sai to Dai](#upgrading-sai-to-dai)
    
	-   [Swapping Dai for Sai](#swapping-dai-for-sai)
    
	-   [Migrating CDPs](#migrating-cdps)
    
	-   [CLI Tools for Migration](#cli-tools-for-migration)
    

-   [Partner Migration Scenarios](#partner-migration-scenarios)
    

	-   [As a Dai Holder](#as-a-dai-holder)
    
	-   [As a SCD CDP Owner](#as-a-scdp-cdp-holder)
    
	-   [As a Centralized Exchange or Custodial Wallet](#as-a-centralized-exchange-or-custodial-wallet)
    
	-   [As a Decentralized Exchange](#as-a-decentralized-exchange)
    
	-   [As a Relayer](#as-a-relayer)
	
	-   [As a Non-custodial wallet](#as-a-non-custodial-wallet)
    
	-   [As a Keeper](#as-a-keeper)
    
	-   [As a Market Maker](#as-a-market-maker)
    

## Migration Portal

Upon release of MCD, the Migration Portal at migrate.makerdao.com will allow you to carry out Dai and CDP migration through an intuitive web UI in just a few clicks. By logging in with your favourite wallet solution, the portal will scan your wallet for any recommended migrations and showcase them in the UI (seen in picture below). This migration scan feature will be continually supported going forward, ensuring that users are always using an up-to-date version of the Maker platform.

## ![](https://lh4.googleusercontent.com/4lDcE3D49XKtlrLS-aACDK0s0v83m4G4zwpZrmWZL6LS2k8DrjDpYFE-yW1nx4-rd8qaXxPJhLZncjmNlzeCk1odtpJynNRzH3eyCO1jmfP3V69bLDNaQyMK4LtxoIM07Bfdk24e)

Landing Page that will show you possible migrations for the connected wallet.

## ![](https://lh3.googleusercontent.com/BRDdg8WB2QzyRs_92gG05sKDGcqmsKZZvWRdpQJmF7xmiSf7jy0oZq8wU7xmL6X49gcTVFEKn3teve_UnrpZynFc080NxTlmCVF2SJVsfmfnY14j7ojRROXXrnYdmy4XU-tJ6uB3)

Wizard for migrating Sai to Dai.

## ![](https://lh4.googleusercontent.com/_Z2LYOE9lsFuBgwiUPOTkmrVKxpTU6tZbLSVQvcp-LRV95vHozUEV-v6ZRgCCgIji0HXBAUNI3os8ehQZActF15yKFsADLvsZualComi8DN2vvXXM6Nh5jCgyclDuiOpvA3XnApq)

Wizard for migrating an SCD CDP to MCD CDP.

## Migration Contract

The functionality of the Migration Portal outlined in the above section is handled by a Migration Contract that will be deployed at MCD launch in order to support a smooth transition from Single Collateral Dai to Multi Collateral Dai. The contract will make the redemption of Single Collateral Dai tokens (SAI from now on) for Multi Collateral Dai tokens (DAI from now on), and the migration of CDPs to the new CDP engine of MCD, an easy task. This section will outline how the migration contract works in order to help super users and partners prepare for MCD migration.

### Functionality

The migration smart contracts are open source and can be found here: [https://github.com/makerdao/scd-mcd-migration](https://github.com/makerdao/scd-mcd-migration)

In the src folder, the smart contract source code can be found. The main contract is the `ScdMcdMigration.sol` which contains the migration functionality that you will interact with.

It contains three main functions, `swapSaiToDai` - a function that upgrades Sai to Dai; `swapDaiToSai` - a function that allows you to exchange your Dai back to Sai; and `migrate`, a function that allows you to migrate your SCD CDP to MCD. The following sections will go deeper into these function calls. The migration portal will present this functionality in an easy to use UI, so a regular user will not have to deal with these function calls directly, however we will dive into them in the following sections to dissect how migration works, and outline the process for power users or partners, who want to carry out migration themselves.

### Upgrading Dai

In order to upgrade your Dai to MCD, you must use the [swapSaiToDai](https://github.com/makerdao/scd-mcd-migration/blob/master/src/ScdMcdMigration.sol#L59) function in the migration contract. First you must approve that the migration contract can transfer Sai tokens from your account. Then you are ready to invoke the swap by calling the function specifying the amount of Sai you want to upgrade to Dai. A detailed walk-through using CLI tools to carry out this function can [be found here](https://github.com/makerdao/developerguides/blob/master/mcd/upgrading-to-multi-collateral-dai/cli-mcd-migration.md).

  

What happens on the back end, is that the deposited Sai tokens are actually used to create a single giant CDP in the MCD system for all migrating users, of which Dai is minted against. The migration contract will thus take the Sai tokens from your account, and deposit them into the Sai token adapter, which allows the CDP engine Vat, to utilize the tokens for CDP actions. The migration contract will then invoke Vat to lock Sai and issue Dai to the Dai adapter. The migration contract will then exit the Dai tokens from the Dai adapter, which is carried out by invoking a mint function on the Dai token contract which will generate new Dai for the originator’s Eth address. The process and function calls are outlined in the diagram below.

  

![](https://lh4.googleusercontent.com/BtVK6iOF9ZyfhbX9RdWr1JD-RfxlxJSZKj_WpMBHxjOUsUApTRMDKFTlLNdoo_0rqj0gwWdS0LPv2fSsZw3naFRo-1HfUSVS-nYk5qQCJjiPZk-y-m2ozOXRQk9l91HV8EETSEl8)

  

The following diagram outlines what happens when migrating 10 Sai to 10 Dai.

![](https://lh3.googleusercontent.com/6noyZ6-XA3B0Nd48SrnXtcAub6HT8U_K2TKxWA8TqDKKSWMIRT_51kcIUjP6_9XjU1prsfpHE1zU-A168-yse_NEeNFy1LvEpiW_Eome5W3aYhoBv5csXX05o5QSzHDNhTfn_isn)

  

### Swapping back to Sai

The migration contract also allows users to “go back” by swapping Dai for Sai, using the function [swapDaiToSai](https://github.com/makerdao/scd-mcd-migration/blob/master/src/ScdMcdMigration.sol#L75). In this case, the CDP operation is reversed, as Dai is paid back to the system, and Sai is released, just like the repayment of a normal CDP, except with no stability fee cost.

However, doing this operation is dependant on a surplus of Sai already deposited in the migration contract. Therefore there must be at least equivalent amount of Sai deposited in the contract, to the amount of Dai you want to redeem. This function call is very similar to the former, except this time Dai is deposited to the CDP, and Sai collateral released. This requires you to approve that the migration contract can transfer Dai from your wallet, and then you invoke the `swapDaiToSai` function with the specified amount of Dai you want to redeem. You can check out [this guide](https://github.com/makerdao/developerguides/blob/master/mcd/upgrading-to-multi-collateral-dai/cli-mcd-migration.md) for a more detailed look into how you call the functions.

### Migration of CDP

The migration contract also allows users to migrate their CDPs from the SCD core to the MCD core. This is done through the function [migrate](https://github.com/makerdao/scd-mcd-migration/blob/master/src/ScdMcdMigration.sol#L90). The function essentially tries to close your CDP, using excess Sai deposited in the migration contract (by other users who have been upgrading Sai to Dai) to pay your outstanding CDP debt. The migration contract will thus take control of your CDP, pay back the debt using Sai deposited in the contract, redeem the ETH collateral, create a new CDP in the MCD system, lock in the ETH collateral, and burn the created Dai, resulting in an equivalent CDP debt. However, in order to close down the CDP, a stability fee in MKR must be paid, so you need to grant the migration contract approval to spend MKR from you account to carry out the migration.

  

The migration contract uses a proxy contract to carry out all the above steps in one go. Consequently, the contract can also only be used for CDPs that have been created through a Maker proxy contract. This happens automatically if you have opened your CDP at [cdp.makerdao.com](https://cdp.makerdao.com/). Therefore, you must utilize the [ProxyLib.sol](https://github.com/makerdao/scd-mcd-migration/blob/master/src/ProxyLib.sol) contract to carry out the [migrate function call](https://github.com/makerdao/scd-mcd-migration/blob/master/src/ProxyLib.sol).

If you have created CDPs using third party services that do not use Maker proxies to interact with the CDP core, the migration contract might not work.

  

To migrate your CDP, your are also dependant on excess liquidity of Sai in the migration contract to be used to close your CDP. If you have a 10.000 Sai debt CDP you want to migrate, there must be at least 10.000 Sai in the migration contract (from user’s upgrading Sai to Dai), to carry out the CDP migration. The migration cannot be carried out partially, why the whole debt of the CDP must be covered by Sai liquidity in the contract to carry out the migration. If you have a large CDP and are concerned about migration, feel free to reach out to the Integrations Team at [integrate@makerdao.com](mailto:integrate@makerdao.com)

### Migration via CLI

Instead of using the Migration Portal, you can also choose to carry out migration by interacting with the smart contracts directly. We have created [a guide](https://github.com/makerdao/developerguides/blob/master/mcd/upgrading-to-multi-collateral-dai/cli-mcd-migration.md) that showcases how to do this using the CLI tools Seth and MCD-CLI as an example. The guide will explain in depth the different function calls and will be helpful for users or partners who have created implementations that interact directly with the Maker core. [Check out the guide here.](https://github.com/makerdao/developerguides/blob/master/mcd/upgrading-to-multi-collateral-dai/cli-mcd-migration.md)

## Partner Migration Scenarios

### As a Dai holder

#### You control your private key

If you hold your Dai in a wallet where you control your private keys, then head to migrate.makerdao.com and follow the instructions to upgrade your Dai and optionally activate Savings Dai, which allows you to earn savings.

The following figure outlines the migration flow:

![](https://lh6.googleusercontent.com/M406Z_MlqABR2Ry9m5_gwK8PWNPx9sUAs3NbazwH7pvvWh8gSIPxhzGlMXxvCk17voxByaRB-cQeKZfJ3DvD8_O4biGrZL7eA8LyJB7rH1ZkqaulxJXijjNOGCtMwVsAWIxoujUZ)

#### You don’t control your private key

If your Dai is in an exchange or centralized wallet or locked in a dApp smart contract, you can follow the instructions these platforms are providing or withdraw the DAI and complete the upgrade yourself at migrate.makerdao.com

With MCD you can deposit your Dai into a Savings Dai smart contract that will give you accrued annual savings. Find more info at makerdao.com at launch.

### As a SCD CDP owner

As a SCD CDP owner you can move your CDP to the MCD CDP through the migration portal at migrate.makerdao.com at launch. The following diagram shows the flow for CDP migration.

![](https://lh3.googleusercontent.com/d_oq0anvtS6LC2At7p8H2cD9KCyIhR1l0HyAEUMqzT-6gAOwdKMkmgZxIXazlZykU41Sp1bBm6c1XJp03DoHDaLrNczSEgJSsv1Dojfb-yW2q5M-PrtFNA1aiz_2ES6z1BsTiOGg)

You can also choose to close your CDP by paying back your debt and redeeming your Ether, and use your redeemed collateral to open a new MCD CDP.

If you have a large SCD CDP, the migration contract might not have enough Sai liquidity to carry out the migration. In that case, feel free to contact [integrate@makerdao.com](mailto:integrate@makerdao.com) for assistance.

Once upgraded, you can start using Savings Dai by locking your Dai into the Savings Dai smart contract and receive annually accrued savings. Find more info on makerdao.com at launch.

### As a Centralized Exchange or Custodial Wallet

We recommend you take the following steps for upgrading to MCD:

-   Inform your users as soon as possible about the timeline for your own integration and cut-off dates for the upgrade.
    
   
    
-   On cut-off date:
    

	-   Freeze Dai trading/transfers
    
	-   Use migration portal/contract to upgrade all user holdings of SCD (Sai) to MCD (Dai).
    
	-   Point codebase to new Dai token contract address, which will be announced at launch.
    
	-   Unfreeze Dai trading/transfers.
    

-   Inform users about Savings Dai, which allows Dai holders to earn savings.
    

	-   Optional: Integrate Savings Dai and distribute profits to your users
    
	-   Optional: Integrate Savings Dai in your exchange and profit from accrued annual savings.
    

![](https://lh4.googleusercontent.com/Xc1Iz7X8uber53uA1qmNfvyz33rxEbzvvjyz2fGbVzgq1zsFgTojqUUvGdY9_HbslMFIuHptFoEA_o1gC2aDeDSNDi7Ij9Xh8qWtncTHJtCALOIbwjWFsyZatwKImbvwAnotaPQQ)

This approach will result in the following User Journey for the exchange/wallet user:

![](https://lh5.googleusercontent.com/oaYTzBstVZOktWCiSbP3qculwKflBcZ6S2d3WeJuf72GqwmqIIkBZnzDtDrolzdtdxy5ehHNGyxwYl4Z26p8EJrBXL6FYEQdOKCiQ-oIj9oavXcybPQml_b47grXgGQIjcqWnm0g)

### As a Decentralized Exchange

We recommend you take the following steps for upgrading to MCD:

-   Inform your users as soon as possible about the timeline for your own integration of supporting the new (MCD) Dai token.
    
-   Have both Single-Collateral Dai (SCD) and MCD (Multi-Collateral Dai) listed concurrently for a period of time until trade demand for SCD diminishes.
    
-   After the launch of MCD, the new Dai token should be named Dai on your platform. Single Collateral Dai (SCD - the old token) should be named Sai
    
-   Inform users via an alert or warning when they begin a trade of SCD or MCD.
    
-   If there are smart contracts with the address of SCD hard-coded, update the address to the address for MCD which will be published at launch.
    
-   Inform users that they can redeem SCD for MCD at migrate.makerdao.com
    
-   Inform users about Savings Dai, which allows Dai holders to earn savings.
    

	-   Optional: Build a UI that facilitates the usage of the Savings Dai service for your users in your exchange, where users will keep the accrued savings themselves.
    
	-   Optional: Link users to a page on makerdao.com to activating savings, which will be announced at launch.
    

## As a relayer

-   Follow the updates from the exchanges that you’re relaying.
    
-   Update the contract addresses to the new MCD DAI, which will be announced at launch.
    

## As a non-custodial wallet

If you are a creator of a wallet that allows users to be in control of their private keys we recommend you do the following:

-   Inform your users as soon as possible about the timeline for your own integration of MCD.
    
-   Inform your users that they will be able to swap SCD for MCD at [migrate.makerdao.com](https://migrate.makerdao.com/).
    
-   Inform users about Savings Dai, which allows Dai holders to earn savings.
    

-   Optional: Create a UI where users can activate Savings Dai.
    
-   Optional: Link users to a page on makerdao.com for activating savings, which will be announced at launch.
    

## As a Keeper

-   Get acquainted with the updates to Keepers in MCD with [this guide](https://github.com/makerdao/developerguides/blob/master/keepers/auctions/auctions-101.md).
    
-   Refactor your codebase to point to the MCD contract addresses, which will be announced at launch.
    

## As a Market Maker

-   As a market maker you should update the Dai currency pairs according to the instructions given by the exchange.
    

# Summary

In this guide, we introduced you to the steps of how to upgrade to the Multi-Collateral Dai. We have provided you with explanations for the different platforms that you may be relying upon, be it an exchange or a simple Dai holder. As we approach the launch of Multi-Collateral Dai, more details will be made available.

# Troubleshooting

If you encounter any issues with your upgrade process, don’t hesitate to contact us.

-   Contact integrations team - integrate@makerdao.com
    
-   Rocket chat - #dev channel
    

# Next Steps

After finishing this guide we think you’ll enjoy these next guides:

-   Learn about our progress towards the launch of [MCD](https://blog.makerdao.com/multi-collateral-dai-milestones-roadmap/).
    

# Resources

Info:

-   [Blog post: The Road To Mainnet Release](https://blog.makerdao.com/the-road-to-mainnet-release/)   

  

Guides:

-   [Introduction and Overview of Multi-Collateral Dai: MCD101](https://github.com/makerdao/developerguides/blob/master/mcd/mcd-101/mcd-101.md)
    
-   [Using MCD-CLI to create and close a MCD CDP on Kovan](https://github.com/makerdao/developerguides/blob/master/mcd/mcd-cli/mcd-cli-guide-01/mcd-cli-guide-01.md)
    
-   [Using Seth to create and close an MCD CDP on Kovan](https://github.com/makerdao/developerguides/blob/master/mcd/mcd-seth/mcd-seth-01.md)
    
-   [Using Seth for MCD migration](https://github.com/makerdao/developerguides/blob/master/mcd/upgrading-to-multi-collateral-dai/cli-mcd-migration.md)
    
-   [Add a new collateral type to DCS - Kovan](https://github.com/makerdao/developerguides/blob/master/mcd/add-collateral-type-testnet/add-collateral-type-testnet.md)
    

Source code/wiki:

-   [Multi Collateral Dai code + wiki](https://github.com/makerdao/dss)
