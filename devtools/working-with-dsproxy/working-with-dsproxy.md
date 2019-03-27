# Working with DSProxy

**Level**: Advanced

**Estimated Time**: 90 - 120 minutes

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

* Understanding of the functions used to interact with CDPs
* Solidity development experience

## Guide

* [Examples](#examples)
* [Features](#dsproxy)
* [Tutorial](#create-a-script)
* [Best Practices](#best-practices)
* [Production Usage](#production-usage)

### Examples

#### Opening a CDP

Opening a CDP to draw Dai is a common action performed by users within the Dai Credit System(DCS) and they perform multiple transactions on the [WETH](https://etherscan.io/token/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2) and [Tub](https://etherscan.io/address/0x448a5065aebb8e423f0896e6c5d525c040f59af3) contracts to complete it.

Transactions to execute on the WETH token contract are,

* Convert ETH to WETH using the `mint` function.
* Approve the Tub contract to spend the user's WETH balance using the `approve` function.

Transactions to execute on the Tub contract are,

* Convert WETH to PETH using the `join` function.
* Open a new CDP using the `open` function.
* Add PETH collateral to the new CDP using the `lock` function.
* Draw DAI from the CDP using the `draw` function.

[CDP portal](https://cdp.makerdao.com) uses a [script](https://github.com/makerdao/sai-proxy/blob/094de960782c5a8df2dae9fc2783b6366dc1c417/src/SaiProxy.sol#L149) to improve the user experience by executing the above steps atomically within a single transaction. For comparison, you can check early interfaces like [dai.makerdao.com](https://dai.makerdao.com) which made users execute these steps separately.

#### Bust Arbitrage with DEXes

A CDP liquidation creates bad debt which needs to be erased from the system by selling a portion of the collateral locked in a CDP to raise the same amount of Dai from Keepers. Keepers monitor the Tub contract and execute the following transactions when they find an unsafe CDP to complete a successful arbitrage and realize a profit in Dai.

* `bite` an unsafe CDP on Tub. This clears the outstanding Dai debt of the CDP and transfers a portion of its locked collateral to the liquidator contract.
* Approve Tap contract address to spend the keeper's DAI balance using the `approve` function.
* Transfer Dai using `bust` on [Tap](https://etherscan.io/address/0xbda109309f9fafa6dd6a9cb9f1df4085b27ee8ef) liquidator contract to purchase PETH at a discount.
* `exit` on Tub to convert PETH back to WETH.
* Trade WETH for Dai on a DEX that offers the best price using its trade functions.
* `require` check to stop the entire sequence of actions if it results in a loss for the Keeper.

Keepers calling `bite` do not get a preference and anyone can call `bust` to buy the collateral at a discount. A successful arbitrage trade for the Keeper also means that they are able to sell WETH back on other markets to realize the discount offered by Tap as profit in Dai. To avoid these issues, Keepers having been using scripts to execute the above transactions atomically and avoid losses especially in an environment when the price of collateral is rapidly declining.

#### Pay stability fees with Dai

In Single Collateral Dai, CDP owners have to use MKR to pay stability fees when they close a CDP. Most of them are forced to buy a tiny amount of MKR from an exchange since not all of them are MKR holders. The sequence of transactions they have to execute when closing a CDP are,

* Trade DAI for the required amount of MKR on an exchange.
* Approve Tub contract address to spend the user's DAI balance using the `approve` function.
* Approve Tub contract address to spend the user's MKR balance using the `approve` function.
* `wipe` or `shut` on the Tub contract to pay back borrowed Dai.

The CDP portal uses a [script](https://github.com/makerdao/sai-proxy/blob/094de960782c5a8df2dae9fc2783b6366dc1c417/src/SaiProxy.sol#L159) to make the entire process seamless for CDP owners who do not hold MKR to buy the exact amount of MKR they need on the Eth2Dai exchange MKR/DAI market, and also pay back Dai to close the CDP in the same transaction.

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
* Owner of the DSProxy contract, `msg.sender`
* Contract address which contains the script, `address`
* Calldata which contains function signature of script being executed and its input data, `data`

#### Factory Contract

The function  `build` in the DSProxyFactory contract is used to deploy a personal DSProxy contract. For production usecases on mainnet you can use a common factory contract that is already being used by existing projects to avoid deploying redundant DSProxy contracts for users who already have one. Please check the [Production Usage](/production-usage) section in this guide for more details.

### Create a script

We've seen an example earlier of how a script can help CDP owners pay back their Dai debt by purchasing the required amount of MKR from an exchange within the same transaction. Uniswap exchange contracts are a good source of liquidity especially for buying small amounts of MKR. In this section, we will create a script that will allow users to buy MKR with DAI from Uniswap and wipe debt from a CDP.

#### Environment Setup

We'll use `dapp` and `seth` while working through this section but you can also your own tool of choice like the Remix IDE to execute these steps. Instructions to install both the tools can be found [here](https://dapp.tools/).

You have to create a `~/.sethrc` file and configure it with these values to work with the Kovan testnet,

* `export SETH_CHAIN=kovan`
* `export ETH_FROM=0xYourKovanAddressFromKeyStoreOrLedger`
* `export ETH_GAS=4000000`
* `export ETH_GAS_PRICE=2500000000`

Seth uses an Infura RPC URL by default but you can also configure `ETH_RPC_URL` and point it to your preferred end-point.

#### Create a new dapp project

Create a new folder and open it

```bash
mkdir wipe-proxy && cd wipe-proxy
```

Initialize a dapp project within it

```bash
dapp init
```

Add the DSMath library to the project to use safe math operations within the script

```text
dapp install ds-math
```

#### Setup WipeProxy.sol

Import the DSMath contract

```text
import "ds-math/math.sol";
```

Let's add the required interfaces to interact with functions on those contracts later in the script.

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

Add the `UniswapExchangeLike` interface to be able to retrieve output prices of token swaps and execute them on the Uniswap exchange contracts setup for both DAI and MKR tokens

```text
interface UniswapExchangeLike {
    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);
    function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);
    function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) external returns (uint256  tokens_sold);
}
```

Add DSMath to the WipeProxy contract

```text
contract WipeProxy is DSMath {

}
```

#### Setup `wipeWithDai` function

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

Within the function body, ensure at least some Dai debt is being wiped in the transaction using a require statement

```text
require(wad > 0);
```

#### Initialize variables

Initialize contracts using input addresses to interact with their functions later

```text
TubLike tub = TubLike(_tub);
UniswapExchangeLike daiEx = UniswapExchangeLike(_DAIExchange);
UniswapExchangeLike mkrEx = UniswapExchangeLike(_MKRExchange);

TokenLike dai = tub.sai();
TokenLike mkr = tub.gov();
PepLike pep =   tub.pep();
```

Convert the input `cupid` into a left-padded bytes32 hex value format that the Tub contract expects.

```text
bytes32 cup = bytes32(cupid);
```

#### Set all allowances

In the `WipeProxy` contract, create a new `setAllowance` private function

```text
function setAllowance(TokenLike token_, address spender_) private {
        if (token_.allowance(address(this), spender_) != uint(-1)) {
            token_.approve(spender_, uint(-1));
        }
    }
```

In the `wipeWithDai` function, we can now set the required allowances using the `setAllowance` function.

* Allow the Tub contract to debit DAI from the DSProxy contract
* Allow the Tub contract to debit MKR from the DSProxy contract
* Allow the Uniswap DAI Exchange contract to debit DAI from the DSProxy contract

```text
setAllowance(dai, _tub);
setAllowance(mkr, _tub);
setAllowance(dai, _DAIExchange);
```

#### Transfer Dai to the DSProxy contract

Read the current MKRUSD price

```text
(bytes32 val, bool ok) = pep.peek();
```

Calculate the amount of MKR needed for successfully executing wipe by dividing the stability fee amount accrued in Dai with the current value reported by the MKRUSD price oracle contract

```text
uint mkrFee = wdiv(rmul(wad, rdiv(tub.rap(cup), tub.tab(cup))), uint(val));
```

Calculate the additional Dai needed to buy MKR from Uniswap. This is done by first calculating the amount of ETH needed to buy the required MKR, and then the amount of Dai needed to buy the required ETH

```text
uint ethAmt = mkrEx.getEthToTokenOutputPrice(mkrFee);
uint daiAmt = daiEx.getTokenToEthOutputPrice(ethAmt);
```

We can now calculate the total amount of Dai and transfer it from the user's address to their DSProxy contract

```text
daiAmt = add(wad, daiAmt);
require(dai.transferFrom(msg.sender, address(this), daiAmt));
```

#### Exchange Dai for MKR on Uniswap

The `tokenToTokenSwapOutput` function exchanges Dai for the required amount of MKR specified in the input as `mkrFee`. The remaining inputs set the maximum amount of DAI and ETH used for the transaction, and deadline set for the transaction to be valid. Paying stability fees can be skipped if the MKRUSD oracles are not valid.

```text
if(ok && val != 0) {
    daiEx.tokenToTokenSwapOutput(mkrFee, daiAmt, uint(999000000000000000000), uint(1645118771), address(mkr));
}
```

#### Wipe Dai debt from the CDP

Wipe debt of the CDP with DAI and pay the stability fee with MKR available on the DSProxy contract.

```text
tub.wipe(cup, wad);
```

Before we proceed to the next section of this guide, please ensure your code matches the `WipeProxy` contract below

```text
contract WipeProxy is DSMath {
    function setAllowance(TokenLike token_, address spender_) private {
        if (token_.allowance(address(this), spender_) != uint(-1)) {
            token_.approve(spender_, uint(-1));
        }
    }

    function wipeWithDai(
        address _tub,
        address _DAIExchange,
        address _MKRExchange,
        uint cupid,
        uint wad
    ) public {
        require(wad > 0);

        TubLike tub = TubLike(_tub);
        UniswapExchangeLike daiEx = UniswapExchangeLike(_DAIExchange);
        UniswapExchangeLike mkrEx = UniswapExchangeLike(_MKRExchange);
        TokenLike dai = tub.sai();
        TokenLike mkr = tub.gov();
        PepLike pep =   tub.pep();

        bytes32 cup = bytes32(cupid);

        setAllowance(dai, _tub);
        setAllowance(mkr, _tub);
        setAllowance(dai, _DAIExchange);

        (bytes32 val, bool ok) = pep.peek();

        // MKR required for wipe = Stability fees accrued in Dai / MKRUSD value
        uint mkrFee = wdiv(rmul(wad, rdiv(tub.rap(cup), tub.tab(cup))), uint(val));

        uint ethAmt = mkrEx.getEthToTokenOutputPrice(mkrFee);
        uint daiAmt = daiEx.getTokenToEthOutputPrice(ethAmt);

        daiAmt = add(wad, daiAmt);
        require(dai.transferFrom(msg.sender, address(this), daiAmt));

        if(ok && val != 0) {
           daiEx.tokenToTokenSwapOutput(mkrFee, daiAmt, uint(999000000000000000000), uint(1645118771), address(mkr));
        }

        tub.wipe(cup, wad);
    }
}

```

### Deployment and Execution

Before we begin, ensure you have some Kovan ETH to pay gas for transactions and Kovan Dai on the address by following instructions on this [guide](https://github.com/makerdao/developerguides/blob/master/dai/dai-token/dai-token.md#testnet)

Build the `wipe-proxy` project

```bash
dapp build
```

Deploy the WipeProxy contract

```bash
dapp create WipeProxy
```

Make a note of the contract address returned after successful execution and store it as a variable

```bash
export WIPEPROXY=0xfd92bd57d369714f519c3e6095d62d5872114e34
```

Deploy your own DSProxy contract for your address using the factory contract present on Kovan

```bash
export PROXYREGISTRY=0x64a436ae831c1672ae81f674cab8b6775df3475c
seth send $PROXYREGISTRY 'build()'
```

This transaction might fail if you already have deployed a DSProxy contract before from this address. You can check if you have one now with this command

```bash
seth call $PROXYREGISTRY 'proxies(address)(address)' 0xYourAddressHere
```

Make a note of the returned DSProxy contract address and store it as a variable.

```bash
export MYPROXY=0xYourDSProxyAddress
```

Set allowance for your DSProxy contract address to spend from the Dai token balance on your own address

```bash
export DAITOKEN=0xc4375b7de8af5a38a93548eb8453a498222c4ff2
seth send $DAITOKEN 'approve(address)' $MYPROXY
```

We can prepare calldata to wipe 1 DAI in debt from CDP #44 on Kovan using this command with the following inputs,

* Address of the Tub contract on Kovan
* Address of the Uniswap DAI Exchange
* Address of the Uniswap MKR Exchange
* CDP #44 in bytes32 format
* 1 Dai to wipe

```bash
seth calldata 'wipeWithDai(address,address,address,uint,uint)' 0xa71937147b55deb8a530c7229c442fd3f31b7db2 0x47D4Af3BBaEC0dE4dba5F44ae8Ed2761977D32d6 0x88f55896d822E2355760648731778f21952693AB $(seth --to-hexdata $(seth --to-uint256 44)) $(seth --to-uint256 $(seth --to-wei 1 eth))
```

Make a note of the returned hex data to use as input while interacting with the DSProxy contract and store it

```bash
export CALLDATA=0xf4bd4298000000000000000000000000a71937147b55deb8a530c7229c442fd3f31b7db200000000000000000000000047d4af3bbaec0de4dba5f44ae8ed2761977d32d600000000000000000000000088f55896d822e2355760648731778f21952693ab000000000000000000000000000000000000000000000000000000000000002c0000000000000000000000000000000000000000000000000de0b6b3a7640000
```

Call execute on the DSProxy contract with these inputs,

* Address of the deployed `WipeProxy` contract
* Calldata to execute the `wipeWithDai` script

```bash
seth send $MYPROXY 'execute(address,bytes memory)' $WIPEPROXY $CALLDATA
```

### Best Practices

Use `require` when using `transferFrom` within the script to ensure the transaction fails when a token transfer is unsuccessful

### Production Usage

Deploying a script to production involves creating user interfaces that can handle a DSProxy contract deployment for users who need one, and then facilitating their interactions with various deployed scripts through their deployed DSProxy contracts.

A common [Proxy Registry](https://github.com/makerdao/proxy-registry) can be used by all projects to deploy DSProxy contracts for users. The address of the deployed DSProxy contract is stored in the registry and can be looked up in the future to avoid creating a new DSProxy contract for users who already have one.

Proxy Registries are already available on these networks,

* Mainnet: `0x4678f0a6958e4d2bc4f1baf7bc52e8f3564f3fe4`
* Kovan: `0x64a436ae831c1672ae81f674cab8b6775df3475c`

## Troubleshooting

### Recovering ETH

[Proxy Recover Funds](https://proxy-recover-funds.surge.sh/) interface can be used to recover and transfer ETH back to their address if it gets stuck within the DSProxy contract after a failed transaction.

## Summary

Writing scripts can help you solve a variety of problems you encounter as a developer trying to improve the user experience for your users, or even as a power user interacting with ethereum protocols. We hope this guide has covered all the relevant details to help you get started with DSProxy.

## Additional resources

1. [DSProxy](https://github.com/dapphub/ds-proxy)
2. [Sai Proxy](https://github.com/makerdao/sai-proxy)
3. [Oasis Direct Proxy](https://github.com/makerdao/oasis-direct-proxy)

## Next Steps

## Help

* Contact Integrations team - integrate@makerdao.com

* Rocket chat - #dev channel