#!./test/libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'


load test_helper

@test "mcd ilks" {
  run mcd ilks
  assert_line 'ILK      GEM           DESC'
}

@test "mcd --ilk=COL1-A gem join 60" {
  run mcd --ilk=COL1-A gem join 60
  assert_line --index 5 'vat 60.000000000000000000 Unlocked collateral (COL1)'
}

@test "mcd --ilk=COL1-A frob 60 1" {
  run mcd --ilk=COL1-A frob 60 1
  assert_line --index 5 'ilk  COL1-A                                     Collateral type'
}

@test "mcd dai exit 1" {
  run mcd dai exit 1
  assert_line --index 6 'ext 1.000000000000000000 ERC20 Dai balance'
}

@test "mcd dai join 1" {
  run mcd dai join 1
  assert_line --index 6 'ext 0.000000000000000000 ERC20 Dai balance'
}

@test "mcd --ilk=COL1-A frob -- -60 -1" {
  run mcd --ilk=COL1-A frob -- -60 -1
  assert_line --index 7 'ink  0.000000000000000000                       Locked collateral (COL1)'
}

@test "mcd --ilk=COL1-A gem exit 60" {
  run mcd --ilk=COL1-A gem exit 60
  assert_line --index 5 'vat 0.000000000000000000 Unlocked collateral (COL1)'
}
