#!/bin/bash
export MCD_CHAIN=kovan
export SETH_CHAIN=kovan
export ETH_FROM=0x18d92ba0b79d769e6b781b92ee2e9d45b3e1e017
export ETH_KEYSTORE=./account/
export ETH_PASSWORD=./account/pass
export REP=0xc7aa227823789e363f29679f23f7e8f6d9904a9b
export DAI_TOKEN=0x5944413037920674d39049ec4844117a031eaa74
export MCD_JOIN_REP_A=0x7d9d701e87920a1a7396438769b571fb55b6ffdc
export MCD_VAT=0x5ce1e3c8ba1363c7a87f5e9118aac0db4b0f0691
export MCD_JOIN_DAI=0xe70a5307f5132ee3a6a056c5efb7d5a53f3cdbd7
export urn=$ETH_FROM
export wad=$(seth --to-uint256 $(seth --to-wei 10 eth))
export ilk=$(seth --to-bytes32 $(seth --from-ascii "REP-A"))
export dink=$(seth --to-uint256 $(seth --to-hex $(seth --to-wei 10 eth)))
export dart=$(seth --to-uint256 $(seth --to-hex $(seth --to-wei 35 eth)))
export minus10hex=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7538DCFB76180000
export minus35hex=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE1A4705701D540000






