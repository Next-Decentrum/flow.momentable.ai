import Momentables from 0xbbd7a5e25771f977
  
  pub fun main(addr: Address): Bool {
    let ref = getAccount(addr).getCapability<&{Momentables.MomentablesCollectionPublic}>(Momentables.CollectionPublicPath).check()
    return ref
  }