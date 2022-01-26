import FungibleToken from "../../contracts/FungibleToken.cdc"
import FUSD from "../../contracts/FUSD.cdc"

pub fun main(address: Address): Bool {
  let vaultRef = getAccount(address).getCapability<&FUSD.Vault{FungibleToken.Balance}>(/public/FUSDVault).check()
  return vaultRef
}