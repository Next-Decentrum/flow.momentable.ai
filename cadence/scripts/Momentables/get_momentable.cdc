import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import Momentables from "../../contracts/Momentables.cdc"

pub struct AccountItem {
  pub let itemID: UInt64
  pub let momentableId: String
  pub let resourceID: UInt64
  pub let owner: Address

  init(itemID: UInt64, momentableId: String, resourceID: UInt64, owner: Address) {
    self.itemID = itemID
    self.momentableId = momentableId
    self.resourceID = resourceID
    self.owner = owner
  }
}

pub fun main(address: Address, itemID: UInt64): AnyStruct {
  if let collection = getAccount(address).getCapability<&Momentables.Collection{NonFungibleToken.CollectionPublic, Momentables.MomentablesCollectionPublic}>(Momentables.CollectionPublicPath).borrow() {
    if let item = collection.borrowMomentables(id: itemID) {
      //return {itemID: itemID, momentableId: item.momentableId, resourceID: item.uuid, owner: address}
      return item
    }
  }

  return nil
}

// pub fun main(address: Address, itemID: UInt64): UInt64 {

//     // get the public account object for the token owner
//     let owner = getAccount(address)

//     let collectionBorrow = owner.getCapability(Momentables.CollectionPublicPath)
//         .borrow<&{Momentables.MomentablesCollectionPublic}>()
//         ?? panic("Could not borrow MomentablesCollectionPublic")

//     // borrow a reference to a specific NFT in the collection
//     let Momentable = collectionBorrow.borrowMomentables(id: itemID)
//         ?? panic("No such itemID in that collection")

//     return Momentable.momentableId
// }


