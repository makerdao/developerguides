#!./test/libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'


. test_helper.bash

@test "check REP balance" {
  run seth --from-wei $(seth --to-dec $(seth call $REP 'balanceOf(address)' $ETH_FROM)) eth
  assert_line '50.000000000000000000'
}

@test "approve MCD_JOIN_REP to withdraw 20 REP" {
  run seth send $REP 'approve(address,uint)' $MCD_JOIN_REP_A $dink
  [[ "$output" == *"seth-send: Transaction included in block"* ]]
}

@test "Send 20 REP to urn" {
  run seth send $MCD_JOIN_REP_A 'join(address,uint)' $urn $dink
  [[ "$output" == *"seth-send: Transaction included in block"* ]]
}

@test "Locking 20 REP and issuing 5 Dai" {
  run seth send $CDP_MANAGER 'frob(uint,address,int,int)' 7 $ETH_FROM $dink $dart
  [[ "$output" == *"seth-send: Transaction included in block"* ]]
}

@test "Approving MCD_JOIN_DAI to exit" {
  run seth send $MCD_VAT 'hope(address)' $MCD_JOIN_DAI
  [[ "$output" == *"seth-send: Transaction included in block"* ]]
}

@test "Exiting DAI to own wallet address" {
  run seth send $MCD_JOIN_DAI 'exit(address,uint)' $ETH_FROM $dart
  [[ "$output" == *"seth-send: Transaction included in block"* ]]
}

@test "Check Dai balance in own wallet" {
  run seth --from-wei $(seth --to-dec $(seth call $MCD_DAI 'balanceOf(address)' $ETH_FROM))
  assert_line "5.000000000000000000"
}

@test "Approving MCD_JOIN_DAI to take DAI from your wallet" {
  run seth send $MCD_DAI 'approve(address,uint)' $MCD_JOIN_DAI $dart
  [[ "$output" == *"seth-send: Transaction included in block"* ]]
}

@test "Sending DAI to urn" {
  run seth send $MCD_JOIN_DAI 'join(address,uint)' $urn $dart
  [[ "$output" == *"seth-send: Transaction included in block"* ]]
}

@test "Paying back DAI and receving ink to wallet" {
  run seth send $CDP_MANAGER 'frob(uint,address,int,int)' 7 $ETH_FROM $nDink $nDart
  [[ "$output" == *"seth-send: Transaction included in block"* ]]
}

@test "Exiting collateral from REP adapter" {
  run seth send $MCD_JOIN_REP_A 'exit(address,uint)' $ETH_FROM $dink
  [[ "$output" == *"seth-send: Transaction included in block"* ]]
}

@test "check REP balance" {
  run seth --from-wei $(seth --to-dec $(seth call $REP 'balanceOf(address)' $ETH_FROM)) eth
  assert_line '50.000000000000000000'
}
