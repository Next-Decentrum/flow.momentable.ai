import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import NFTStorefront from "../../contracts/NFTStorefront.cdc"
import Momentables from "../../contracts/Momentables.cdc"

pub struct SaleItem {
    pub let itemID: UInt64
    pub let momentableId: String
    pub let owner: Address
    pub let price: UFix64

    init(itemID: UInt64, momentableId: String, owner: Address, price: UFix64) {
        self.itemID = itemID
        self.momentableId = momentableId
        self.owner = owner
        self.price = price
    }
}

pub fun main(address: Address, saleOfferResourceID: UInt64): SaleItem? {
    let account = getAccount(address)

    if let storefrontRef = account.getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(NFTStorefront.StorefrontPublicPath).borrow() {
        if let saleOffer = storefrontRef.borrowSaleOffer(saleOfferResourceID: saleOfferResourceID) {
            let details = saleOffer.getDetails()

            let itemID = details.nftID
            let itemPrice = details.salePrice

            if let collection = account.getCapability<&Momentables.Collection{NonFungibleToken.CollectionPublic, Momentables.MomentablesCollectionPublic}>(Momentables.CollectionPublicPath).borrow() {
                if let item = collection.borrowMomentables(id: itemID) {
                    return SaleItem(itemID: itemID, momentableId: item.momentableId, owner: address, price: itemPrice)
                }
            }
        }
    }
        
    return nil
}
