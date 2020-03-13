# Emergency Shutdown Guide - MCD

**Level:** Advanced   
**Estimated Time:** 30 min   
**Audience:** Technical and commercial teams that hold Dai and/or own Vaults.   

  

# Overview

Emergency Shutdown (ES) is a fail-safe mechanism that can be triggered in the event of a serious threat to the Maker Protocol such as, but not limited to, governance attacks, long-term market irrationality, hacks and security breaches.

ES is triggered by the MKR holders, most likely after observing the threat implication to the system and concluding that there is no other alternative to manage the threat.

  

This guide will help you prepare and take the proper action in case of an Emergency Shutdown in the Maker Protocol. There are steps suited for each type of user and service provider that includes the Maker Protocol products.

# Learning Objectives

In this guide you will learn what steps to take according to your user profile in case of an ES event.

-   Knowledge on how the ES process will work
    
-   Best practices for ES for different users and partners
    
-   Where to find more guides on the specific emergency shutdown scenario
    

# Pre-requisites

-   Basic knowledge of the MakerDAO: Dai and/or Vault system. [See the MCD 101 guide, especially section 1 and 2.](https://docs.makerdao.com/maker-protocol-101)
    

# Sections

-   [Introduction](#introduction)    
    -   [Overview of the shutdown process](#Overview-of-the-shutdown-process)

-   [Emergency Shutdown Preparedness](#Emergency-Shutdown-Scenarios)
    
-   [User Stories](#Dai-Holders)
    
    -   [Dai Holders](#Dai-Holders)
    
    -   [Vault Owners](#Vault-Owners)
    
    -   [MKR Holders](#MKR-Holders)
    
    -   [Centralized Exchange or Custodial Wallet](#Centralized-Exchange-or-Custodial-Wallet)
    
    -   [Decentralized Exchange](#Decentralised-Exchange)
    
    -   [Non-Custodial Wallet](#Non-Custodial-Wallet)
    
    -   [Dapp Browses](#Dapp-Browsers)
    
    -   [Vault Integrators](#Vault-Integrators)
    
    -   [Dapps](#Dapps)
    
    -   [Keepers](#Keepers)
    
    -   [Market Makers](#Market-Makers)

 - [How to check if Emergency Shutdown has been triggered?](#How-to-check-if-Emergency-Shutdown-has-been-triggered?)
 - [CLI guide on how to redeem your Dai or excess collateral after ES](#CLI-guide-on-how-to-redeem-your-Dai-or-excess-collateral-after-ES)

 - [Summary](#Summary)
    

  

## Introduction

The Maker Protocol dictates that the Dai Target Price is 1 US Dollar, translating to a 1:1 US Dollar soft peg of the stablecoin Dai. Emergency Shutdown is a process that can be used as a last resort to directly enforce the Target Price to holders of Dai and Vaults, and protect the Maker Protocol against attacks on its infrastructure.

  

Emergency shutdown stops and winds down the Maker Protocol. As long as the protocol is adequately collateralised and all debt has been removed, first Vault holders, and subsequently Dai holders will receive the net value of assets they are entitled to.

  

In short, it allows Dai holders to directly claim an equivalent dollar-amount of collateral using their Dai after an Emergency Shutdown processing period, as the protocol directly enforces that 1 Dai entitles you to 1 US Dollar of collateral according to the price reported by the oracles at the moment when ES is triggered. The protocol makes it possible for the user to use Dai to claim a proportional amount of protocol collateral. The amount of collateral which can be claimed is determined by the Maker Oracles at the time ES is triggered.

  

### Overview of the shutdown process

-   The process of initiating Emergency Shutdown is controlled by MKR voters, who can trigger it by depositing MKR into the Emergency Shutdown Module.
    
-   Emergency Shutdown is supposed to be triggered in the case of serious emergencies, such as long-term market irrationality, hacks, or security breaches.
    
-   Emergency Shutdown stops and winds down the Maker Protocol while ensuring that all users, both Dai holders and Vault users, receive the net value of assets they are entitled to.
    
-   Vault owners have priority over Dai holders for claiming a proportional amount of underlying collateral (currently ETH and BAT). Vault holders will be able to repay any debt that they owe, which once repaid, will allow them to claim their underlying collateral. A user interface will allow the user to see their vaults(s), the underlying collateral and any associated debt, with the ability to pay this off. They can do this via Vault frontends, such as Oasis Borrow, that have Emergency Shutdown support implemented, as well as [via command-line tools](https://docs.makerdao.com/clis/emergency-shutdown-es-cli).
    
-   Dai holders, will need to wait for a cool down period of approximately 73 hours for the above debt to be repaid. Once this is completed, the user will be able to, per one unit of Dai, claim a proportional amount of all underlying collateral. It is worth noting that the user will not be able to choose any particular collateral type over another and will instead receive an equal distribution of supported collateral per quantity of Dai that they hold.
    
-   Dai holders always receive the same relative amount of collateral from the system, whether they are among the first or last people to process their claims. In other words, there is no race condition.
    
-   Dai holders may also sell their Dai to Keepers (if available) to avoid self-management of the different collateral types in the system.
    
-   Dai token remains fully functional as an ERC20 token all the time. Even though the Emergency Shutdown has been triggered, a user could transfer the token or invoke any other function in the Dai ERC20 contract.
    

  
![](https://lh6.googleusercontent.com/-1uUOYCTeE3gIf9hMIVHg8aONDoYPXY3wWANWX6elx1ZpeybB7x4OHGFklNXq3j04XMRJvoDPBkm1RowBpHgZLKNLO54RN1P7O6GoTlH5n3jXuSzd_qiT1_3gplngeXvWpya3iY)  
Emergency Shutdown Process - visualized

## Emergency Shutdown Scenarios

There are generally two scenarios in case of an Emergency Shutdown event.  
**The Redeployment Scenario** is when the system has been triggered into a shutdown event, but the MKR token holders, or a third party, have decided to redeploy the system with necessary changes to run the system again. This will allow users to open new Vaults and have a new Dai token while claiming collateral from the old system.

**The Shutdown Scenario** is when the Emergency Shutdown has been triggered and the system is being terminated without a future plan of system redeployment. This will allow users to claim excess collateral or claim collateral from their Dai.

## Emergency Shutdown Preparedness

In case of an emergency shutdown event, different MakerDAO communication channels will be alerted. Your first step is to go to these channels and update yourself with the current status.

  

## Dai Holders

-   Follow communication for latest development updates
    

    -   [Forum](https://forum.makerdao.com/)
        
    -   [Reddit](https://www.reddit.com/r/makerDAO/)
        
    -   [Social media](https://twitter.com/MakerDAO)
        
    -   [Blog](https://blog.makerdao.com/)
    

  

-   If your wallet has the interface to claim collateral or migrate your Dai or has a Dapp browser built into it, feel free to use it and/or head towards the [migration portal](https://migrate.makerdao.com/) for the claiming/migration process.
    
-   If your wallet does not support claiming of collateral or migration of Dai, withdraw your Dai to a wallet you control and head towards the [migration portal](https://migrate.makerdao.com/) for the claiming/migration process.  
      
    

## Vault Owners

-   Follow communication for latest development updates
    

    -   [Forum](https://forum.makerdao.com/)
        
    -   [Reddit](https://www.reddit.com/r/makerDAO/)
        
    -   [Social media](https://twitter.com/MakerDAO)
        
    -   [Blog](https://blog.makerdao.com/)
    

-   If you are using Oasis to manage your vault, head to the [migration portal](https://migrate.makerdao.com/), and follow the redemption process.
    
-   If you are a user of third party interfaces such as [DefiSaver](http://defisaver.com/) or [InstaDapp](https://instadapp.io/), verify that they have built the Emergency Shutdown Interfaces. If so, use their interface to claim excess collateral or migrate to a new deployed system.
    
-   In case of protocol redeployment, you can open a new vault with the claimed collateral.
    

## MKR Holders

-   Follow communication for latest development updates
    

    -   [Forum](https://forum.makerdao.com/)
        
    -   [Reddit](https://www.reddit.com/r/makerDAO/)
        
    -   [Social media](https://twitter.com/MakerDAO)
        
    -   [Blog](https://blog.makerdao.com/)
    

-   Vote on polls and executive votes as it relates the the re-deployment of the Maker Protocol on the [Governance Portal](http://vote.makerdao.com/)
    

  

## Centralized Exchange or Custodial Wallet

As a service provider you have to be up to date with the latest status from MakerDAO so you have the right information to take the proper action.

### Procedure

-   Alert users on the current situation and provide them guidance on the right action to take. Depending on the ES scenario, redeployment or shutdown, advise them to act accordingly.
    
-   Give users options to withdraw their Dai/MKR from exchange or inform them that the exchange/wallet will do the emergency shutdown process for them.
    
-   Scenario: Redeployment
    

-   Migrate Dai holdings to new Dai token on behalf of users using the [migration portal](https://migrate.makerdao.com/)
    
-   Alternatively carry out migration by interacting directly with the migration contracts.
    
-   If applicable, migrate MKR token holdings on behalf of users using the [migration portal](https://migrate.makerdao.com/)
    
-   Update token address(es) in your system
    

-   Scenario: Shutdown
    

-   Claim Dai equivalent in collateral on behalf of users using the [migration portal](https://migrate.makerdao.com/)
    
-   Choose one of the following:
    

-   Distribute collateral to users
    

-   Get withdrawal address from users for collateral types not supported on exchange
    

-   Or keep collateral (i.e. to sell off) and update user internal fiat balances to reflect their entitled amount.
    

## Decentralised Exchange

As a decentralized exchange you can inform users with a banner about the current status of the Maker Protocol and direct them towards relevant communication channels to find out more.

  

Choose one of the two following options to allow your users to carry out the ES redemption process:

-   Build an interface to do the ES process on your platform - inform your users and have them act accordingly.
    
-   Direct them to the [migration portal](https://migrate.makerdao.com/) where they can start the claiming process for their Dai.
    

### Procedure:

-   Scenario: Redeployment
    

-   Inform users to migrate their Dai to the new Dai (and MKR if applicable) on [migration portal](https://migrate.makerdao.com/) or create an interface to do the process on your platform.
    
-   Add new token(s) to the exchange.
    

-   Scenario: Shutdown
    

-   Inform users to claim equivalent value of Dai in collateral on the [migration portal](https://migrate.makerdao.com/) or create an interface to do the process locally.
    

## Non-Custodial Wallet

As a non-custodial wallet make sure to follow the latest updates from MakerDAO’s communication channels and update your users accordingly. Alert users about ES and provide links for more information:

-   Follow communication for latest development updates
    

    -   [Forum](https://forum.makerdao.com/)
        
    -   [Reddit](https://www.reddit.com/r/makerDAO/)
        
    -   [Social media](https://twitter.com/MakerDAO)
        
    -   [Blog](https://blog.makerdao.com/)
    

### Procedure

-   Scenario: Redeployment
    

-   Inform users to migrate their Dai on the [migration portal](https://migrate.makerdao.com/) or create internal interface to do the process locally
    
-   Add featured support for new token(s)
    

-   Scenario: Shutdown
    

-   Redirect users to the [migration portal](https://migrate.makerdao.com/) to claim their Dai equivalent in collateral or create interface to do the process locally
    

## Dapp Browsers

As a Dapp browser make sure to follow the latest updates from MakerDAO’s communication channels and update your users accordingly.

-   Follow communication for latest development updates
    

    -   [Forum](https://forum.makerdao.com/)
        
    -   [Reddit](https://www.reddit.com/r/makerDAO/)
        
    -   [Social media](https://twitter.com/MakerDAO)
        
    -   [Blog](https://blog.makerdao.com/)
    

-   Alert users about ES and provide links for more information.
    

-   Either if it’s a system shutdown or system redeployment after ES is triggered, redirect users to the [migration portal](https://migrate.makerdao.com/) to claim collateral or create an interface to do the process locally.
    

## Vault Integrators

Vault integrators can be services like [DefiSaver](http://defisaver.com/), [InstaDapp](https://instadapp.io/) or custodians like centralized exchanges that have integrated Vaults.

As a vault integrator it is very important that you have integrated with the Emergency Shutdown Services which will allow you to quickly create a reactive logic that will handle the post ES process for your users.

-   Follow communication for latest development updates
    

    -   [Forum](https://forum.makerdao.com/)
        
    -   [Reddit](https://www.reddit.com/r/makerDAO/)
        
    -   [Social media](https://twitter.com/MakerDAO)
        
    -   [Blog](https://blog.makerdao.com/)
    

### Custodial Vault Integrator

-   If you are a custodial service, make sure to inform your users in advance about your plan in handling the Emergency Shutdown event.
    

### Procedure

-   Scenario: Redeployment
    

-   Migrate users’ funds to a new redeployed system using the [migration portal](https://migrate.makerdao.com/) or by interacting directly with the migration contracts.
    

-   Scenario: Shutdown
    

-   Claim users’ funds through the [migration portal](https://migrate.makerdao.com/) or by direct interaction with the migration contracts and make them available in their accounts
    

### Non-Custodial Vault Integrator

-   As a non-custodial vault integrator make sure to have integrated the emergency shutdown service which you will be able to be notified at the exact moment the shutdown has been triggered.
    
-   Notify your users through the interface and direct them towards the right communication channels:
    

    -   [Forum](https://forum.makerdao.com/)
        
    -   [Reddit](https://www.reddit.com/r/makerDAO/)
        
    -   [Social media](https://twitter.com/MakerDAO)
        
    -   [Blog](https://blog.makerdao.com/)
    

-   Create an interface that will help users migrate their Dai in case of a new redeployment or allow users to claim their collateral in case of an only shutdown scenario.
    

## Dapps

Dapps involves services such as:

-   Lending Protocols
    
-   Aggregator Interfaces, eg, Zerion and DefiSaver
    
-   DSR Interfaces
    
-   Smart Contracts holding Dai
    

-   As a Dapp creator you should integrate the Emergency Shutdown Service which can notify you when the Emergency Shutdown has been triggered.
    
-   When the ES has been triggered:
    

-   Have an UI interface that alerts and informs users about the event
    
-   Or direct them towards the official communication channels for more information
    

### Custodial Dapps

If you control the access to the smart contracts backing your Dapp, then you can:

-   Migrate Dai to new Dai and/or claim excess Vault collateral of users in case of system redeployment.
    
-   Claim Dai collateral or claim excess collateral from Vault.
    

### Non-Custodial Dapps

If you don’t control the smart contracts backing your Dapp directly, then create an interface that allows your users to:

-   Migrate Dai to the new redeployed system and/or claim excess collateral from Vaults.
    
-   Claim Dai equivalent in collateral or claim excess collateral from Vaults in case of a system shutdown.
    

## Keepers

As a Keeper in the Maker Protocol it’s recommended that you prepare to:

-   Help Dai holders claim equivalent collateral, acting as a secondary market
    
-   Bid in the auction contracts in the Maker Protocol helping it settle any debt it might have
    
-   Migrate Dai to new Dai in case of system redeployment
    
-   Claim equivalent Dai collateral in the system after emergency shutdown
    

## Market Makers

-   As a market maker, your role is to provide liquidity in the market so Dai holders can exchange their Dai to other assets.
    
-   After there is no market to cover, you can act as a Dai holder and start migrating Dai to new Dai in case of system redeployment or claim equivalent Dai collateral in case of system wide shutdown.
    

  

# How to check if Emergency Shutdown has been triggered?

In addition to the emergency communication channels, you as a service provider can implement the Emergency Shutdown Services from the Maker Protocol so you can be notified of such an event right when it happens.

### Using Dai.js

Through [our Dai.js library](https://github.com/makerdao/dai.js/tree/dev/packages/dai-plugin-mcd) you can read the system’s status and be notified in an instant of any systemic change. Specifically, calling the [isGlobalSettlementInvoked()](https://github.com/makerdao/dai.js/blob/92df6c7ae89ec076062d0d64d2ae233365a117ef/packages/dai-plugin-mcd/src/SystemDataService.js#L29) function will provide you with the response.

### Using smart contracts

If your implementation requires communicating directly with the smart contracts, then you will find all the necessary data in the [END module](https://docs.makerdao.com/smart-contract-modules/shutdown/end-detailed-documentation) of the Maker Protocol. The END contract has a parameter called [`live`](https://github.com/makerdao/dss/blob/44330065999621834b08de1edf3b962f6bbd74c6/src/end.sol#L202) which is the Emergency Shutdown flag of the system.

  

When the system is running normally, the parameter [live is equal to one](https://etherscan.io/address/0xab14d3ce3f733cacb76ec2abe7d2fcb00c99f3d5#readContract), `live = 1`. In case of an Emergency Shutdown, the live parameter will equal to zero, as `live = 0`.

# CLI guide on how to redeem your Dai or excess collateral after ES
Head over to [this guide](https://docs.makerdao.com/clis/dai-and-collateral-redemption-during-emergency-shutdown) to learn how to redeem your Dai or excess collateral in case of an ES event.
  

# Summary

In this guide you have learned how to act in case of an Emergency Shutdown event in the Maker Protocol. You have received an introduction in the Emergency Shutdown module and have received information to make you an educated actor in the MakerDAO ecosystem.

  

# Additional Resources

-   If you’re curious to understand in more detail how the ES module works, head towards [our documentation page](https://docs.makerdao.com/smart-contract-modules/emergency-shutdown-module).
    
-   [We also have a CLI guide](https://docs.makerdao.com/clis/dai-and-collateral-redemption-during-emergency-shutdown) on how to do the claiming of Dai equivalent collateral or claiming excess collateral from your vault.
    

  

# Help

Reach us at:

-   [Rocket Chat](https://chat.makerdao.com/channel/dev)
    
-   Contact Integrations Team: integrate@makerdao.com