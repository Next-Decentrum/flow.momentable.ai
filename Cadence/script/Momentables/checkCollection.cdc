import Momentables from 0xa5bb5acbf4dd8848
  
  pub fun main(addr: Address): Bool {
    let ref = getAccount(addr).getCapability<&{Momentables.MomentablesCollectionPublic}>(/public/MomentablesCollection).check()
    return ref
  }