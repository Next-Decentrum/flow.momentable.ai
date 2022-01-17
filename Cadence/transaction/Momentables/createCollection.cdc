import NonFungibleToken from 0x631e88ae7f1d7c20
import Momentables from 0xa5bb5acbf4dd8848


transaction {
    prepare(signer: AuthAccount) {

        if signer.borrow<&Momentables.Collection>(from: /storage/MomentablesCollection) == nil {

            let collection <- Momentables.createEmptyCollection()
            signer.save(<-collection, to: /storage/MomentablesCollection)
            signer.link<&Momentables.Collection{NonFungibleToken.CollectionPublic, Momentables.MomentablesCollectionPublic}>(/public/MomentablesCollection, target: /storage/MomentablesCollection)
            log("collection created")
        }
    }
}