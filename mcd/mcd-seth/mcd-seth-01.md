# Drawing Dai from the Kovan MCD deployment using Seth
**This guide works under the [0.2.12 Release](https://changelog.makerdao.com/releases/0.2.12/index.html) of the system.** 

This tutorial will cover how to use the tool `seth` to deposit REP tokens to draw DAI from the Kovan deployment of MCD as an example, since the process is the same for any other ERC-20 token. You can use the same methodology for any supported token in MCD, by changing the contract addresses to the specific token you want to use.

## Prerequisites

### Setting up Seth

For this guide, we are going to use the tool `seth`, to send transactions and interact with the Ethereum smart contracts.

[Use this guide to install and set up Seth](https://github.com/makerdao/developerguides/blob/master/devtools/seth/seth-guide-01/seth-guide-01.md).

**Note: Complete the above guide to setup your Seth environment variables and getting familiar with the tool before continuing. For this guide, we are using the Kovan Testnet. Ensure that Seth is configured to connect to Kovan by setting the network parameter accordingly in a terminal or config file:**

`export SETH_CHAIN=kovan`

## Getting tokens
Even though we are not using it as collateral, you will need Kovan ETH for gas. You can get some by following the guide here: [https://github.com/Kovan-testnet/faucet](https://github.com/kovan-testnet/faucet)

Next, we are going to need some test collateral tokens (REP) on the Kovan network to draw DAI from them. Luckily, there is a faucet set up just for this. It gives the caller 50 REP Kovan tokens. You can also use the same faucet for the other supported MCD tokens for the test deployment (BAT, GNT, ZRX, DGD, WETH). Find the latest contracts here, and substitute for the REP equivalent below: [https://changelog.makerdao.com/releases/0.2.12/index.html](https://changelog.makerdao.com/releases/0.2.12/index.html).

You can only call the faucet once per account address, so if you mess something up in the future or you need more for any reason, you are going to need to create a new account. This is how you can call the faucet with seth:

**REP ERC-20 token contract**

`export REP=0xc7aa227823789e363f29679f23f7e8f6d9904a9b`

**Token faucet on Kovan**

`export FAUCET=0x94598157fcf0715c3bc9b4a35450cce82ac57b20`

Execute the following to receive test 50 REP tokens:

`seth send $FAUCET 'gulp(address)' $REP`

Let's check if we have received the tokens from the faucet. The following conversions are needed, because seth returns data in hexadecimal value, and the contract stores it in wei unit.

Execute:

`seth --from-wei $(seth --to-dec $(seth call $REP 'balanceOf(address)' $ETH_FROM)) eth`

If everything went according to plan, the output should be this:

`50.000000000000000000`

## Saving contract addresses
For better readability, we are going to save a bunch of contract addresses in variables belonging to the related smart contracts deployed to Kovan. In a terminal, carry out the following commands (in grey):

**Set the gas quantity**     
`export ETH_GAS=2000000`

**REP ERC-20 token contract**

`export REP=0xc7aa227823789e363f29679f23f7e8f6d9904a9b`

**DAI ERC-20 token contract**

`export DAI_TOKEN=0xb64964e9c0b658aa7b448cdbddfcdccab26cc584`

**REP-A token join adapter**

`export MCD_JOIN_REP_A=0x2c205dd1a49b17d24062e72b2fd4585c643359fb`

**Vat contract - Central state storage for MCD**

`export MCD_VAT=0xdf69460542dbdcf2f1e77941f53cfd4113a06183`

**DAI token join adapter**

`export MCD_JOIN_DAI=0x922253e8bb9905ae4d37bc9bd512db5c91b5ee6c`

**CDP Manager Contract**   

`export CDP_MANAGER=0x093a6036114813f951c82929c171c2e415539ffa`

## Token approval
You do not transfer ERC-20 tokens manually to the MCD adapters - instead you give approval for the adapters to using some of your ERC-20 tokens. The following section will take you through how to do that.

In this example, we are going to use 10 REP tokens to draw 35 DAI. You can of course use different amounts (i.e. divide all amounts by 10), just remember to change it accordingly in the function calls of this guide, while ensuring that you are within the accepted collateralization ratio of REP CDPs. Let’s approve the use of 10 REP tokens for the adapter, and then call the approve function of the REP token contract with the right parameters. Again, we have to do some conversions, namely from `eth` unit to `wei`, then from decimal to hexadecimal (the `eth` keyword can be a bit confusing, but we are still dealing with REP tokens. REP has similar fraction values to ETH, so the keyword just means conversion to the whole token denomination):

`seth send $REP 'approve(address,uint256)' $MCD_JOIN_REP_A $(seth --to-uint256 $(seth --to-wei 10 eth))`

If you want to be sure that your approve transaction succeeded, you can check the results with this command:

```seth --from-wei $(seth --to-dec $(seth call $REP 'allowance(address, address)' $ETH_FROM $MCD_JOIN_REP_A)) eth```

Output:

`10.000000000000000000`

## Finally interacting with the MCD contracts
In order to better understand the MCD contracts, the following provides a brief explanation of relevant terms.
-   `wad`: token unit amount 
-   `gem`: collateral token adapter
-   `ilk`: CDP type
-   `urn`: CDP record - keeps track of a CDP
-   `ink`: rate * wad represented in collateral  
-   `dink`: delta ink - a signed difference value to the current value
-   `art`: rate * wad represented in DAI   
-   `dart`: delta art - a signed difference value to the current value 
-   `lad`: CDP owner
-   `rat`: collateralization ratio

After giving permission to the REP adapter of MCD to take some of our tokens, it’s time to finally start using the MCD contracts.    
We'll be using the [CDP Manager](https://github.com/makerdao/dss-cdp-manager) as the prefered interface to interact with MCD contracts.     

First let's open a cdp so we can use it to lock collateral into. For this we need to define the type of collateral(REP-A) we want to lock in this CDP.   
`export ilk=$(seth --to-bytes32 $(seth --from-ascii "REP-A"))`     
Now let's open the CDP   
`seth send $CDP_MANAGER 'open(bytes32)' $ilk`    

We need the `cdpId` of our open cdp so we can interact with the system.  
`export cdpId=$(seth --to-dec $(seth call $CDP_MANAGER 'last(address)' $ETH_FROM))`    
In this case `cdpId` is `8`

Now, we need to get the `urn` address of our CDP.   
`export urn=$(seth call $CDP_MANAGER 'urns(uint)(address)' $cdpId)`    

After acquiring `cdpId` and `urn` address, we can move to the next step. Locking our tokens into the system. 
First we are going to make a transaction to the REP adapter to actually take 10 of our tokens with the join contract function.

The contract function looks like the following: `join(bytes32 urn, uint wad)`

The first parameter is the `urn`.

The second parameter is the token amount in `wad`.

First, let’s set up the `wad` parameter in variable for the sake of readability:

`export wad=$(seth --to-uint256 $(seth --to-wei 10 eth))`

Then use the following command to use the join function, thus taking 10 REP from our account and sending to `urn` address.

`seth send $MCD_JOIN_REP_A "join(address, uint)" $urn $wad`

You can check the results with the contract function: `gem(bytes32 ilk,address urn)(uint256)` with    
`seth --from-wei $(seth --to-dec $(seth call $MCD_VAT 'gem(bytes32,address)(uint256)' $ilk $urn)) eth`

The output should look like this:

`10.000000000000000000`

The reason for the size of the number, even when converting it from wei values, is that these numbers are stored with a pretty big resolution for precision.

The next step is adding the collateral into an urn. This is done through the `CDP Manager` contract. 
The function is called `frob`, which receives couple of parameters: `uint` - the `cdpId`, `address` - the destination address to send dai(`ETH_FROM` and not `urn`), `int` - delta ink and `int` - delta art. If the `frob` operation is successful, it will adjust the corresponding data in the protected `vat` module. When adding collateral to an `urn`, `dink` needs to be the (positive) amount we want to add and `dart` needs to be the (positive) amount of DAI we want to draw. Let’s add our 10 REP to the urn, and draw 35 DAI ensuring that the position is overcollateralized.


We already set up `ilk` before, so we only need to set up `dink` (REP deposit) and `dart` (DAI to be drawn):

`export dink=$(seth --to-uint256 $(seth --to-hex $(seth --to-wei 10 eth)))`

`export dart=$(seth --to-uint256 $(seth --to-hex $(seth --to-wei 35 eth)))`

And execute:

`seth send $CDP_MANAGER 'frob(uint,address,int,int)' $cdpId $ETH_FROM $dink $dart`

Now, let's check out our DAI balance in MCD to see if we have succeeded. We are going to use the following `vat` function: `dai(bytes32 urn)(uint256)`

Let’s execute it:

`seth --from-wei $(seth --to-dec $(seth call $MCD_VAT 'dai(address)(uint256)' $ETH_FROM))`

The output should look like this:

`35000000000000000000000000000.000000000000000000`

It shows the DAI amount in wei, so the actual amount is 35. Now this DAI is minted, but the balance is still technically owned by the DAI adapter of MCD. If you actually want to use it, you have to transfer it to your account. Here is the function for it: `exit(address guy, uint256 wad)`

Let’s execute:   

Permitting Dai adapter to move Dai from VAT to your address.   
`seth send $MCD_VAT 'hope(address)' $MCD_JOIN_DAI`    

Exiting Dai:   
`seth send $MCD_JOIN_DAI "exit(address, uint256)" $ETH_FROM $dart`

And to check the DAI balance of your account:

`seth --from-wei $(seth --to-dec $(seth call $DAI_TOKEN 'balanceOf(address)' $ETH_FROM)) eth`

Expected output:

`35.000000000000000000`

If everything checks out, congratulations: you have just acquired some multi-collateral DAI on Kovan!

## Paying back DAI debt to release collateral
To pay back your DAI and release the locked collateral, follow the following steps.

First, let’s approve the transfer of 35 DAI tokens to the adapter. Call the approve function of the DAI ERC-20 token contract with the right parameters (again, we have to do some conversions, namely from `eth` unit to `wei`, then from decimal to hexadecimal):

`seth send $DAI_TOKEN 'approve(address,uint256)' $MCD_JOIN_DAI $(seth --to-uint256 $(seth --to-wei 35 eth))`

If you want to be sure that your approve transaction succeeded, you can check the results with this command:

`seth --from-wei $(seth --to-dec $(seth call $DAI_TOKEN 'allowance(address, address)' $ETH_FROM $MCD_JOIN_DAI)) eth`

Output:

`35.000000000000000000`

Now to actually join the Dai to the adapter:

`seth send $MCD_JOIN_DAI "join(address,uint)" $urn $dart`

To make sure it all worked:

`seth --from-wei $(seth --to-dec $(seth call $MCD_VAT 'dai(address)(uint256)' $urn)) eth`

Output:

`35000000000000000000000000000.000000000000000000`

Now, onto actually getting our collateral back. `dart` and `dink`, as the d in their abbreviation stands for delta, are inputs for changing a value, and thus they can be negative. When we want to lower the amount of DAI drawn from the `urn`, we lower the art parameter of the `urn`. Again, we need to use the `frob` operation to change these parameters: `frob(uint cdpId, address ETH_FROM, int dink, int dart)`

We only need to set up the `dink` and `dart` variables.

Now, here is a little problem: `seth`’s `--to-hex` option is unable to deal with negative numbers, we have two ways to deal with this, just blindly believe me and accept that these values are the following in 32 bit long hexadecimals:  

**-10:**

`export minus10hex=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7538DCFB76180000`

**-35:**

`export minus35hex=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE1A4705701D540000`

Or you can alternatively install and use [mcd-cli](https://github.com/makerdao/mcd-cli#install), another tool for this, and execute:

`minus10hex=$(mcd --to-hex $(seth --to-wei -10 eth))`

`minus35hex=$(mcd --to-hex $(seth --to-wei -35 eth))`

Then set up the actual `dink` and `dart` parameters:

`export dink=$(seth --to-uint256 $minus10hex)`

`export dart=$(seth --to-uint256 $minus35hex)`

And execute:

`seth send $CDP_MANAGER 'frob(uint,address,int,int)' $cdpId $ETH_FROM $dink $dart`

This doesn’t mean you have already got back your tokens yet. If you check, your account’s REP balance is not yet back to the original amount.

To check the balance, execute:

`seth --from-wei $(seth --to-dec $(seth call $REP 'balanceOf(address)' $ETH_FROM)) eth`

Output:

`40.000000000000000000`

You first have to transfer the tokens back with the exit operation:

`export wad=$(seth --to-word $(seth --to-wei 10 eth))`

`seth send $MCD_JOIN_REP_A 'exit(address,uint)' $ETH_FROM $wad`

If you check the balance again:

`seth --from-wei $(seth --to-dec $(seth call $REP 'balanceOf(address)' $ETH_FROM)) eth`

Output:

`50.000000000000000000`

Yay, you got back your tokens! If you have come this far, congratulations, you have finished paying back the debt of your CDP in Multi-Collateral Dai and getting back the collateral. Spend those freshly regained test REP tokens wisely!
