import NonFungibleToken from 0x631e88ae7f1d7c20
import Momentables from 0xa5bb5acbf4dd8848

pub struct AccountItem {
  pub let itemID: UInt64
  pub let momentableId: String
  pub let metadata: String
  pub let owner: Address
  init(itemID: UInt64, momentableId: String, metadata: String, owner: Address) {
    self.itemID = itemID
    self.momentableId = momentableId
    self.metadata = metadata
    self.owner = owner
  }
}
pub fun fetch(address: Address, id: UInt64): AccountItem? {
  if let col = getAccount(address).getCapability<&Momentables.Collection{NonFungibleToken.CollectionPublic, Momentables.MomentablesCollectionPublic}>(/public/MomentablesCollection).borrow() {
    if let item = col.borrowMomentables(id: id) {
      return AccountItem(itemID: id, momentableId: item.momentableId, metadata: item.metadata, owner: address)
    }
  }
  return nil
}