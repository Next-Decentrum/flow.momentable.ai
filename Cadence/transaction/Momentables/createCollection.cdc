import NonFungibleToken from 0x631e88ae7f1d7c20
import Momentables from 0xbbd7a5e25771f977


transaction {
    prepare(signer: AuthAccount) {

        if signer.borrow<&Momentables.Collection>(from: Momentables.CollectionStoragePath) == nil {

            let collection <- Momentables.createEmptyCollection()
            signer.save(<-collection, to: Momentables.CollectionStoragePath)
            signer.link<&Momentables.Collection{NonFungibleToken.CollectionPublic, Momentables.MomentablesCollectionPublic}>(Momentables.CollectionPublicPath, target: Momentables.CollectionStoragePath)
            log("collection created")
        }
    }
}