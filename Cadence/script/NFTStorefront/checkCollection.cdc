import NFTStorefront from 0x94b06cfca1d8a476
  
pub fun main(addr: Address): Bool {
    let ref = getAccount(addr).getCapability<&{NFTStorefront.NFTStorefront.StorefrontPublic}>(NFTStorefront.StorefrontPublicPath).check()
    return ref
}