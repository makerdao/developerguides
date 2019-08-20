#!/bin/bash
export MCD_CHAIN=kovan
export SETH_CHAIN=kovan
export ETH_FROM=0x18d92ba0b79d769e6b781b92ee2e9d45b3e1e017
export ETH_KEYSTORE=./account/
export ETH_PASSWORD=./account/pass
export CDP_MANAGER=0x7a4991c6bd1053c31f1678955ce839999d9841b1
export MCD_VAT=0x04c67ea772ebb467383772cb1b64c7a9b1e02bca
export REP=0xc7aa227823789e363f29679f23f7e8f6d9904a9b
export MCD_JOIN_REP_A=0x91f4e07be74445a3897b6d4e70393b5ad7b8e4b0
export MCD_DAI=0xdb6a55a94e0dd324292f3d05cf504c751b31cee2
export MCD_JOIN_DAI=0xcf20652c7e9ff777fcb3772b594e852d1154174d
export ETH_GAS=2000000
export ilk=$(seth --to-bytes32 $(seth --from-ascii "REP-A"))
export urn=$(seth call $CDP_MANAGER 'urns(uint)(address)' 7)
export dink=$(seth --to-uint256 $(seth --to-wei 20 eth))
export dart=$(seth --to-uint256 $(seth --to-wei 5 eth))
export nDink=$(seth --to-uint256 $(mcd --to-hex $(seth --to-wei -20 eth)))
export nDart=$(seth --to-uint256 $(mcd --to-hex $(seth --to-wei -5 eth)))



