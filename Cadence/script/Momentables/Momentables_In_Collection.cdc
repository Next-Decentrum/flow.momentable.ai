import NonFungibleToken from 0x631e88ae7f1d7c20
import Momentables from 0xa5bb5acbf4dd8848

// This script returns the size of an account's MomentablesV2 collection.

pub fun main(address: Address): Int {
    let account = getAccount(address)

    let collectionRef = account.getCapability(/public/MomentablesCollection)
        .borrow<&{NonFungibleToken.CollectionPublic}>()
        ?? panic("Could not borrow capability from public collection")
    
    return collectionRef.getIDs().length
}