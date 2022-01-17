import NonFungibleToken from 0x631e88ae7f1d7c20
import Momentables from 0xa5bb5acbf4dd8848

transaction(recipient: Address, momentableId: String, metadata: {String:AnyStruct}, royality:Momentables.Royality) {
    
    // local variable for storing the minter reference
    let minter: &Momentables.NFTMinter
    // let vaultCap: Capability<&{FungibleToken.Receiver}>
    //let collectionCap: Capability<&{Momentables.MomentablesCollectionPublic}>

    prepare(signer: AuthAccount) {

        // borrow a reference to the NFTMinter resource in storage
        self.minter = signer.borrow<&Momentables.NFTMinter>(from: /storage/MomentablesMinter)
            ?? panic("Could not borrow a reference to the NFT minter")
    }

    execute {
        // get the public account object for the recipient
        let recipient = getAccount(recipient)

        // borrow the recipient's public NFT collection reference
        let receiver = recipient
            .getCapability(/public/MomentablesCollection)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get receiver reference to the NFT Collection")

        // mint the NFT and deposit it to the recipient's collection
        self.minter.mintNFT(recipient: receiver, momentableId: momentableId, metadata: metadata, royality:royality)
    }
}