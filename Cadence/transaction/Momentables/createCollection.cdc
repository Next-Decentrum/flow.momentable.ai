import NonFungibleToken from 0x631e88ae7f1d7c20
import MomentablesV1 from 0xa5bb5acbf4dd8848


transaction {
    prepare(signer: AuthAccount) {

        if signer.borrow<&MomentablesV1.Collection>(from: MomentablesV1.CollectionStoragePath) == nil {

            let collection <- MomentablesV1.createEmptyCollection()
            signer.save(<-collection, to: MomentablesV1.CollectionStoragePath)
            signer.link<&MomentablesV1.Collection{NonFungibleToken.CollectionPublic, MomentablesV1.MomentablesV1CollectionPublic}>(MomentablesV1.CollectionPublicPath, target: MomentablesV1.CollectionStoragePath)
            log("collection created")
        }
    }
}