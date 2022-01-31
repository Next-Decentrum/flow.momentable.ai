import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import MetadataViews from "../../contracts/MetadataViews.cdc"
import NFTStorefront from "../../contracts/NFTStorefront.cdc"
import Momentables from "../../contracts/Momentables.cdc"

pub struct ListingItem {
  pub let name: String
  pub let description: String
  pub let thumbnail: String
  pub let traits: {String: {String:String}}?

  pub let itemID: UInt64
  pub let momentableId: String
  pub let resourceID: UInt64
  pub let owner: Address
  pub let creatorName: String
  pub let creatorAddress: Address


  init(
    name: String,
    description: String,
    thumbnail: String,
    traits: {String: {String:String}}?,
    itemID: UInt64, 
    momentableId: String, 
    resourceID: UInt64, 
    owner: Address,
    creatorName: String,
    creatorAddress: Address) {
    self.name = name
    self.description = description
    self.thumbnail = thumbnail
    self.traits = traits
    self.itemID = itemID
    self.momentableId = momentableId
    self.resourceID = resourceID
    self.owner = owner
    self.creatorName = creatorName
    self.creatorAddress = creatorAddress
  }
}

pub fun dwebURL(_ file: MetadataViews.IPFSFile): String {
    var url = "https://gateway.pinata.cloud/ipfs/"
        .concat(file.cid)
    
    if let path = file.path {
        return url.concat(path)
    }
    
    return url
}

pub fun main(address: Address, listingResourceID: UInt64): ListingItem? {
    let account = getAccount(address)

    if let storefrontRef = account.getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(NFTStorefront.StorefrontPublicPath).borrow() {

        if let listing = storefrontRef.borrowListing(listingResourceID: listingResourceID) {
            
            let details = listing.getDetails()

            let itemID = details.nftID
            let itemPrice = details.salePrice
        
            if let collection = getAccount(address).getCapability<&Momentables.Collection{NonFungibleToken.CollectionPublic, Momentables.MomentablesCollectionPublic}>(Momentables.CollectionPublicPath).borrow() {
                if let item = collection.borrowMomentables(id: itemID) {
                if let view =  item.resolveView(Type<MetadataViews.Display>()) {
                    let displayView = view as! MetadataViews.Display
                    let owner: Address = item.owner!.address!
                    let ipfsThumbnail = displayView.thumbnail as! MetadataViews.IPFSFile
                    
                    if let view = item.resolveView(Type<Momentables.RarityView>()) {
                    var rarityView = view as! Momentables.RarityView
                    
                    return ListingItem(
                                name: displayView.name,
                                description: displayView.description,
                                thumbnail: dwebURL(ipfsThumbnail),
                                traits:rarityView.traits,
                                itemID: itemID,
                                momentableId: item.momentableId, 
                                resourceID: item.uuid,
                                owner: address,
                                creatorName: item.getCreator().creatorName,
                                creatorAddress: item.getCreator().creatorWallet.address
                            ) 
                    
                    }

                    return ListingItem(
                                name: displayView.name,
                                description: displayView.description,
                                thumbnail: dwebURL(ipfsThumbnail),
                                traits:{},
                                itemID: itemID,
                                momentableId: item.momentableId, 
                                resourceID: item.uuid,
                                owner: address,
                                creatorName: item.getCreator().creatorName,
                                creatorAddress: item.getCreator().creatorWallet.address
                            ) 
                }

                //return {itemID: itemID, momentableId: item.momentableId, resourceID: item.uuid, owner: address}
                }
            }
        }
    }

    return nil
}