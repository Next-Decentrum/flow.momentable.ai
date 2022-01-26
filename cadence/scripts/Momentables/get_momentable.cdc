import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import Momentables from "../../contracts/Momentables.cdc"
import MetadataViews from "../../contracts/MetadataViews.cdc"

pub struct AccountItem {

  pub let name: String
  pub let description: String
  pub let thumbnail: String
  pub let traits: {String: {String:String}}?

  pub let itemID: UInt64
  pub let momentableId: String
  pub let resourceID: UInt64
  pub let owner: Address



  init(
    name: String,
    description: String,
    thumbnail: String,
    traits: {String: {String:String}}?,
    itemID: UInt64, 
    momentableId: String, 
    resourceID: UInt64, 
    owner: Address) {
    self.name = name
    self.description = description
    self.thumbnail = thumbnail
    self.traits = traits
    self.itemID = itemID
    self.momentableId = momentableId
    self.resourceID = resourceID
    self.owner = owner
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

pub fun main(address: Address, itemID: UInt64): AnyStruct {

  var accountItem: AnyStruct = {}

  if let collection = getAccount(address).getCapability<&Momentables.Collection{NonFungibleToken.CollectionPublic, Momentables.MomentablesCollectionPublic}>(Momentables.CollectionPublicPath).borrow() {
    if let item = collection.borrowMomentables(id: itemID) {

       if let view =  item.resolveView(Type<MetadataViews.DisplayView>()) {
         let displayView = view as! MetadataViews.DisplayView
         let owner: Address = item.owner!.address!
         let ipfsThumbnail = displayView.thumbnail as! MetadataViews.IPFSFile
         
         if let view = item.resolveView(Type<MetadataViews.RarityView>()) {
          var rarityView: MetadataViews.RarityView = view as! MetadataViews.RarityView
        
          return AccountItem(
                    name: displayView.name,
                    description: displayView.description,
                    thumbnail: dwebURL(ipfsThumbnail),
                    traits:rarityView.traits,
                    itemID: itemID,
                    momentableId: item.momentableId, 
                    resourceID: item.uuid,
                    owner: address,
                ) 
          
         }

         return AccountItem(
                    name: displayView.name,
                    description: displayView.description,
                    thumbnail: dwebURL(ipfsThumbnail),
                    traits:{},
                    itemID: itemID,
                    momentableId: item.momentableId, 
                    resourceID: item.uuid,
                    owner: address,
                ) 
       }

      //return {itemID: itemID, momentableId: item.momentableId, resourceID: item.uuid, owner: address}
      return AccountItem
    }
  }

  return nil
}