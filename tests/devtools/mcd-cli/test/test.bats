#!./test/libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'


. test_helper.bash

@test "mcd ilks" {
  run mcd ilks
  assert_line 'ILK     GEM           DESC'
}

@test "mcd --ilk=REP-A gem join 50" {
  run mcd --ilk=REP-A gem join 50
  assert_line --index 5 'vat 50.000000000000000000 Unlocked collateral (REP)'
}

@test "mcd --ilk=REP-A frob 50 1" {
  run mcd --ilk=REP-A frob 50 1
  assert_line --index 5 'ilk  REP-A                                      Collateral type'
}

@test "mcd dai exit 1" {
  run mcd dai exit 1
  assert_line --index 6 'ext 1.000000000000000000 ERC20 Dai balance'
}

@test "mcd dai join 1" {
  run mcd dai join 1
  assert_line --index 6 'ext 0.000000000000000000 ERC20 Dai balance'
}

@test "mcd --ilk=REP-A frob -- -50 -1" {
  run mcd --ilk=REP-A frob -- -50 -1
  assert_line --index 5 'ilk  REP-A                                      Collateral type'
}

@test "mcd --ilk=REP-A gem exit 50" {
  run mcd --ilk=REP-A gem exit 50
  assert_line --index 5 'vat 0.000000000000000000 Unlocked collateral (REP)'
}
