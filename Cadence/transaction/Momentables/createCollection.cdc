import NonFungibleToken from 0x631e88ae7f1d7c20
import MomentablesV2 from 0xa5bb5acbf4dd8848


transaction {
    prepare(signer: AuthAccount) {

        if signer.borrow<&MomentablesV2.Collection>(from: MomentablesV2.CollectionStoragePath) == nil {

            let collection <- MomentablesV2.createEmptyCollection()
            signer.save(<-collection, to: MomentablesV2.CollectionStoragePath)
            signer.link<&MomentablesV2.Collection{NonFungibleToken.CollectionPublic, MomentablesV2.MomentablesV2CollectionPublic}>(MomentablesV2.CollectionPublicPath, target: MomentablesV2.CollectionStoragePath)
            log("collection created")
        }
    }
}