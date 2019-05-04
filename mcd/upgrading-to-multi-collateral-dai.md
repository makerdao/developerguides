# Upgrading to Multi-Collateral Dai    
**Level**: Intermediate   
**Estimated Time**: 5 -20 minutes    
**Audience**: Technical and commercial teams with partners and Dai holders
## Overview
This guide gives a high level overview of the upgrade process for different actors in the Maker ecosystem. More details will become available as we close in on Multi-Collateral Dai (MCD) launch.  
The steps necessary to migrate from Single-Collateral Dai (SCD) to Multi-Collateral Dai differ depending on your platform and use case for Dai, so the guide is split into sections.  

## Learning Objectives
- Use the Redeemer & Migration Tool
- Upgrade to Multi-Collateral Dai

## Pre-requisites
- Knowledge of the [ERC20 token standard.](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md)
- Basic knowledge of the [MakerDAO: DAI and/or CDP system.](https://github.com/makerdao/awesome-makerdao) 
  
## Sections
- As a Decentralized Exchange
- As a Centralized Exchange
- As a Relayer
- As a Wallet Creator
- As a Keeper
- As a Dai holder
- As a SCD CDP owner
- As a Market Maker

## As a Decentralized Exchange
We recommend you take the following steps for upgrading to MCD:    
- After launch of MCD, inform your users as soon as possible about the timeline for your own integration.
- Have both Single-Collateral Dai (SCD) and MCD listed concurrently for a period of time until trade demand for SCD diminishes.
- After the launch, MCD should be named Dai on your platform. SCD should be named Sai
- Inform users via an alert or warning when they begin a trade of SCD or MCD
- If there are smart contracts with the address of Dai hard-coded, update the address to the address for MCD which will be published at launch
- Inform users where to redeem SCD for MCD. We will announce tools for this closer to launch.
- Inform users about Savings Dai, which allows Dai holders to earn savings.
  - Optional: Build a UI that facilitates the usage of the Savings Dai service for your users in your exchange, where users will keep the accrued savings themselves.
  - Optional: Link users to a page on makerdao.com for activating savings, which will be announced at launch.    
  
## As a Centralized Exchange
We recommend you take the following steps for upgrading to MCD:
- After launch of MCD, inform your users as soon as possible about the timeline for your own integration.
- Have both SCD and MCD listed concurrently for a period of time until trade demand for SCD diminishes.
- After the launch, MCD should be named Dai. SCD should be named Sai
- Shortly after launch, use the Redeemer smart contract to swap all user’s SCD for MCD
  - Inform users of Dai upgrade and offer an Opt-out method as a withdrawal of funds by a certain date.
    - Opt-out could also be a user setting, preferably communicated as “not recommended”.  
- Inform users about Savings Dai, which allows Dai holders to earn savings.
  - Optional: Integrate Savings Dai and distribute profits to your users
  - Optional: Integrate Savings Dai in your exchange and profit from ~2% accrued annual savings. 

## As a relayer
- Follow the updates from the exchanges that you’re relaying. 
- Update the contract addresses to the new MCD DAI, which will be announced at launch.

## As a non-custodial wallet 
If you are a creator of a wallet that allows users to be in control of their private keys we recommend you do the following:
- After launch of MCD, inform your users as soon as possible about the timeline for your own integration.
- Provide them relevant links to where they can do the swap. This will be available on makerdao.com at launch.
- Inform users about Savings Dai, which allows Dai holders to earn savings.
    - Optional: Create an UI where users can activate Savings Dai.
    - Optional: Link users to a page on makerdao.com for activating savings, which will be announced at launch. 

## As a custodial wallet
If you are a creator of a wallet that has control over users’ private keys, i.e. a centralized wallet, we recommend you do the following:
- After launch of MCD, inform your users as soon as possible about the timeline for your own integration.
- Choose from these:
  - Option A: Perform the upgrade through our redeemer service which will be announced at launch
  - Option B: Provide option to opt-out through a withdrawal of funds and link to more information that can be found on makerdao.com at launch. 
- Inform users about Savings Dai, which allows Dai holders to earn savings. 
  - Accumulate or distribute the profits to your users from integrating Savings Dai.
  
## As a Keeper
Update your codebase to point at the MCD DAI contract addresses, which will be announced at launch.    

## As a Dai holder    
### You control your private key
If you hold your Dai in a wallet where you control your private keys, then head to a page on makerdao.com which will be announced at launch. Follow the instructions to upgrade to MCD and optionally activate Savings Dai, which allows you to earn savings.    

### You don’t control your private key
If your Dai is in an exchange or centralized wallet or locked in a dApp smart contract, you can follow the instructions these platforms are providing or withdraw the DAI and complete the upgrade yourself at a page on makerdao.com which will be announced at launch. 

With MCD you can deposit your Dai into a Savings Dai smart contract that will give you ~2% accrued annual savings. Find more info on a page at makerdao.com at launch. 

## As a SCD CDP owner    
As a SCD CDP owner you can move your CDP to the MCD CDP through the redeemer portal that you’ll find at makerdao.com at launch. Or close your CDP by paying back your debt and redeeming your ether back.    

Once upgraded, you can start using Savings Dai by locking your Dai into the Savings Dai smart contract and receive around ~2% annually accrued savings. Find more info on makerdao.com at launch. 

## As a Market Maker    
As a market maker you should update the Dai currency pairs according to the instructions given by the exchange.    

## Summary
In this guide, we introduced you to the steps of how to upgrade to the Multi-Collateral Dai. We have provided you with explanations for the different platforms that you may be relying upon, be it an exchange or a simple Dai holder. As we approach the launch of Multi-Collateral Dai, more details will be made available.    

## Troubleshooting    
If you encounter any issues with your upgrade process, don’t hesitate to contact us.
- Contact integrations team - integrate@makerdao.com
- Rocket chat - #dev channel

## Next Steps     
After finishing this guide we think you’ll enjoy these next guides:
- Learn about our progress towards the launch of [MCD](https://blog.makerdao.com/the-road-to-mainnet-release).

## Resources
- https://blog.makerdao.com/the-road-to-mainnet-release/ 
