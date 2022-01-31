import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import Momentables from "../../contracts/Momentables.cdc"

// This transaction transfers a Momentables from one account to another.

transaction(recipient: Address, withdrawID: UInt64) {
    prepare(signer: AuthAccount) {

        if signer.borrow<&Momentables.Collection>(from: Momentables.CollectionStoragePath) == nil {

            // create a new empty collection
            let collection <- Momentables.createEmptyCollection()
            
            // save it to the account
            signer.save(<-collection, to: Momentables.CollectionStoragePath)

            // create a public capability for the collection
            signer.link<&Momentables.Collection{NonFungibleToken.CollectionPublic, Momentables.MomentablesCollectionPublic}>(Momentables.CollectionPublicPath, target: Momentables.CollectionStoragePath)
        }
        
        // get the recipients public account object
        let recipient = getAccount(recipient)

        // borrow a reference to the signer's NFT collection
        let collectionRef = signer.borrow<&Momentables.Collection>(from: Momentables.CollectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")

        // borrow a public reference to the receivers collection
        let depositRef = recipient.getCapability(Momentables.CollectionPublicPath).borrow<&{NonFungibleToken.CollectionPublic}>()!

        // withdraw the NFT from the owner's collection
        let nft <- collectionRef.withdraw(withdrawID: withdrawID)

        // Deposit the NFT in the recipient's collection
        depositRef.deposit(token: <-nft)
    }
}
