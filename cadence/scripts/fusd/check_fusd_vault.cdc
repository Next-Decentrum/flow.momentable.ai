import FungibleToken from "../../contracts/standard/FungibleToken.cdc"
import FUSD from "../../contracts/standard/FUSD.cdc"

pub fun main(address: Address): Bool {
  let vaultRef = getAccount(address).getCapability<&FUSD.Vault{FungibleToken.Balance}>(/public/FUSDVault).check()
  return vaultRef
}