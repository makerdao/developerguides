---
title: DsrManager
description: Learn about DsrManager and integrate with DSR
parent: dai
tags:
  - dai
	- DSR
  - dsrManager contract
  - integrate with DSR
slug: dsr-manager-guide
contentType: guides
root: false
---

# DsrManager

**Level**: Beginner  
**Estimated Time**: 10 minutes

- [DsrManager](#dsrmanager)
  - [Deployment Details](#deployment-details)
  - [Contract Details](#contract-details)
    - [Math](#math)
    - [Storage](#storage)
  - [Functions and mechanics](#functions-and-mechanics)
    - [daiBalance(address usr) returns (uint wad)](#daibalanceaddress-usr-returns-uint-wad)
    - [join(address dst, uint wad)](#joinaddress-dst-uint-wad)
    - [exit(address dst, uint wad)](#exitaddress-dst-uint-wad)
    - [exitAll(address dst)](#exitalladdress-dst)
  - [Gotchas / Integration Concerns](#gotchas--integration-concerns)

The `DsrManager` provides an easy to use smart contract that allows service providers to deposit/withdraw dai into the DSR contract  [pot](https://docs.makerdao.com/smart-contract-modules/rates-module/pot-detailed-documentation), and activate/deactivate the Dai Savings Rate to start earning savings on a pool of dai in a single function call. To understand the DsrManager, it is necessary to have an understanding of the  [pot](https://docs.makerdao.com/smart-contract-modules/rates-module/pot-detailed-documentation) first. The DSR is set by Maker Governance, and the purpose of DSR is to offer another incentive for holding Dai.

## Deployment Details

- Mainnet: [0x373238337Bfe1146fb49989fc222523f83081dDb](https://etherscan.io/address/0x373238337Bfe1146fb49989fc222523f83081dDb#code)
- Kovan: [0x7f5d60432DE4840a3E7AE7218f7D6b7A2412683a](https://kovan.etherscan.io/address/0x7f5d60432DE4840a3E7AE7218f7D6b7A2412683a#code)
- Ropsten: [0x74ddba71e98d26ceb071a7f3287260eda8daa045](https://ropsten.etherscan.io/address/0x74ddba71e98d26ceb071a7f3287260eda8daa045#code)

## Contract Details

### Math

- `wad`  - some quantity of tokens, as a fixed point integer with 18 decimal places.
- `ray` - a fixed point integer, with 27 decimal places.
- `rad` - a fixed point integer, with 45 decimal places.
- `mul(uint, uint)`, `rmul(uint, uint)`, `add(uint, uint)` & `sub(uint, uint)` - will revert on overflow or underflow
- `Rdiv` - Divide two `ray`s and return a new `ray`. Always rounds down. A `ray` is a decimal number with 27 digits of precision that is being represented as an integer.
- `Rdivup` - Divide two `ray`s and return a new `ray`. Always rounds up. A `ray` is a decimal number with 27 digits of precision that is being represented as an integer.

### Storage

- `pot` - stores the contract address of the main Dai Savings Rate contract `pot`.
- `dai` - stores the contract address of dai.
- `daiJoin`  - stores the contract address of the Dai token adapter.
- `supply` - the supply of Dai in the DsrManager.
- `pieOf` - `mapping (addresses=>uint256)` mapping of user addresses and normalized Dai balances (`amount of dai / chi`) deposited into `pot`.
- `pie` - stores the address' `pot` balance.
- `chi` - the rate accumulator. This is the always increasing value which decides how much dai is given when `drip()` is called.
- `vat`  - an address that conforms to a `VatLike` interface.
- `rho` - the last time that `drip` is called.

## Functions and mechanics

### daiBalance(address usr) returns (uint wad)

- Calculates and returns the Dai balance of the specified address usr in the DsrManager contract. (Existing Dai balance + earned dsr)

### join(address dst, uint wad)

- `uint wad` this parameter specifies the amount of Dai that you want to join to the pot. The `wad` amount of Dai must be present in the account of `msg.sender`.
- address `dst` specifies a destination address for the deposited dai in the pot. Allows a hot wallet address (`msg.sender`) to deposit dai into the pot and transfer ownership of that dai to a cold wallet (or any other address for that matter)
- The normalized balance `pie` is calculated by dividing wad with the rate acumulator `chi`.
- the `dst`'s `pieOf` amount is updated to include the `pie`.
- The total supply amount is also updated by adding the `pie`.
- `wad` amount of dai is transferred to the DsrManager contract
- The DsrManager contract  joins `wad` amount of dai into the MCD system through the dai token adapter `daiJoin`.
- The DsrManager contract `join`s `pie` amount of dai to the `pot`.

### exit(address dst, uint wad)

- `exit()` essentially functions as the exact opposite of `join()`.
- `uint wad` this parameter is based on the amount of dai that you want to `exit` the `pot`.
- address `dst` specifies a destination address for the retrieved dai from the `pot`. Allows a cold wallet address (`msg.sender`) to retrieve dai from the `pot` and transfer ownership of that dai to a hot wallet (or any other address for that matter)
- The normalized balance `pie` is calculated by dividing wad with the rate acumulator `chi`.
- The `msg.sender`’s `pieOf` amount is updated by subtracting the `pie`.
- The total supply amount is also updated by subtracting the `pie`.
- The contract calls exit on the `pot` contract.
- It calculates the amount of dai to retrieve by multiplying `pie` with `chi`.
- Then exits the dai from the dai token adapter `daiJoin` to the destination address `dst`.

### exitAll(address dst)

- `exitAll()` functions like the `exit` function, except it simply looks into the mapping `pieOf`, to determine how much dai the `msg.sender` has, and `exit`s the entire amount of dai, instead of a specified amount.

## Gotchas / Integration Concerns

- In order to use the `join` function, you need to `approve` the contract to transfer Dai from your wallet. You need to call `approve` on the Dai token, specifying the `DsrManager` contract and the amount that the contract should be able to pull (can be set to `-1`, if you want to set an unlimited approval)
