# Drawing Dai from the Kovan Maker Protocol deployment using Seth

**This guide works under the Kovan [1.0.2 Release](https://changelog.makerdao.com/releases/kovan/1.0.2/index.html) of the system.**

- [Drawing Dai from the Kovan Maker Protocol deployment using Seth](#drawing-dai-from-the-kovan-maker-protocol-deployment-using-seth)
  - [Prerequisites](#prerequisites)
    - [Setting up Seth](#setting-up-seth)
    - [Other tools](#other-tools)
  - [Getting tokens](#getting-tokens)
  - [Saving contract addresses](#saving-contract-addresses)
  - [Token approval](#token-approval)
  - [Finally interacting with the Maker Protocol contracts](#finally-interacting-with-the-maker-protocol-contracts)
  - [Paying back DAI debt to release collateral](#paying-back-dai-debt-to-release-collateral)

**You can also use the Rinkey, Ropsten and Goerli deployments in this guide. Just make sure to change the contract addresses from the specific network.**

This tutorial will cover how to use the tool `seth` to deposit BAT tokens to draw DAI from the Kovan deployment of MCD as an example, since the process is the same for any other ERC-20 token. You can use the same methodology for any supported token in MCD, by changing the contract addresses to the specific token you want to use.

## Prerequisites

### Setting up Seth

For this guide, we are going to use the tool `seth`, to send transactions and interact with the Ethereum smart contracts.

[Use this guide to install and set up Seth](https://github.com/makerdao/developerguides/blob/master/devtools/seth/seth-guide-01/seth-guide-01.md).

**Note: Complete the above guide to setup your Seth environment variables and getting familiar with the tool before continuing. For this guide, we are using the Kovan Testnet. Ensure that Seth is configured to connect to Kovan by setting the network parameter accordingly in a terminal or config file:**

**If using other networks, make sure to change the `SETH_CHAIN` and `ETH_RPC_URL` variables to your preferred network**

`export SETH_CHAIN=kovan`

### Other tools

- [mcd-cli](https://github.com/makerdao/mcd-cli#installation)
- `bc` ([Arbitrary Precision Calculator](https://www.gnu.org/software/bc/))

## Getting tokens

Even though we are not using it as collateral, we will need Kovan ETH for gas. We can get some by following the guide here: [https://github.com/Kovan-testnet/faucet](https://github.com/kovan-testnet/faucet)

Next, we are going to need some test collateral tokens (BAT) on the Kovan network to draw DAI from them. Luckily, there is a faucet set up just for this. It gives the caller 50 BAT Kovan tokens.

We can only call the faucet once per account address, so if you mess something up in the future or you need more for any reason, you are going to need to create a new account. This is how we can call the faucet with seth:

**BAT ERC-20 token contract:**

`export BAT=0x9f8cFB61D3B2aF62864408DD703F9C3BEB55dff7`

**Token faucet on Kovan:**

`export FAUCET=0x57aAeAE905376a4B1899bA81364b4cE2519CBfB3`

Execute the following to receive test 50 BAT tokens:

`seth send $FAUCET 'gulp(address)' $BAT`

Let's check if we have received the tokens from the faucet. The following conversions are needed, because seth returns data in hexadecimal value, and the contract stores it in wei unit.

Execute:

`seth --from-wei $(seth --to-dec $(seth call $BAT 'balanceOf(address)' $ETH_FROM)) eth`

If everything went according to plan, the output should be this:

`50.000000000000000000`

Note: We will need more than 50 BAT to be able to open a Vault large enough to generate the 20 minimum DAI required. The faucet won't provide more than 50 BAT per address but you may create additional addresses to accumulate the 130-150 BAT necessary.

## Saving contract addresses

For better readability, we are going to save a bunch of contract addresses in variables belonging to the related smart contracts deployed to Kovan. In a terminal, carry out the following commands (in grey):

**Set the gas quantity**  
`export ETH_GAS=2000000`

**BAT ERC-20 token contract:**

`export BAT=0x9f8cFB61D3B2aF62864408DD703F9C3BEB55dff7`

**DAI ERC-20 token contract:**

`export DAI_TOKEN=0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa`

**BAT-A token join adapter:**

`export MCD_JOIN_BAT_A=0x2a4C485B1B8dFb46acCfbeCaF75b6188A59dBd0a`

**Vat contract - Central state storage for MCD:**

`export MCD_VAT=0xbA987bDB501d131f766fEe8180Da5d81b34b69d9`

**DAI token join adapter:**

`export MCD_JOIN_DAI=0x5AA71a3ae1C0bd6ac27A1f28e1415fFFB6F15B8c`

**CDP Manager Contract:**

`export CDP_MANAGER=0x1476483dD8C35F25e568113C5f70249D3976ba21`

**MCD JUG Contract:**

`export MCD_JUG=0xcbB7718c9F39d05aEEDE1c472ca8Bf804b2f1EaD`

## Token approval

We do not transfer ERC-20 tokens manually to the MCD adapters - instead we give approval for the adapters to using some of our ERC-20 tokens. The following section will take us through the necessary steps.

In this example, we are going to use 150 BAT tokens to draw 20 DAI. You may of course use different amounts, just remember to change it accordingly in the function calls of this guide, while ensuring that you are within the accepted collateralization ratio of BAT Vault (150%) and the minimum vault debt (20 DAI). Let’s approve the use of 150 BAT tokens for the adapter, and then call the approve function of the BAT token contract with the right parameters. Again, we have to do some conversions, namely from `eth` unit to `wei`, then from decimal to hexadecimal (the `eth` keyword can be a bit confusing, but we are still dealing with BAT tokens. BAT has similar fraction values to ETH, so the keyword just means conversion to the whole token denomination):

`seth send $BAT 'approve(address,uint256)' $MCD_JOIN_BAT_A $(seth --to-uint256 $(seth --to-wei 150 eth))`

If we want to be sure that our approve transaction succeeded, we can check the results with this command:

`seth --from-wei $(seth --to-dec $(seth call $BAT 'allowance(address, address)' $ETH_FROM $MCD_JOIN_BAT_A)) eth`

Output:

`150.000000000000000000`

## Finally interacting with the Maker Protocol contracts

In order to better understand the MCD contracts, the following provides a brief explanation of relevant terms.

- `wad`: token unit amount
- `gem`: collateral token adapter
- `ilk`: Vault type
- `urn`: Vault record - keeps track of a Vault
- `ink`: rate \* wad represented in collateral
- `dink`: delta ink - a signed difference value to the current value
- `art`: rate \* wad represented in DAI
- `dart`: delta art - a signed difference value to the current value
- `lad`: Vault owner
- `rat`: collateralization ratio

After giving permission to the BAT adapter of MCD to take some of our tokens, it’s time to finally start using the MCD contracts.  
We'll be using the [CDP Manager](https://github.com/makerdao/dss-cdp-manager) as the preferred interface to interact with MCD contracts.

We begin by opening an empty Vault so we can use it to lock collateral into. For this we need to define the type of collateral (BAT-A) we want to lock in this Vault.  
`export ilk=$(seth --to-bytes32 $(seth --from-ascii "BAT-A"))`  
Now let's open the Vault  
`seth send $CDP_MANAGER 'open(bytes32,address)' $ilk $ETH_FROM`

We need the `cdpId` and `urn` address of our open Vault so we can interact with the system.

```bash
export cdpId=$(seth --to-dec $(seth call $CDP_MANAGER 'last(address)' $ETH_FROM))
export urn=$(seth call $CDP_MANAGER 'urns(uint)(address)' $cdpId)
```

After acquiring `cdpId` and `urn` address, we can move to the next step. Locking our tokens into the system.
First we are going to make a transaction to the BAT adapter to actually take 10 of our tokens with the join contract function.

The contract function looks like the following: `join(address urn, uint wad)`

- The first parameter is the `urn`, our vault address.
- The second parameter is the token amount in `wad`.

For the sake of readability, we up the `wadC` parameter representing the amount of collateral:

`export wadC=$(seth --to-uint256 $(seth --to-wei 150 eth))`

Then use the following command to use the join function, thus taking 150 BAT from our account and sending to `urn` address.

`seth send $MCD_JOIN_BAT_A "join(address, uint)" $urn $wadC`

We can check the results with the contract function: `gem(bytes32 ilk,address urn)(uint256)` with.

`seth --from-wei $(seth call $MCD_VAT 'gem(bytes32,address)(uint256)' $ilk $urn) eth`

The output should look like this:

`150.000000000000000000`

An optional, but recommended step is to invoke `jug.drip(ilk)` to make we are not paying undue stability fees. For more detail, please read the guide [Intro to the Rate mechanism](https://github.com/makerdao/developerguides/blob/master/mcd/intro-rate-mechanism/intro-rate-mechanism.md)

`seth send $MCD_JUG 'drip(bytes32)' $ilk`

The next step is adding the collateral into an urn. This is done through the `CDP Manager` contract.
The function is called `frob(uint256,uint256,uint256)`, which receives couple of parameters:

- `uint256 cdp` - the `cdpId`
- `int256 dink` - delta ink (collateral)
- `int256 dart` - delta art (Dai).

If the `frob` operation is successful, it will adjust the corresponding data in the protected `vat` module. When adding collateral to an `urn`, `dink` needs to be the (positive) amount we want to add and `dart` needs to be the (positive) amount of DAI we want to draw. Let’s add our 150 BAT to the urn, and draw 20 DAI ensuring that the position is overcollateralized.

We already set up `cdp` before, so we only need to set up `dink` (BAT deposit) and `dart` (DAI to be drawn):

```bash
dink=$(seth --to-uint256 $(seth --to-wei 150 eth))
rate=$(seth --to-fix 27 $(seth --to-dec $(seth call $MCD_VAT 'ilks(bytes32)(uint256,uint256,uint256,uint256,uint256)' $ilk | sed -n 2p)))
dart=$(seth --to-uint256 $(bc<<<"scale=18; art=(20/$rate*10^18+1); scale=0; art/1"))
```

- The `vat` is using an internal dai representation called "normalised art" that is useful to calculate accrued stability fees. To convert the Dai amount to normalized art, we have to divide it by the current ilk `rate`.

With the variables set, we can call `frob`:  
`seth send $CDP_MANAGER 'frob(uint256,int256,int256)' $cdpId $dink $dart`

Now, let's check out our internal DAI balance to see if we have succeeded. We are going to use the following `vat` function: `dai(address urn)(uint256)`:

`seth --to-fix 45 $(seth --to-dec $(seth call $MCD_VAT 'dai(address)(uint256)' $urn))`

The output should look like this (The result isn't exactly 20 Dai because of number precision):

`20.000000000000000000989957880534621130774523011`

Now this DAI is minted, but the balance is still technically owned by the DAI adapter of MCD. If we actually want to use it, we have to transfer it to our account:

```bash
export rad=$(seth --to-dec $(seth call $MCD_VAT 'dai(address)(uint256)' $urn))
seth send $CDP_MANAGER 'move(uint256,address,uint256)' $cdpId $ETH_FROM $(seth --to-uint256 $rad)
```

- Here, `rad`, is the total amount of DAI available in the `urn`. We are reading this number to get all the DAI possible.

We then permitting the Dai adapter to move Dai from VAT to our address:  
`seth send $MCD_VAT 'hope(address)' $MCD_JOIN_DAI`

An finally we exit the internal dai to the ERC-20 DAI:  
`seth send $MCD_JOIN_DAI "exit(address,uint256)" $ETH_FROM $(seth --to-uint256 $(seth --to-wei 20 eth))`

And to check the DAI balance of our account:

`seth --from-wei $(seth --to-dec $(seth call $DAI_TOKEN 'balanceOf(address)' $ETH_FROM)) eth`

Expected output:

`20.000000000000000000`

If everything checks out, congratulations: you have just acquired some multi-collateral DAI on Kovan!

## Paying back DAI debt to release collateral

To pay back your DAI and release the locked collateral, follow the following steps. Please make sure to obtain some additional Dai (from another account or from another vault) because chances are interest will have accumulated in the meantime. To force stability fee accumulation, anyone can invoke `jug.drip(ilk)`:

`seth send $MCD_JUG 'drip(bytes32)' $ilk`

First thing is to determine what is our debt, including the accrued stability fee:

```bash
art=$(seth --from-wei $(seth --to-dec $(seth call $MCD_VAT 'urns(bytes32,address)(uint256,uint256)' $ilk $urn | sed -n 2p)))
rate=$(seth --to-fix 27 $(seth --to-dec $(seth call $MCD_VAT 'ilks(bytes32)(uint256,uint256,uint256,uint256,uint256)' $ilk | sed -n 2p)))
debt=$(bc<<<"$art*$rate")
debtWadRound=$(seth --to-uint256 $(bc<<<"$art*$rate*10^18/1+1"))
```

- `art`: internal vault debt representation
- `rate`: accumulated stability fee from the system
- `debt`: vault debt in Dai
- `debtWadRound`: vault debt in wad (i.e. multiplied by 10^18), added by 1 wad to avoid rounding issues.

Then we need to approve the transfer of DAI tokens to the adapter. Call the approve function of the DAI ERC-20 token contract with the right parameters:

`seth send $DAI_TOKEN 'approve(address,uint256)' $MCD_JOIN_DAI $debtWadRound`

If we want to be sure that our approve transaction succeeded, we can check the results with this command:

`seth --from-wei $(seth --to-dec $(seth call $DAI_TOKEN 'allowance(address, address)' $ETH_FROM $MCD_JOIN_DAI)) eth`

Output:

`20.000000000000000001`

Now to actually join the Dai to the adapter:

`seth send $MCD_JOIN_DAI "join(address,uint)" $urn $debtWadRound`

To make sure it all worked:

`seth --to-fix 45 $(seth --to-dec $(seth call $MCD_VAT 'dai(address)(uint256)' $urn))`

Output:

`20.000000000000000001000000000000000000000000000`

Now, onto actually getting our collateral back. `dart` and `dink`, as the d in their abbreviation stands for delta, are inputs for changing a value, and thus they can be negative. When we want to lower the amount of DAI drawn from the `urn`, we lower the art parameter of the `urn`. Again, we need to use the `frob` operation to change these parameters: `frob(uint cdpId, address ETH_FROM, int dink, int dart)`

We only need to set up the `dink` and `dart` variables.

Using [mcd-cli](https://github.com/makerdao/mcd-cli#installation), we create our two negative `$dink` and `$dart`.

```bash
dink=$(seth --to-uint256 $(mcd --to-hex $(seth --to-wei -150 eth)))
dart=$(seth --to-uint256 $(mcd --to-hex -$(seth --to-wei $art eth)))
```

And execute:

`seth send $CDP_MANAGER "frob(uint256,int256,int256)" $cdpId $dink $dart`

This doesn’t mean we have already got back your tokens yet. Our account’s BAT balance is not yet back to the original amount:

`seth --from-wei $(seth --to-dec $(seth call $BAT 'balanceOf(address)' $ETH_FROM)) eth`

Output:

`0.000000000000000000`

The BAT is still assigned to the Vault, so we need to move them to our address:
`seth send $CDP_MANAGER 'flux(uint256,address,uint256)' $cdpId $ETH_FROM $wadC`

And from there exit the BAT adapter to get back our tokens:

`seth send $MCD_JOIN_BAT_A "exit(address, uint)" $ETH_FROM $wadC`

If we check the balance again:

`seth --from-wei $(seth --to-dec $(seth call $BAT 'balanceOf(address)' $ETH_FROM)) eth`

Output:

`150.000000000000000000`

Yay, you got back your tokens! If you have come this far, congratulations, you have finished paying back the debt of your Vault in Multi-Collateral Dai and getting back the collateral. Spend those freshly regained test BAT tokens wisely!
