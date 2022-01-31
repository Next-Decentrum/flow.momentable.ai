import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import FungibleToken from "../../contracts/FungibleToken.cdc"
import FlowToken from "../../contracts/FlowToken.cdc"

import Momentables from "../../contracts/Momentables.cdc"
import NFTStorefront from "../../contracts/NFTStorefront.cdc"



pub fun getOrCreateStorefront(account: AuthAccount): &NFTStorefront.Storefront {
    if let storefrontRef = account.borrow<&NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath) {
        return storefrontRef
    }

    let storefront <- NFTStorefront.createStorefront()

    let storefrontRef = &storefront as &NFTStorefront.Storefront

    account.save(<-storefront, to: NFTStorefront.StorefrontStoragePath)

    account.link<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(NFTStorefront.StorefrontPublicPath, target: NFTStorefront.StorefrontStoragePath)

    return storefrontRef
}

transaction(saleItemID: UInt64, saleItemPrice: UFix64) {

    let flowReceiver: Capability<&FlowToken.Vault{FungibleToken.Receiver}>
    let MomentablesProvider: Capability<&Momentables.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>
    let storefront: &NFTStorefront.Storefront

    prepare(account: AuthAccount) {
        

        let MomentablesCollectionProviderPrivatePath = /private/MomentablesCollectionProvider

        self.flowReceiver = account.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)!

        assert(self.flowReceiver.borrow() != nil, message: "Missing or mis-typed FLOW receiver")

        if !account.getCapability<&Momentables.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(MomentablesCollectionProviderPrivatePath)!.check() {
            account.link<&Momentables.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(MomentablesCollectionProviderPrivatePath, target: /storage/MomentablesCollection)
        }

        self.MomentablesProvider = account.getCapability<&Momentables.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(MomentablesCollectionProviderPrivatePath)!

        assert(self.MomentablesProvider.borrow() != nil, message: "Missing or mis-typed Momentables.Collection provider")

        self.storefront = getOrCreateStorefront(account: account)
    }

    execute {
        let saleCut = NFTStorefront.SaleCut(
            receiver: self.flowReceiver,
            amount: saleItemPrice
        )
        self.storefront.createListing(
            nftProviderCapability: self.MomentablesProvider,
            nftType: Type<@Momentables.NFT>(),
            nftID: saleItemID,
            salePaymentVaultType: Type<@FlowToken.Vault>(),
            saleCuts: [saleCut]
        )
    }
}