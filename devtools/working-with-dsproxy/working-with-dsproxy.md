# Working with DSProxy

**Level**: Advanced

**Estimated Time**: X - Y minutes

## Overview

Whether you are a Keeper looking to integrate the Dai Credit System with a new source of liquidity, or an interface developer looking to cut down the number of transactions an end user has to sign, you can now implement your ideas by creating simple scripts that can atomically perform transactions across multiple contracts through DSProxy.

Maker's approach to modularizing smart contracts and splitting logic into numerous tiny functions are great for security, but interface developers and end users interacting with them have to execute multiple transactions now to achieve a single goal. Instead of imposing the design constraints of good end-user ergonomics on the core smart contracts, we move it to an additional compositional layer of smart contracts built with DSProxy and stateless scripts.

Keeping this functionality in a separate layer also allows developers to add additional scripts over time when new user needs emerge and better methods to compose new protocols are developed.

Understanding the DSProxy design pattern will help you quickly develop scripts that compose functionality of existing smart contracts in novel ways. Developing core smart contracts with this pattern in mind can increase their security without sacrificing usability, while reducing overall complexity, and preserving atomicity of transactions when simultaneously interacting with multiple smart contracts.

## Learning Objectives

In this guide we will,

* Understand how DSProxy and scripts work through examples
* Understand the features of a DSProxy contract
* Build and deploy a new script
* Look at best practices of developing a script
* Additional details to help with deploying a script to production

## Pre-requisites

* DCS contracts
* CDPs
* Solidity development

## Guide

* [Examples](#examples)
* [Features](#dsproxy)
* [Tutorial](#create-a-script)
* [Best Practices](#best-practices)
* [Production Usage](#production-usage)

### Examples

#### Opening a CDP

Opening a CDP to draw Dai is a common action performed by users within the Dai Credit System(DCS) and they perform multiple transactions on the [WETH](https://example.com) and [Tub](https://example.com) contracts to complete it.

Transactions to execute on the WETH token contract are,

* Convert ETH to WETH using the `mint` function.
* Approve the [Tub](https://example.com) contract address to spend the user's WETH balance using the `approve` function.

Transactions to execute on the Tub contract are,

* Convert WETH to PETH using the `join` function.
* Open a new CDP using the `open` function.
* Add PETH collateral to the new CDP using the `lock` function.
* Draw DAI from the CDP using the `draw` function.

[CDP portal](https://cdp.makerdao.com) uses a [script](https://example.com) to improve the user experience by executing the above steps atomically within a single transaction. For comparison, you can check early interfaces like [dai.makerdao.com](https://dai.makerdao.com) which made users execute these steps separately.

#### Bust Arbitrage with DEXes

A CDP liquidation creates bad debt which needs to be erased from the system by selling a portion of the collateral locked in a CDP to raise the same amount of Dai from Keepers. Keepers monitor the Tub contract and execute the following transactions when they find an unsafe CDP to complete a successful arbitrage and realize a profit in Dai.

* `bite` an unsafe CDP on Tub. This clears the outstanding Dai debt of the CDP and transfers a portion of its locked collateral to the liquidator contract.
* Approve Tap contract address to spend the keeper's DAI balance using the `approve` function.
* Transfer Dai using `bust` on [Tap](https://example.com) liquidator contract to purchase PETH at a discount.
* `exit` on Tub to convert PETH back to WETH.
* Trade WETH for Dai on a DEX that offers the best price using its trade functions.
* `require` check to stop the entire sequence of actions if it results in a loss for the Keeper.

Keepers calling `bite` do not get a preference and anyone can call `bust` to buy the collateral at a discount. A successful arbitrage trade for the Keeper also means that they are able to sell WETH back on other markets to realize the discount offered by Tap as profit in Dai. To avoid these issues, Keepers having been using [scripts](https://example.com) to execute the above transactions atomically and avoid losses especially in an environment when the price of collateral is rapidly declining.

#### Pay stability fees with Dai

In Single Collateral Dai, CDP owners have to use MKR to pay stability fees when they close a CDP. Most of them are forced to buy a tiny amount of MKR from an exchange since not all of them are MKR holders. The sequence of transactions they have to execute when closing a CDP are,

* Trade DAI for the required amount of MKR on an exchange.
* Approve Tub contract address to spend the user's DAI balance using the `approve` function.
* Approve Tub contract address to spend the user's MKR balance using the `approve` function.
* `wipe` or `shut` on the Tub contract to pay back borrowed Dai.

The CDP portal uses a [script](https://example.com) to make the entire process seamless for CDP owners who do not hold MKR to buy the exact amount of MKR they need on the Eth2Dai exchange MKR/DAI market, and also pay back Dai to close the CDP in the same transaction.

### DSProxy

A user first deploys their own personal DSProxy contract and then uses it to call various scripts for the goals they wish to achieve. This DSProxy contract can also directly own digital assets long term since the user always has full ownership of the contract and it can be treated as an extension of the user's own ethereum address.

Scripts are implemented in Solidity as functions and multiple scripts are typically combined and deployed together as a single contract. A DSProxy contract can only execute one script in a single transaction. In this section we will focus on the features of a DSProxy contract and look at how scripts work in the next section.

#### Ownership

Ownership of a DSProxy contract is set to an address when it is deployed. There is support for authorities based on DSAuth if there is a need for ownership of the DSProxy contract to be shared among multiple users.

#### Execute

`execute(address target, bytes data)` function implements the core functionality of DSProxy. It takes in two inputs, an `address` of the contract containing scripts, and `data` which contains calldata to identify the script that needs to be executed along with it's input data.

`msg.sender` when the script is being executed will continue to be the user address instead of the address of the DSProxy contract.

`execute(bytes code, bytes data)` is an additional function that can be used when a user wants to deploy a contract containing scripts and then call one of the scripts in a single transaction. A `cache` registers the address of contract deployed to save gas by skipping deployment when other users call `execute` with the same bytecode later.

#### Event Logs

A DSProxy contract generates a event called `LogNote` with these values indexed when `execute()` is called,

* Function signature, `0x1cff79cd`
* Owner of the proxy contract, `msg.sender`
* Contract address which contains the script, `address`
* Calldata which contains function signature of script being executed and its input data, `data`

#### Factory Contract

The function  `build` in the DSProxyFactory contract is used to deploy a personal DSProxy contract. For production usecases on mainnet you can use a common factory contract that is already being used by existing projects to avoid deploying redundant DSProxy contracts for users who already have one. Please check the [Production Usage](https://example.com) section in this guide for more details.

### Create a script

Goal for the script
DCS wipe function
Uniswap liquidity

#### Environment Setup

We'll use `dapp` and `seth` while working through this section but you can also your own tool of choice to execute them. Instructions to install them can be found [here](https://example.com).

`~/.sethrc` file has to be configured with these values to work with the Kovan testnet,

* `SETH_CHAIN=kovan`
* `ETH_FROM=0xYourKovanAddressFromKeyStoreOrLedger`
* `ETH_GAS=4000000`
* `ETH_GAS_PRICE=2500000000`

Seth uses an Infura RPC URL by default but you can also configure `ETH_RPC_URL` and point it to your preferred end-point.

#### Create a new dapp project

Create a new folder and open it
`mkdir wipe-proxy && cd wipe-proxy`

Initialize a dapp project within it
`dapp init`

Add the DSMath library to the project to use safe math operations
`dapp install ds-math`

#### Setup WipeProxy.sol

Import the DSMath contract and inherit DSMath
`import "ds-math/math.sol";`

`contract WipeProxy is DSMath {`

Before we begin creating the script, we'll first add a few contract interfaces to be able to interact with functions from those contracts later in the script.

Add the `TubLike` interface to interact with CDPs on the Tub contract

```text
interface TubLike {
    function wipe(bytes32, uint) external;
    function gov() external view returns (TokenLike);
    function sai() external view returns (TokenLike);
    function tab(bytes32) external returns (uint);
    function rap(bytes32) external returns (uint);
    function pep() external view returns (PepLike);
}
```

Add the `TokenLike` interface to interact with functions on DAI and MKR tokens

```text
interface TokenLike {
    function allowance(address, address) external view returns (uint);
    function balanceOf(address) external view returns (uint);
    function approve(address, uint) external;
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
}
```

Add the `PepLike` interface to read the MKRUSD price from the Pep contract

```text
interface PepLike {
    function peek() external returns (bytes32, bool);
}
```

Add the `UniswapExchangeLike` interface to execute token swaps on a Uniswap exchange contract

```text
interface UniswapExchangeLike {
    function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) external returns (uint256  tokens_sold);
}
```

#### Implement script outline

Add a new function `wipeWithDai` which takes in the following inputs,

* Address of the Tub contract
* Address of the Uniswap DAI exchange contract
* Address of the Uniswap MKR exchange contract
* Id of the CDP in decimals. Ex: 44
* Amount of Dai debt to pay back on the CDP

```text
function wipeWithDai(
    address _tub,
    address _DAIExchange,
    address _MKRExchange,
    uint cupid,
    uint wad
) 
    public 
{
    // logic
}
```

#### Checks

Add `require(wad > 0);` to ensure some Dai debt is being wiped

#### Initialize variables

Initialize contracts to interact with their functions

```text
TubLike tub = TubLike(_tub);
UniswapExchangeLike daiEx = UniswapExchangeLike(_DAIExchange);
UniswapExchangeLike mkrEx = UniswapExchangeLike(_MKRExchange);

TokenLike dai = tub.sai();
TokenLike mkr = tub.gov();
PepLike pep =   tub.pep();
```

Add the following line to convert the input `cupid` into a left-padded bytes32 hex value that the Tub contract expects.

```text
bytes32 cup = bytes32(cupid);
```

#### Set all allowances

Add a `setAllowance` private function to the contract to reuse logic

```text
function setAllowance(TokenLike token_, address spender_) private {
        if (token_.allowance(address(this), spender_) != uint(-1)) {
            token_.approve(spender_, uint(-1));
        }
    }
```

Back in the `wipeWithDai` function, we can now set all the required allowances using this function.
Allow the Tub contract to debit DAI from the proxy contract, `setAllowance(dai, _tub);`
Allow the Tub contract to debit MKR from the proxy contract, `setAllowance(mkr, _tub);`
Allow the Uniswap DAI exchange contract to debit DAI from the proxy contract, `setAllowance(dai, _DAIExchange);`

#### Buy MKR with DAI on Uniswap

Read the current MKRUSD price
`(bytes32 val, bool ok) = pep.peek();`

Calculate the stability fees owed for the `wad` amount of dai debt being wiped from the CDP
`uint daiFee = rmul(wad, rdiv(tub.rap(cup), tub.tab(cup)));`

Calculate the amount of MKR that is needed for a successful executing wipe
`uint mkrFee = wdiv(daiFee, uint(val));`

Calculate the total amount of Dai needed to both wipe debt, buy MKR from Uniswap, and and additional buffer to account for price slippage.
`uint daiTransfer = add(wad, mul(daiFee, 2));`

Transfer Dai from the user's addresss to the proxy contract
`require(dai.transferFrom(msg.sender, address(this), daiTransfer));`

Exchange Dai for MKR on Uniswap. The `tokenToTokenSwapOutput` function exchanges a certain amount of Dai for a precise amount of MKR specified in the input. The remaining inputs set the maximum amount of Dai and ETH used for the transaction, and deadline set for the transaction to be valid. Paying stability fees can be completely skipped if the MKRUSD oracles are not valid.

```text
if(ok && val != 0) {
    daiEx.tokenToTokenSwapOutput(mkrFee, daiTransfer, uint(999000000000000000000), uint(1645118771), address(mkr));
}
```

Wipe Dai debt from the CDP. This function call automatically pays the stability fee with the MKR available on the address.
`tub.wipe(cup, wad);`

Transfer remaining Dai on the proxy contract back to the user's address.

```text
daiTransfer = dai.balanceOf(address(this));
require(dai.transferFrom(address(this), msg.sender, daiTransfer));
```

### Deployment and Execution

Before we begin the tutorial, make sure you have enough Kovan ETH and Dai on the address you are going to use by following instructions on this [guide](https://example.com)

Build the `wipe-proxy` project by running `dapp build` on the root folder

Deploy the WipeProxy contract using the command `dapp create WipeProxy`. Make a note of the contract address returned after successful execution and store it as a variable
`export WIPEPROXY=0xbaadbd7a81cb735a77b547a112e9c370a62b200b`

Deploy a DSProxy contract for your address using the factory contract present on Kovan
`seth send 0x64a436ae831c1672ae81f674cab8b6775df3475c 'build()'`

This transaction might fail if you have an existing DSProxy. You can check if you have one now with this command
`seth call 0x64a436ae831c1672ae81f674cab8b6775df3475c 'proxies(address)(address)' 0xYourAddressHere`

Store the address of the DSProxy contract deployed in a variable
`export PROXY=0xYourDSProxyContractAddress`

We can prepare calldata to wipe 1 DAI in debt from CDP #44 on Kovan using this command with the following inputs,

* Address of the Tub contract on Kovan
* Address of the Uniswap DAI Exchange
* CDP #44 in bytes32 format
* 1 Dai to wipe

```bash
seth calldata 'wipeWithDai(address,address,uint,uint)' 0xa71937147b55deb8a530c7229c442fd3f31b7db2 0x47D4Af3BBaEC0dE4dba5F44ae8Ed2761977D32d6 $(seth --to-hexdata $(seth --to-uint256 44)) $(seth --to-uint256 $(seth --to-wei 1 eth))
```

Make a note of the returned hex data to use as input while interacting with the DSProxy contract `0x1fcc37ad000000000000000000000000a71937147b55deb8a530c7229c442fd3f31b7db200000000000000000000000047d4af3bbaec0de4dba5f44ae8ed2761977d32d6000000000000000000000000000000000000000000000000000000000000002c0000000000000000000000000000000000000000000000000de0b6b3a7640000`

Finish the transaction by calling execute on the DSProxy contract

```text

```

### Best Practices

Need to use require for ERC20 token transfer
`require(transferFrom)`

`require(msg.sender.call.value(wethAmt)())`

Approvals
Get the required amount and set back to 0
Approve max. Reasons?
Gas efficiency

Deploying a proxy and executing in one step
Only available if the transaction is called on a payable function?

### Production Usage

Using Proxy Factory & Registry

proxy registry - https://github.com/makerdao/proxy-registry

Using the existing registry to deploy proxy contracts to save gas costs as most users who have interacted with the CDP portal, or Oasis have a ds-proxy deployed and registered

Create a contract with multiple functions

Deploy a contract
Skip the cache

Call build to create a new proxy for your address using an existing proxy factory

Call the proxies mapping to find the deployed proxy address

## Troubleshooting

### Recovering ETH

Instances in which ETH can get stuck?
Using https://github.com/makerdao/proxy-recover-funds

## Summary


## Additional resources

1. .

## Next Steps

## Help

* Contact Integrations team - integrate@makerdao.com

* Rocket chat - #dev channel

