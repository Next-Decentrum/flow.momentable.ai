## create collection
flow transactions send --network=testnet --signer=testnet-account ./Cadence/transaction/Momentables/createCollection.cdc

## check collection
flow scripts execute --network=testnet ./Cadence/script/Momentables/checkCollection.cdc --arg Address: 0xabc

## mint momentables
flow transactions send --network=testnet --signer=testnet-account ./Cadence/transaction/Momentables/mint.cdc --arg Address:0xabc, --arg String:"One", --arg String:"First"

## momentables in collection
flow scripts execute --network=testnet ./Cadence/script/Momentables_In_Collection.cdc --arg Address:0xabc

## transfer the momentalbles to another account
flow transactions send --network=testnet --signer=testnet-account ./Cadence/transaction/Momentables/transfer.cdc --arg Address:0xabc, --arg UInt64:1

## get flow token balance
flow scripts execute --network=testnet --signer=testnet-account ./Cadence/transaction/FlowToken/get_balance.cdc --arg Address: 0xabc

## transfer flow token to another account
flow transactions send --network=testnet --signer=testnet-account ./Cadence/transaction/FlowToken/transfer_tokens.cdc --arg Address: 0xabc

## update contract
flow accounts update-contract --network=testnet --signer=testnet-account Momentables ./Cadence/contract/Momentables.cdc