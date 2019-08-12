#!./test/libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'


. test_helper.bash

@test "testing variable" {
    export wad=$(seth --to-word $(seth --to-wei 35 eth))
    echo $wad
    run seth send $MCD_JOIN_DAI "exit(address, uint256)" $ETH_FROM $wad
    [[ "$output" == *"seth-send: Transaction included in block"* ]]
}
