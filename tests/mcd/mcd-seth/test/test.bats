#!./test/libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'


. test_helper.bash

@test "check REP balance" {
  run seth --from-wei $(seth --to-dec $(seth call $REP 'balanceOf(address)' $ETH_FROM)) eth
  assert_line '50.000000000000000000'
}

@test "approve MCD_JOIN_REP to withdraw 10 REP" {
  run seth send $REP 'approve(address,uint256)' $MCD_JOIN_REP_A $(seth --to-uint256 $(seth --to-wei 10 eth))
  [[ "$output" == *"seth-send: Transaction included in block"* ]]
}

@test "JOIN is taking 10 REP" {
  run seth send $MCD_JOIN_REP_A "join(address, uint)" $ETH_FROM $wad
  [[ "$output" == *"seth-send: Transaction included in block"* ]]
}

@test "Check VAT for 10 REP" {
  run seth --from-wei $(seth --to-dec $(seth call $MCD_VAT 'gem(bytes32,address)(uint256)' $ilk $ETH_FROM)) eth
  assert_line '10.000000000000000000'
}

@test "Locking 10 REP and Drawing 35 DAI" {
  run seth send $MCD_VAT "frob(bytes32,address,address,address,int256,int256)" $ilk $ETH_FROM $ETH_FROM $ETH_FROM $dink $dart
  [[ "$output" == *"seth-send: Transaction included in block"* ]]
}

@test "Check Dai balance in VAT" {
  run seth --from-wei $(seth --to-dec $(seth call $MCD_VAT 'dai(address)(uint256)' $ETH_FROM))
  assert_line "35000000000000000000000000000.000000000000000000"
}

@test "Permit DAI Adapter to withdraw Dai from VAT" {
  run seth send $MCD_VAT 'hope(address)' $MCD_JOIN_DAI
  [[ "$output" == *"seth-send: Transaction included in block"* ]]
}

@test "Exiting DAI to own account" {
    export wad=$(seth --to-word $(seth --to-wei 35 eth))
    echo $wad
    run seth send $MCD_JOIN_DAI "exit(address, uint256)" $ETH_FROM $wad
    [[ "$output" == *"seth-send: Transaction included in block"* ]]
}

@test "Check Dai balance after exiting" {
  run seth --from-wei $(seth --to-dec $(seth call $DAI_TOKEN 'balanceOf(address)' $ETH_FROM)) eth
  assert_line "35.000000000000000000"
}


@test "Approve Dai adapter to withdraw from your account" {
  echo Paying Back DAI
  run seth send $DAI_TOKEN 'approve(address,uint256)' $MCD_JOIN_DAI $(seth --to-uint256 $(seth --to-wei 35 eth))
  [[ "$output" == *"seth-send: Transaction included in block"* ]]
}

@test "Verify DAI adapter approval" {
  run seth --from-wei $(seth --to-dec $(seth call $DAI_TOKEN 'allowance(address, address)' $ETH_FROM $MCD_JOIN_DAI)) eth
  assert_line "35.000000000000000000"
}

@test "Join DAI to the adapter" {
  export wad=$(seth --to-word $(seth --to-wei 35 eth))
  run seth send $MCD_JOIN_DAI "join(address,uint)" $ETH_FROM $wad
  [[ "$output" == *"seth-send: Transaction included in block"* ]]
}

@test "Pay back DAI and unlock REP" {
  export dink=$(seth --to-uint256 $minus10hex)
  export dart=$(seth --to-uint256 $minus35hex)
  run seth send $MCD_VAT "frob(bytes32,address,address,address,int256,int256)" $ilk $ETH_FROM $ETH_FROM $ETH_FROM $dink $dart
  [[ "$output" == *"seth-send: Transaction included in block"* ]]
}

@test "Get REP tokens from REP adapter" {
  export wad=$(seth --to-word $(seth --to-wei 10 eth))
  run seth send $MCD_JOIN_REP_A 'exit(address,uint)' $ETH_FROM $wad
  [[ "$output" == *"seth-send: Transaction included in block"* ]]
}

@test "Check REP balance: == 50 REP" {
  run seth --from-wei $(seth --to-dec $(seth call $REP 'balanceOf(address)' $ETH_FROM)) eth
  assert_line "50.000000000000000000"
}