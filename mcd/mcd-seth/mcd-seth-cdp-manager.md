# Seth CDP Manager Guide 

**Level:** Intermediate

**Estimated Time:** 30 minutes 

This guide works under the [0.2.11](https://changelog.makerdao.com/releases/0.2.11/index.html) kovan release of the system

# Overview

The [DssCdpManager](https://github.com/makerdao/dss-cdp-manager) as known as the CDP Manager, was created to enable a formalised process to interact with the Dai Credit System with the CDP's. The manager works by having a [dss](https://github.com/makerdao/dss)  wrapper that allows users to interact with their CDP's in an easy way, treating them as non-fungible tokens (NFTs).

In addition to the [dss-proxy](https://github.com/makerdao/dss-proxy-actions), the CDP Manager is the recommended interface to engage with the Dai Credit System as it allows users to easily transfer their CDP's to each other if need be. In addition, each CDP created through this interface gets an ID, which can then be used for purposes such as tracking your CDP positions, or attaching this ID to another reference in your own system. 

By using the CDP Manager directly, the wallet users will be the direct owners of the CDP's. Compared to the dss-proxy, which the dss-proxy address will be the owner of the CDP's and the users will be owners of the proxy. 

# Learning Objectives

This guide will help you understand the functions available in the CDP Manager by walking you through the lifecycle of a CDP. 

The lifecycle being:

- Lock collateral in the system
- Draw Dai
- Pay back Dai
- Unlock collateral from system

# Pre-requisites

You will need to have a good understanding of these concepts and tools in order to follow along this guide,

- [MCD 101](https://github.com/makerdao/developerguides/blob/master/mcd/mcd-101/mcd-101.md)
- Solidity
- [Seth](https://github.com/dapphub/dapptools/tree/master/src/seth)

# Guide

Before starting this guide please install [dapptools](https://dapp.tools/) and [setup seth](https://github.com/makerdao/developerguides/blob/master/devtools/seth/seth-guide-01/seth-guide-01.md) for use with the Kovan testnet.

## Setup

Execute these commands to initialise environment variables with addresses of the core Dai Credit System(DCS) contracts. In your terminal, execute:

    export CDP_MANAGER=0x7a4991c6bd1053c31f1678955ce839999d9841b1
    export MCD_VAT=0x04c67ea772ebb467383772cb1b64c7a9b1e02bca
    export REP=0xc7aa227823789e363f29679f23f7e8f6d9904a9b
    export MCD_JOIN_REP_A=0x91f4e07be74445a3897b6d4e70393b5ad7b8e4b0
    export MCD_DAI=0xdb6a55a94e0dd324292f3d05cf504c751b31cee2
    export MCD_JOIN_DAI=0xcf20652c7e9ff777fcb3772b594e852d1154174d
    export ETH_GAS=2000000

We'll use kovan REP tokens as our collateral in this guide. If you need to get some kovan REP tokens, follow [this guide.](https://github.com/makerdao/developerguides/blob/master/mcd/mcd-seth/mcd-seth-01.md#getting-tokens) 

## The CDP Lifecycle

The CDP lifecycle involves the process of locking some collateral token that is [approved](https://blog.makerdao.com/multi-collateral-dai-collateral-types/) by the MKR token holders into the system, drawing Dai against this token, [using Dai,](https://github.com/makerdao/awesome-makerdao#use-your-dai) paying back Dai into the system and freeing back the locked collateral. 

### Locking collateral into the system

As we use the CDP Manager for interacting with the system, first you'll need to just `open` an empty CDP. 

CDP Manager provides two types of the `open` functions:

    function open(bytes32 ilk) public returns (uint cdp);
    function open(bytes32 ilk, address usr) public note returns (uint);

No matter what function you call, you'll receive a `cdpId` of your CDP.`(bytes32 ilk)` is the type of collateral you have to define in the function so that you'll create a specific `urn`. Each `urn` can only have one type of collateral. Hence, you as a user can open many urns with different or same collaterals. This approach gives you flexibility if you want to handle many CDPS(urns). 

An example where one would use this method of opening many urns, is custodial exchanges that want to integrate CDP's onto their platform. As the users don't have access to their keys to interact with the CDP, the exchange could open each user a CDP and link the `cdpId` to the `userId`. 

The function with just one parameter `(bytes32 ilk)` will open a CDP for your address. 

The function with two parameters `(bytes32 ilk, address usr)` will open a CDP for a specific address you want. 

Let's define the `ilk` before we call the `open` function. 

    export ilk=$(seth --to-bytes32 $(seth --from-ascii "REP-A"))

Now let's call the `open` function. 

    seth send $CDP_MANAGER 'open(bytes32)' $ilk

To get the `cdpId`, execute:

    seth call $CDP_MANAGER 'last(address)' $ETH_FROM

Output:

`0x0000000000000000000000000000000000000000000000000000000000000005`

So, the `cdpId` is `5`. 

Besides the `cdpId`, we need to get the `urn` address as well. That's where  `ink`(collateral balance) and `art`(outstanding stablecoin debt) is registered. 

Keep in mind to change `5` to your `cdpId`. 

    export urn=$(seth call $CDP_MANAGER 'urns(uint)(address)' 5)

---

After acquiring the `cdpId` and `urn` address, we can move to the next step. Locking our tokens into the system. This process has two steps:

- Approving `MCD_JOIN_REP_A` adapter to withdraw `REP` from our wallet
- Send `REP` to the `urn` address.

Let's define the value of collateral that we will lock, `dink`, and the value of Dai that we'll draw, `dart`.

    export dink=$(seth --to-uint256 $(seth --to-wei 20 eth))
    export dart=$(seth --to-uint256 $(seth --to-wei 5 eth))

Approving `MCD_JOIN_REP_A` adapter to withdraw `dink` `REP`. 

    seth send $REP 'approve(address,uint)' $MCD_JOIN_REP_A $dink

Sending `dink` amount of `REP` to the `urn`.

    seth send $MCD_JOIN_REP_A 'join(address,uint)' $urn $dink

Now we can lock our `REP` into the system and draw `Dai` against it. We can do it all in one function. Keep in mind to change `5` to your `cdpId`.

    seth send $CDP_MANAGER 'frob(uint,int,int)' 5 $dink $dart

**NOTE:**
You can use the other `frob(uint, address, int, int)` function with the extra `address` parameter. With this function, you will send the newly created `DAI` to your `ETH_FROM` address and not the `urn`. Skipping the `CDP_MANAGER.move()` function. 

Let's check the status of our `urn` by calling `VAT`.

    seth call $MCD_VAT 'urns(bytes32,address)(uint256,uint256)' $ilk $urn

Output:

    000000000000000000000000000000000000000000000001158e460913d00000
    0000000000000000000000000000000000000000000000004563918244f40000

If converted to decimals we get this:
`20.000000000000000000` <- Dink
`5.000000000000000000` <- Dart

This tells us that our `CDP` has 20 `REP` as collateral and `5` `DAI` as outstanding debt. 

---

### Draw Dai

So, what has been done til now was the creation of Dai debt in the system. In short, you create a balance of your debt in the system. After, you need to add this balance to your wallet.  Now, to actually withdraw it to your own address, we will need to do some functions calls:

    CDP_MANAGER.move(uint,address,uint);
    MCD_VAT.hope(address);
    MCD_JOIN_DAI.exit(address,uint)

`CDP_MANAGER.move()` function **moves** the `Dai` from the urn to your `ETH_FROM`, your personal address. However, you still won't see the balance on your wallet. In order to see the balance, you'll need to approve the `MCD_JOIN_DAI` adapter in `MCD_VAT` from the system with the `MCD_VAT.hope()` function. After, you call the `MCD_JOIN_DAI.exit()` to finally move the `DAI` to your wallet. This looks a bit of a complicated process, but this just shows how the system operates. 

Moving `DAI` from `urn` to `ETH_FROM`(your address). 
Defining `rad`, a high precision number. In `VAT` the debt balance is registered with a higher precision number than on your wallet. 

    export rad=$(seth --to-uint256 $(echo "5"*10^45 | bc))
    seth send $CDP_MANAGER 'move(uint,address,uint)' 5 $ETH_FROM $rad

Approving `MCD_JOIN_DAI` to `exit` in `MCD_VAT`.

    seth send $MCD_VAT 'hope(address)' $MCD_JOIN_DAI

Exiting `DAI` to own wallet address. 

    seth send $MCD_JOIN_DAI 'exit(address,uint)' $ETH_FROM $dart

Finally, we have got our new `DAI` on our wallet. To check the balance, execute the below command. 

    seth --from-wei $(seth --to-dec $(seth call $MCD_DAI 'balanceOf(address)' $ETH_FROM))

---

### Pay back Dai

Paying back Dai involves calling a set of functions as well. They are:

    MCD_DAI.approve(address,uint);
    MCD_JOIN_DAI.join(address,uint);
    CDP_MANAGER.frob(uint,int,int)

The first one is to approve `MCD_JOIN_DAI` to take `DAI` from your wallet. 
Second, you send the `DAI` to your `urn`. 
Third, you pay back `DAI` in the `VAT`. 

Approving  `MCD_JOIN_DAI` to take `DAI` from your wallet:

    seth send $MCD_DAI 'approve(address,uint)' $MCD_JOIN_DAI $dart

Sending `DAI` to your `urn`. By setting the `address` parameter to `urn` in `join(address, uint)` you skip the step of needing to use the `move` function in the `CDP_MANAGER`. 

    seth send $MCD_JOIN_DAI 'join(address,uint)' $urn $dart

Paying back `DAI` involves calling the `CDP_MANAGER.frob()` function with negative `dink` and `dart` values. In other words, we're just changing the balance to 0 in `VAT`. This of course involves sending the `DAI` to the system, which gets burned, and unlocking the collateral in your `urn`.  

    export nDink=$(seth --to-uint256 $(mcd --to-hex $(seth --to-wei -20 eth)))
    export nDart=$(seth --to-uint256 $(mcd --to-hex $(seth --to-wei -5 eth)))
    seth send $CDP_MANAGER 'frob(uint,int,int)' 5 $nDink $nDart

---

### Unlock collateral from system

Now we need to take the collateral from the `urn` and have it sent back to your address. `5` being your `cdpId`, `ETH_FROM` your address and `dink` the amount of collateral locked into the system. 

    seth send $CDP_MANAGER 'flux(uint,address,uint)' 5 $ETH_FROM $dink

**NOTE:** 
You could skip the above step if you called the `CDP_MANAGER.frob(uint, address, int, int)` function. As you can see this function has an extra parameter, `address`. If you call this function instead, the locked collateral is sent directly to your address and not to the `urn`. After this, you just have to call the `MCD_JOIN_REP_A.exit(address, uint)` function to get your collateral. 

Let's exit the collateral from the `REP` adapter. 

    seth send $MCD_JOIN_REP_A 'exit(address,uint)' $ETH_FROM $dink

To see if you got your collateral back in your wallet, just check your `REP` balance:

    seth --from-wei $(seth --to-dec $(seth call $REP 'balanceOf(address)' $ETH_FROM))

Congrats! You have issued and payed back DAI through the CDP Manager.

## Help
---
- Contact Integrations team - integrate@makerdao.com
- Rocket chat - [#dev](https://chat.makerdao.com/channel/dev) channel 
