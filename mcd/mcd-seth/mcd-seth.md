# Drawing Dai from the Goerli Maker Protocol deployment using Seth

**⚠️ ATTENTION:** This guide works under the Goerli [1.11.0 Release](https://chainlog.makerdao.com/api/goerli/1.11.0.json) of the system.

**ℹ️ NOTICE:** You can also use the Kovan, Rinkeby and Ropsten deployments in this guide. Just make sure to change the contract addresses from the specific network.

This tutorial will cover how to use the tool `seth` to deposit WBTC tokens to draw DAI from the Goerli deployment of MCD as an example, since the process is the same for any other ERC-20 token. You can use the same methodology for any supported token in MCD, by changing the contract addresses to the specific token you want to use.

* [Prerequisites](#prerequisites)
    * [Setting up Seth](#setting-up-seth)
    * [Other tools](#other-tools)
* [Getting tokens](#getting-tokens)
* [Saving contract addresses](#saving-contract-addresses)
* [Token approval](#token-approval)
* [Finally interacting with the Maker Protocol contracts](#finally-interacting-with-the-maker-protocol-contracts)
* [Paying back DAI debt to release collateral](#paying-back-dai-debt-to-release-collateral)

## Prerequisites

### Setting up Seth

For this guide, we are going to use the tool `seth`, to send transactions and interact with the Ethereum smart contracts.

[Use this guide to install and set up Seth](https://github.com/makerdao/developerguides/blob/master/devtools/seth/seth-guide/seth-guide.md).

**⚠️ ATTENTION:** Complete the above guide to set up your Seth environment variables and getting familiar with the tool before continuing. For this guide, we are using the Goerli Testnet. Ensure that `seth` is configured to connect to Goerli by setting the network parameter accordingly in a terminal or config file:

```bash
export SETH_CHAIN=goerli
```

If using other networks, make sure to change the `SETH_CHAIN` and `ETH_RPC_URL` variables to your preferred network:

```bash
# Remove the `#` from the line below to execute it
# export SETH_CHAIN=rinkeby
```

### Other tools

- [`bc` (Arbitrary Precision Calculator)](https://www.gnu.org/software/bc/).

## Getting tokens

Even though we are not using it as collateral, we will need Goerli ETH for gas. We can get some from this [faucet](https://goerlifaucet.com/).

Next, we need to get some test collateral tokens (WBTC) on the Goerli network to draw DAI from them. Luckily, there is a faucet set up just for this. It gives the caller 5 WBTC Goerli tokens.

We can only call the faucet once per account address, so if you mess something up in the future, or you require more for any reason, you are going to need to create a new account. This is how we can call the faucet with `seth`:

**WBTC ERC-20 token contract:**

```bash
export WBTC=0x7ccF0411c7932B99FC3704d68575250F032e3bB7
```

**ℹ️ NOTICE:** `WBTC` has only 8 decimals instead of the standard 18 decimals, so keep this in mind when performing conversions, as `seth --to-wei/--from-wei` will not work. Use `seth --to-fix/--from-fix` instead.
For tokens with 18 decimals, you can simply change the value of the variable below to `18` or use `seth --to-wei/--from-wei`.

```bash
export WBTC_DECIMALS=8
```

**Token faucet on Goerli:**

```bash
export FAUCET=0xa473CdDD6E4FAc72481dc36f39A409D86980D187
```

Execute the following to receive test 5 WBTC tokens:

```bash
seth send $FAUCET 'gulp(address)' $WBTC
```

Let's check if we have received the tokens from the faucet. The following conversions are needed, because `seth` returns data in hexadecimal value, and the contract stores it in `wei` unit.

Execute:

```bash
seth call $WBTC 'balanceOf(address)(uint256)' $ETH_FROM | seth --to-fix $WBTC_DECIMALS
```

If everything went according to plan, the output should be this:

`5.00000000`

## Saving contract addresses

For better readability, we are going to save a bunch of contract addresses in variables belonging to the related smart contracts deployed to Goerli. In a terminal, carry out the following commands (in grey):

**Set the gas quantity:**

```bash
export ETH_GAS=2000000
```

**WBTC ERC-20 token contract:**

```bash
export WBTC=0x7ccF0411c7932B99FC3704d68575250F032e3bB7
```

**DAI ERC-20 token contract:**

```bash
export MCD_DAI=0x11fE4B6AE13d2a6055C8D9cF65c55bac32B5d844
```

**WBTC-A token join adapter:**

```bash
export MCD_JOIN_WBTC_A=0x3cbE712a12e651eEAF430472c0C1BF1a2a18939D
```

**Vat contract – Central state storage for MCD:**

```bash
export MCD_VAT=0xB966002DDAa2Baf48369f5015329750019736031
```

**DAI token join adapter:**

```bash
export MCD_JOIN_DAI=0x6a60b7070befb2bfc964F646efDF70388320f4E0
```

**CDP Manager Contract:**

```bash
export CDP_MANAGER=0xdcBf58c9640A7bd0e062f8092d70fb981Bb52032
```

**MCD JUG Contract:**

```bash
export MCD_JUG=0xC90C99FE9B5d5207A03b9F28A6E8A19C0e558916
```

## Token approval

We do not transfer ERC-20 tokens manually to the MCD adapters – instead we give approval for the adapters to using some of our ERC-20 tokens. The following section will take us through the necessary steps.

In this example, we are going to use 5 WBTC tokens to draw 15000 DAI. You may of course use different amounts, just remember to change it accordingly in the function calls of this guide, while ensuring that you are within the accepted collateralization ratio (`mat`) of a WBTC Vault and the minimum vault debt (`dust`) – respectively, `145%` and `15000` DAI at the time of this writing.

Let’s approve the use of 5 WBTC tokens for the adapter, and then call the `approve` function of the WBTC token contract with the right parameters. Again, we have to do some conversions:

```bash
seth send $WBTC 'approve(address, uint256)' $MCD_JOIN_WBTC_A $(seth --from-fix $WBTC_DECIMALS 5)
```

If we want to be sure that our approval transaction succeeded, we can check the results with this command:

```bash
seth call $WBTC 'allowance(address, address)(uint256)' $ETH_FROM $MCD_JOIN_WBTC_A | \
    seth --to-fix $WBTC_DECIMALS
```

Output:

`5.00000000`

## Finally interacting with the Maker Protocol contracts

In order to better understand the MCD contracts, the following provides a brief explanation of relevant terms.

- `wad`: token unit amount
- `gem`: collateral token adapter
- `ilk`: Vault type
- `urn`: Vault record – keeps track of a Vault
- `ink`: rate \* wad represented in collateral
- `dink`: delta ink – a signed difference value to the current value
- `art`: rate \* wad represented in DAI
- `dart`: delta art – a signed difference value to the current value
- `lad`: Vault owner
- `rat`: collateralization ratio.

After giving permission to the WBTC adapter of MCD to take some of our tokens, it’s time to finally start using the MCD contracts.

We'll be using the [CDP Manager](https://github.com/makerdao/dss-cdp-manager) as the preferred interface to interact with MCD contracts.

We begin by opening an empty Vault, so we can use it to lock collateral into. For this we need to define the type of collateral (WBTC-A) we want to lock in this Vault:

```bash
export ilk=$(seth --to-bytes32 $(seth --from-ascii "WBTC-A"))
```

Now let’s open the Vault:

```bash
seth send $CDP_MANAGER 'open(bytes32, address)' $ilk $ETH_FROM
```

We need the `cdpId` and `urn` address of our open Vault, so we can interact with the system:

```bash
export cdpId=$(seth call $CDP_MANAGER 'last(address)(uint256)' $ETH_FROM)
export urn=$(seth call $CDP_MANAGER 'urns(uint256)(address)' $cdpId)
```

After acquiring `cdpId` and `urn` address, we can move to the next step: locking our tokens into the system.

First we are going to make a transaction to the WBTC adapter to actually take 5 of our tokens with the join contract function.
The contract function looks like the following: `join(address urn, uint256 amt)`.

- The first parameter is the `urn`, our vault address
- The second parameter is the token amount.

For the sake of readability, we set the `amt` parameter representing the amount of collateral:

```bash
export amt=$(seth --from-fix $WBTC_DECIMALS 5)
```

Then use the following command to use the join function, thus taking 5 WBTC from our account and sending to `urn` address.

```bash
seth send $MCD_JOIN_WBTC_A 'join(address, uint256)' $urn $amt
```

**ℹ️ NOTICE:** From this point on, the [join-5](https://goerli.etherscan.io/address/0x3cbE712a12e651eEAF430472c0C1BF1a2a18939D#code) adapter already took care of the fact that WBTC has only 8 decimals, so we can proceed with `wad` normally.

Inside the `Vat`, different parameters have different decimal precisions:

- `dai`: 45 decimals `[rad]`
- `rate`: 27 decimals `[ray]`
- `dink`: 18 decimals `[wad]`.
- `dart`: 18 decimals `[wad]`.
- ...

Learn more about naming in MCD [here](https://github.com/makerdao/dss/wiki/Glossary#general).

We can check the results with the contract function: `gem(bytes32 ilk, address urn)(uint256)` with:

```bash
seth call $MCD_VAT 'gem(bytes32, address)(uint256)' $ilk $urn | seth --from-wei
```

The output should look like this:

`5.000000000000000000`

An optional, but recommended step is to invoke `jug.drip(ilk)` to make we are not paying undue stability fees.

```bash
seth send $MCD_JUG 'drip(bytes32)' $ilk
```

 For more details, please see the guide [Intro to the Rate mechanism](../intro-rate-mechanism/intro-rate-mechanism.md).

The next step is adding the collateral into an urn. This is done through the `CDP Manager` contract.

The function is called `frob(uint256, uint256, uint256)`, which receives the following parameters:

- `uint256 cdp`: the `cdpId`
- `int256 dink`: delta ink (collateral) `[wad]`
- `int256 dart`: delta art (Dai). `[wad]`

If the `frob` operation is successful, it will adjust the corresponding data in the protected `vat` module. When adding collateral to an `urn`, `dink` needs to be the (positive) amount we want to add and `dart` needs to be the (positive) amount of DAI we want to draw. 

Let’s add our 5 WBTC to the urn, and draw 15000 DAI ensuring that the position is overcollateralized.
We already set up `cdp` before, so we only need to set up `dink` (WBTC deposit) and `dart` (DAI to be drawn):

**ℹ️ NOTICE:** The `Vat` uses an internal `dai` representation called “normalized art” that is useful to calculate accrued stability fees.
To convert the Dai amount to normalized art, we have to divide it by the current ilk `rate`:

```bash
export WAD_DECIMALS=18
export RAY_DECIMALS=27
export RAD_DECIMALS=45

export dink=$(seth --to-wei 5 eth)
export rate=$(seth call $MCD_VAT \
    'ilks(bytes32)(uint256 Art, uint256 rate, uint256 spot, uint256 line, uint256 dust)' $ilk | \
    sed -n 2p | seth --to-fix $RAY_DECIMALS)
export dart=$(bc<<<"scale=${WAD_DECIMALS}; art=(15000/$rate*10^${WAD_DECIMALS}+1); scale=0; art/1")
```

With the variables set, we can call `frob`:
```bash
seth send $CDP_MANAGER 'frob(uint256, int256, int256)' $cdpId $dink $dart
```

Now, let’s check out our internal DAI balance to see if we have succeeded. We can use the `vat` function `dai(address urn)(uint256)`:

```bash
seth call $MCD_VAT 'dai(address)(uint256)' $urn | seth --to-fix $RAD_DECIMALS
```

The output should look like this (The result isn't exactly 15000 Dai because of number precision):

`15000.000000000000000000384361909233192325560636045`

Now this DAI is minted, but the balance is still technically owned by the DAI adapter of MCD.

If we actually want to use it, we have to transfer it to our account:

```bash
export rad=$(seth call $MCD_VAT 'dai(address)(uint256)' $urn)
seth send $CDP_MANAGER 'move(uint256, address, uint256)' $cdpId $ETH_FROM $rad
```

**ℹ️ NOTICE:** Here, `rad`, is the total amount of DAI available in the `urn`. We are reading this number to get all the DAI possible.

We now allow the Dai adapter to move Dai from VAT to our address:

```bash
seth send $MCD_VAT 'hope(address)' $MCD_JOIN_DAI
```

And finally we exit the internal `dai` to the ERC-20 DAI:

```bash
seth send $MCD_JOIN_DAI 'exit(address, uint256)' $ETH_FROM $(seth --to-wei 15000 eth)
```

And to check the DAI balance of our account:

```bash
seth call $MCD_DAI 'balanceOf(address)(uint256)' $ETH_FROM | seth --from-wei
```

Expected output:

`15000.000000000000000000`

If everything checks out, congratulations: you have just acquired some multi-collateral DAI on Goerli!

## Paying back DAI debt to release collateral

To pay back your DAI and release the locked collateral, follow the following steps. 

**⚠️ ATTENTION:** Please make sure to **obtain some additional Dai** (from another account or from another vault) because chances are interest will have accumulated in the meantime.

To force stability fee accumulation, anyone can invoke `jug.drip(ilk)`:

```bash
seth send $MCD_JUG 'drip(bytes32)' $ilk
```

First thing is to determine what is our debt, including the accrued stability fee:

```bash
export WAD_DECIMALS=18
export RAY_DECIMALS=27
export RAD_DECIMALS=45

export art=$(seth call $MCD_VAT 'urns(bytes32, address)(uint256 ink, uint256 art)' $ilk $urn | \
    sed -n 2p | seth --from-wei)
export rate=$(seth call $MCD_VAT \
    'ilks(bytes32)(uint256 Art, uint256 rate, uint256 spot, uint256 line, uint256 dust)' $ilk | \
    sed -n 2p | seth --to-fix $RAY_DECIMALS)
export debt=$(bc<<<"${art}*${rate}")
export debtWadRound=$(bc<<<"(${art}*${rate}*10^${WAD_DECIMALS})/1 + 1")
```

- `art`: internal vault debt representation `[wad]`
- `rate`: accumulated stability fee from the system `[ray]`
- `debt`: vault debt in Dai `[rad]`
- `debtWadRound`: vault debt added by 1 wad to avoid rounding issues `[wad]`.

Then we need to approve the transfer of DAI tokens to the adapter. Call the `approve` function of the DAI ERC-20 token contract with the right parameters:

```bash
seth send $MCD_DAI 'approve(address, uint256)' $MCD_JOIN_DAI $debtWadRound
```

If we want to be sure that our approval transaction succeeded, we can check the results with this command:

```bash
seth call $MCD_DAI 'allowance(address, address)(uint256)' $ETH_FROM $MCD_JOIN_DAI | seth --from-wei
```

Output:

`15000.041850037339693452`

Now to actually join the Dai to the adapter:

```bash
seth send $MCD_JOIN_DAI 'join(address, uint256)' $urn $debtWadRound
```

To make sure it all worked:

```bash
seth call $MCD_VAT 'dai(address)(uint256)' $urn | seth --to-fix $RAD_DECIMALS
```

Output:

`15000.041850037339693452000000000000000000000000000`

Now, onto actually getting our collateral back. `dart` and `dink`, as the `d` in their abbreviation stands for delta, are inputs for changing a value, and thus they can be negative. When we want to lower the amount of DAI drawn from the `urn`, we lower the art parameter of the `urn`.

We only need to set up the `dink` and `dart` variables.

```bash
dink=$(seth --to-int256 -$(seth --to-wei 5 eth))
dart=$(seth --to-int256 -$(seth --to-wei $art eth))
```

Again, we need to use the `frob` operation to change these parameters `frob(uint256 cdpId, address from, int dink, int dart)`:

```bash
seth send $CDP_MANAGER 'frob(uint256, int256, int256)' $cdpId $dink $dart
```

This doesn’t mean we have already got back your tokens yet. Our account’s WBTC balance is not yet back to the original amount:

```bash
seth call $WBTC 'balanceOf(address)(uint256)' $ETH_FROM | seth --to-fix $WBTC_DECIMALS
```

Output:

`0.00000000`

The WBTC is still assigned to the Vault, so we need to move them to our address:

```bash
export wad=$(seth --to-wei 5 eth)
seth send $CDP_MANAGER 'flux(uint256, address, uint256)' $cdpId $ETH_FROM $wad
```

**ℹ️ NOTICE:** We are about to interact with the [join-5](https://goerli.etherscan.io/address/0x3cbE712a12e651eEAF430472c0C1BF1a2a18939D#code) adapter once again, so we need to bring `$WBTC_DECIMALS` back into the equation.

From there exit the WBTC adapter to get back our tokens:

```bash
export WBTC_DECIMALS=8

export amt=$(seth --from-fix $WBTC_DECIMALS 5)
seth send $MCD_JOIN_WBTC_A 'exit(address, uint256)' $ETH_FROM $amt
```

If we check the balance again:

```bash
seth call $WBTC 'balanceOf(address)(uint256)' $ETH_FROM | seth --to-fix $WBTC_DECIMALS
```

Output:

`5.00000000`

Yay, you got back your tokens! If you have come this far, congratulations, you have finished paying back the debt of your Vault in Multi-Collateral Dai and getting back the collateral.

Spend those freshly regained test WBTC tokens wisely!
