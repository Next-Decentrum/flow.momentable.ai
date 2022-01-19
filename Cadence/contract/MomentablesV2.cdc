{
	"contracts": {
		"MomentablesV2": "./Cadence/contract/MomentablesV2.cdc",
		"FlowToken": {
			"source":"./Cadence/contract/FlowToken.cdc",
			"aliases": {
				"testnet":"0x7e60df042a9c0868",
				"mainnet":"0x1654653399040a61"
			}
		},
		"NFTStorefront": {
			"source":"./Cadence/contract/NFTStorefront.cdc",
			"aliases": {
				"testnet":"0x94b06cfca1d8a476",
				"mainnet":"0x4eb8a10cb9f87357"
			}
		},
		"NonFungibleToken": {
			"source":"./Cadence/contract/NonFungibleToken.cdc",
			"aliases": {
				"testnet":"0x631e88ae7f1d7c20",
				"mainnet": "0x1d7e57aa55817448"
			}
		},
		"FungibleToken": {
            "source": "./Cadence/contract/FungibleToken.cdc",
            "aliases": {
                "testnet": "0x9a0766d93b6608b7",
                "mainnet": "0xf233dcee88fe0abe"
            }
        }
	},
	"networks": {
		"mainnet": "access.mainnet.nodes.onflow.org:9000",
		"testnet": "access.devnet.nodes.onflow.org:9000"
	},
	"accounts": {
		"testnet-account": {
            "address": "0xa5bb5acbf4dd8848",
            "key": {
                "type": "hex",
                "index": 0,
                "signatureAlgorithm": "ECDSA_P256",
                "hashAlgorithm": "SHA3_256",
                "privateKey": "e6a1819471085bf150f3774c1aee410f518273aee00a745d4a7b8f1c66963050"
            }
        },
		"testnet-account1": {
            "address": "0x4f63c8c3cfe3a424",
            "key": {
                "type": "hex",
                "index": 0,
                "signatureAlgorithm": "ECDSA_P256",
                "hashAlgorithm": "SHA3_256",
                "privateKey": "efd86d59a05e240b31b32ee5a36b8d1bc84ddb7d3c83a5845bd7ea63a637adc5"
            }
        }
	},
	"deployments": {
		"testnet": {
			"testnet-account":["MomentablesV2"]
		}
	}
}