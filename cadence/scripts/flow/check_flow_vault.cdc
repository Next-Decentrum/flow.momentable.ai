import FungibleToken from "../../contracts/standard/FungibleToken.cdc"
import FlowToken from "../../contracts/standard/FlowToken.cdc"

pub fun main(address: Address): Bool {
  let vaultRef = getAccount(address).getCapability<&FlowToken.Vault{FungibleToken.Balance}>(/public/flowTokenVault).check()
  return vaultRef
}