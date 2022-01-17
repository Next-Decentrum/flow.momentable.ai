import NonFungibleToken from 0x631e88ae7f1d7c20
import Momentables from 0xa5bb5acbf4dd8848
import FungibleToken from 0x9a0766d93b6608b7
import FlowToken from 0x7e60df042a9c0868
import NFTStorefront from 0x94b06cfca1d8a476

pub fun getOrCreateCollection(account: AuthAccount): &Momentables.Collection{NonFungibleToken.Receiver} {
    if let collectionRef = account.borrow<&Momentables.Collection>(from: /storage/MomentablesCollection) {
        return collectionRef
    }

    // create a new empty collection
    let collection <- Momentables.createEmptyCollection() as! @Momentables.Collection

    let collectionRef = &collection as &Momentables.Collection
    
    // save it to the account
    account.save(<-collection, to: /storage/MomentablesCollection)

    // create a public capability for the collection
    account.link<&Momentables.Collection{NonFungibleToken.CollectionPublic, Momentables.MomentablesCollectionPublic}>(/public/MomentablesCollection, target: /storage/MomentablesCollection)

    return collectionRef
}

transaction(listingResourceID: UInt64, storefrontAddress: Address) {

    let paymentVault: @FungibleToken.Vault
    let MomentablesCollection: &Momentables.Collection{NonFungibleToken.Receiver}
    let storefront: &NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}
    let listing: &NFTStorefront.Listing{NFTStorefront.ListingPublic}

    prepare(account: AuthAccount) {
        self.storefront = getAccount(storefrontAddress)
            .getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(
                NFTStorefront.StorefrontPublicPath
            )!
            .borrow()
            ?? panic("Could not borrow Storefront from provided address")

        self.listing = self.storefront.borrowListing(listingResourceID: listingResourceID)
            ?? panic("No Listing with that ID in Storefront")
        
        let price = self.listing.getDetails().salePrice

        let mainFLOWVault = account.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("Cannot borrow FLOW vault from account storage")
        
        self.paymentVault <- mainFLOWVault.withdraw(amount: price)

        self.MomentablesCollection = getOrCreateCollection(account: account)
    }

    execute {
        let item <- self.listing.purchase(
            payment: <-self.paymentVault
        )

        self.MomentablesCollection.deposit(token: <-item)

        self.storefront.cleanup(listingResourceID: listingResourceID)
    }
}