import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import FungibleToken from "../../contracts/FungibleToken.cdc"
import FlowToken from "../../contracts/FlowToken.cdc"

import Momentables from "../../contracts/Momentables.cdc"

transaction(
 recipient: Address,
 momentableId: String,
 name: String,
 description: String,
 imageCID: String,
 directoryPath: String,
 traits: {String:{String:String}},
 creatorName: String,
 creatorAddress: Address,
 creatorRoyalty: UFix64,
 collaboratorNames: [String],
 collaboratorAddresses: [Address],
 collaboratorRoyalties: [UFix64],
 momentableCollectionDetails: {String: String}
 ) {
    
    // local variable for storing the minter reference
    let minter: &Momentables.NFTMinter
    // let vaultCap: Capability<&{FungibleToken.Receiver}>
    //let collectionCap: Capability<&{Momentables.MomentablesCollectionPublic}>

    prepare(signer: AuthAccount) {

        // borrow a reference to the NFTMinter resource in storage
        self.minter = signer.borrow<&Momentables.NFTMinter>(from: Momentables.MinterStoragePath)
            ?? panic("Could not borrow a reference to the NFT minter")
    }

    execute {
        // get the public account object for the recipient
        let recipient = getAccount(recipient)

        // borrow the recipient's public NFT collection reference
        let receiver = recipient
            .getCapability(Momentables.CollectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get receiver reference to the NFT Collection")

        if(collaboratorNames.length != collaboratorAddresses.length &&  collaboratorNames.length != collaboratorRoyalties.length){
             panic("Invalid collaborator data")
        }

        let creatorAccount = getAccount(creatorAddress)
        let creatorWallet = creatorAccount.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/FlowTokenReciever)!
        let creatorData = Momentables.Creator(creatorName: creatorName, creatorWallet: creatorWallet, creatorRoyalty: creatorRoyalty);
        
        let collaboratorsData:[ Momentables.Collaborator] = []

        var index = 0
        while index < collaboratorNames.length{
            let collaboratorAccount = getAccount(collaboratorAddresses[index])
            let collaboratorWallet = collaboratorAccount.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/FlowTokenReciever)!
            collaboratorsData.append(Momentables.Collaborator(collaboratorName: collaboratorNames[index], collaboratorAddress: collaboratorWallet, collaboratorRoyalty: collaboratorRoyalties[index])) 
            index = index+1
        }

        // mint the NFT and deposit it to the recipient's collection
        self.minter.mintNFT(
            recipient: receiver, 
            momentableId: momentableId, 
            name:name,
            description:description,
            imageCID:imageCID, 
            directoryPath: directoryPath,
            traits: traits, 
            creator:creatorData , 
            collaborators: collaboratorsData,
            momentableCollectionDetails: momentableCollectionDetails
            )
    }
}