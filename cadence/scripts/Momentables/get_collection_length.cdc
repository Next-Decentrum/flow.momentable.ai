import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import Momentables from "../../contracts/Momentables.cdc"

// This script returns the size of an account's Momentables collection.

pub fun main(address: Address): Int {
    let account = getAccount(address)

    let collectionRef = account.getCapability(Momentables.CollectionPublicPath)
        .borrow<&{NonFungibleToken.CollectionPublic}>()
        ?? panic("Could not borrow capability from public collection")
    
    return collectionRef.getIDs().length
}
