# Emergency Shutdown (ES) CLI Documentation

**Level**: Intermediate  
**Estimated-Time**: 30 minutes

- [Emergency Shutdown (ES) CLI Documentation](#emergency-shutdown-es-cli-documentation)
  - [Description](#description)
  - [Learning Objectives](#learning-objectives)
    - [Table of Contents](#table-of-contents)
  - [1. Installation](#1-installation)
  - [2. Contract Address Setup](#2-contract-address-setup)
  - [3. Commands and Explanations](#3-commands-and-explanations)
    - [Checking your MKR balance](#checking-your-mkr-balance)
    - [Checking and setting your MKR approval](#checking-and-setting-your-mkr-approval)
    - [Checking the live flag](#checking-the-live-flag)
    - [Checking the ESM threshold](#checking-the-esm-threshold)
    - [Deposit a small amount (0.1 MKR) into the ESM](#deposit-a-small-amount-01-mkr-into-the-esm)
    - [Checking how much MKR is in the ESM](#checking-how-much-mkr-is-in-the-esm)
    - [Checking how much MKR you have included in the ESM](#checking-how-much-mkr-you-have-included-in-the-esm)
    - [Depositing e.g. 50,000 MKR into the ESM](#depositing-eg-50000-mkr-into-the-esm)
    - [Checking whether the ESM has been triggered](#checking-whether-the-esm-has-been-triggered)
    - [Triggering the ESM](#triggering-the-esm)
  - [Additional Resources](#additional-resources)

## Description

Emergency Shutdown (ES) is the last resort to protect the MakerDAO system against a serious threat, such as but not limited to governance attacks, long-term market irrationality, hacks and security breaches. The Emergency Shutdown Module (ESM) is responsible for coordinating emergency shutdown, the process used to gracefully shutdown the Maker Protocol and properly allocate collateral to both Vault users and Dai holders. This guide outlines the steps and procedures necessary to check, interact with and trigger the ESM.

## Learning Objectives

- To Check, Deposit and Trigger Emergency Shutdown

### Table of Contents

1. Installation
2. Contract Address Setup
3. Commands and Explanations
    - Checking your MKR balance
    - Checking and setting your MKR approval
    - Checking the live() flag
    - Checking the ESM threshold
    - Deposit a trial amount of MKR into the ESM
    - Depositing MKR into the ESM
    - Checking how much MKR is in the ESM
    - Checking whether the ESM has been triggered
    - Triggering the ESM

## 1. Installation

In order to interface with the Ethereum blockchain, the user needs to install seth, a command line tool as part of the [Dapp.Tools](https://dapp.tools/) toolset. We also provide further [installation information here](https://github.com/makerdao/developerguides/blob/master/devtools/seth/seth-guide-01/seth-guide-01.md). Once the user has installed and configured [`seth`](https://dapp.tools/) correctly to use the main Ethereum network and the address which holds their MKR they can query contract balances, approvals and transfers.

## 2. Contract Address Setup

The user will require the following contract addresses; MCD_END and MCD_ESM accessible at [Changelog.makerdao.com](https://changelog.makerdao.com) as well as the Maker contract address, to be added in place of MKR_ADR below, which can be verified on [Etherscan](https://etherscan.io/token/0x9f8f72aa9304c8b593d555f12ef6589cc3a579a2). These should be setup in the following manner:

```bash
export MCD_END=0xab14d3ce3f733cacb76ec2abe7d2fcb00c99f3d5
export MCD_ESM=0x0581a0abe32aae9b5f0f68defab77c6759100085
export MKR_ADR= <MKR ADDRESS from Etherscan.io>
export MY_ADR= <USER ADDRESS>

#example values for depositing into the ESM
export TRIAL_AMOUNT=$(seth --to-uint256 $(seth --to-wei 0.1 eth))
export REMAINING_AMOUNT=$(seth --to-uint256 $(seth --to-wei 50000 eth))
```

## 3. Commands and Explanations

### Checking your MKR balance

Before depositing your MKR into the ESM contract, first check your address MKR balance:

```bash
seth --from-wei $(seth call $MKR_ADR "balanceOf(address)" $MY_ADR | seth --to-dec)
# 100000.000000000000000000
```

### Checking and setting your MKR approval

In order to execute the contract functions of the MKR token it is required that approvals be set on the token. The first step is to check if the ESM contract is allowed to withdraw from your address:

```bash
seth call $MKR_ADR "allowance(address,address)" $MY_ADR $MCD_ESM
# 0x0000000000000000000000000000000000000000000000000000000000000000 -> not allowed
```

If the ESM contract is not allowed to withdraw from your address, the following can be used to set the allowance on the MKR token. This will approve the ESM to withdraw from the user's wallet:

```bash
seth send $MKR_ADR "approve(address)" $MCD_ESM
```

Following which we again check to confirm that the ESM is allowed to withdraw from the user's account. This action will return uint256 to confirm the allowance to withdraw.

```bash
seth call $MKR_ADR "allowance(address,address)" $MY_ADR $MCD_ESM
# 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff -> allowed
```

[Reference contract information](https://github.com/dapphub/ds-token/blob/cee36a14685b3f93ffa0332853d3fcd943fe96a5/src/token.sol#L36).

### Checking the live flag

Live contracts have `live` = 1, indicating that the system is running normally. Thus when `cage()` is invoked, it sets the flag to 0.

```bash
seth call $MCD_END "live()" | seth --to-dec
# 1 -> system is running normally
```

### Checking the ESM threshold

In order to check the `min` value, you can call:

```bash
seth --from-wei $(seth call $MCD_ESM "min()" | seth --to-dec)
# 50000.000000000000000000
```

### Deposit a small amount (0.1 MKR) into the ESM

To deposit a small amount of MKR into the esm contract to test correct deposit function, we use the `join` function and specify a small amount.

```bash
seth send $MCD_ESM "join(uint256)" $TRIAL_AMOUNT
```

### Checking how much MKR is in the ESM

To check for the total amount of MKR that has been added to the ESM we call the `Sum()` function

```bash
seth --from-wei $(seth call $MCD_ESM "Sum()" | seth --to-dec)
# 50050.000000000000000000
```

### Checking how much MKR you have included in the ESM

To check how much MKR you have included in the ESM we can call lowercase `sum()`  with the user address as an argument:

```bash
seth --from-wei $(seth call $MCD_ESM "sum(address)" $MY_ADR | seth --to-dec)
# 50.000000000000000000
```

### Depositing e.g. 50,000 MKR into the ESM

To deposit MKR into the esm contract we use the `join` function and specify the amount.

```bash
seth send $MCD_ESM "join(uint256)" $REMAINING_AMOUNT
```

Please specify the amount of MKR that you intend to deposit into the ESM.

### Checking whether the ESM has been triggered

To validate that the Emergency Shutdown has been triggered, the `fired()` function can be called which will return a boolean.

```bash
seth call $MCD_ESM "fired()" | seth --to-dec
# 0 -> ES has not been triggered
```

### Triggering the ESM

In order for the emergency shutdown to trigger, it is required that the `Sum()` is greater than the `min()` . Only then can the `fire()` function be executed successfully.

```bash
seth send $MCD_ESM "fire()"
```

**Note:** If triggering the ESM is not successful, ensure gas is set at an appropriate level

**Note:** The triggering of the ESM is **not** to be taken lightly; for a full explanation of the implications please review the below documentation.

## Additional Resources

- [ESM.sol](https://github.com/makerdao/esm/blob/master/src/ESM.sol)
- [Further Documentation](https://docs.makerdao.com/smart-contract-modules/emergency-shutdown-module)
- [End Documentation](https://docs.makerdao.com/smart-contract-modules/shutdown/end-detailed-documentation)
