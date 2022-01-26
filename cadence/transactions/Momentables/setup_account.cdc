import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import Momentables from "../../contracts/Momentables.cdc"

// This transaction configures an account to hold Momentables.

transaction {
    prepare(signer: AuthAccount) {
        // if the account doesn't already have a collection
        if signer.borrow<&Momentables.Collection>(from: Momentables.CollectionStoragePath) == nil {

            // create a new empty collection
            let collection <- Momentables.createEmptyCollection()
            
            // save it to the account
            signer.save(<-collection, to: Momentables.CollectionStoragePath)

            // create a public capability for the collection
            signer.link<&Momentables.Collection{NonFungibleToken.CollectionPublic, Momentables.MomentablesCollectionPublic}>(Momentables.CollectionPublicPath, target: Momentables.CollectionStoragePath)
        }
    }
}
