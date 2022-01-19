import NonFungibleToken from 0x631e88ae7f1d7c20
import MomentablesV1 from 0xa5bb5acbf4dd8848


// This transction uses the NFTMinter resource to mint a new NFT.
//
// It must be run with the account that has the minter resource
// stored at path /storage/NFTMinter.

transaction(recipient: Address, momentableId: String, metadata: {String:AnyStruct},creator:MomentablesV1.Creator, collaborators:[MomentablesV1.Collaborator]) {
    
    // local variable for storing the minter reference
    let minter: &MomentablesV1.NFTMinter

    prepare(signer: AuthAccount) {
        // borrow a reference to the NFTMinter resource in storage
        self.minter = signer.borrow<&MomentablesV1.NFTMinter>(from: MomentablesV1.MinterStoragePath)
            ?? panic("Could not borrow a reference to the NFT minter")
    }

    execute {
        // get the public account object for the recipient
        let recipient = getAccount(recipient)

        // borrow the recipient's public NFT collection reference
        let receiver = recipient
            .getCapability(MomentablesV1.CollectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get receiver reference to the NFT Collection")

        // mint the NFT and deposit it to the recipient's collection
        self.minter.mintNFT(recipient: receiver, momentableId: momentableId, metadata: metadata, creator:creator, collaborators:collaborators)
    }
}
