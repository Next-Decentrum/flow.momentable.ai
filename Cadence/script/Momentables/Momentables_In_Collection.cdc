import NonFungibleToken from 0x631e88ae7f1d7c20
import Momentables from 0xbbd7a5e25771f977

// This script returns the size of an account's MomentablesV2 collection.

pub fun main(address: Address): Int {
    let account = getAccount(address)

    let collectionRef = account.getCapability(Momentables.CollectionPublicPath)
        .borrow<&{NonFungibleToken.CollectionPublic}>()
        ?? panic("Could not borrow capability from public collection")
    
    return collectionRef.getIDs().length
}