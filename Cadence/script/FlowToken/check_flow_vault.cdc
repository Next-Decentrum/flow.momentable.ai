import FungibleToken from 0x9a0766d93b6608b7
import FlowToken from 0x7e60df042a9c0868

pub fun main(address: Address): Bool {
  let vaultRef = getAccount(address).getCapability<&FlowToken.Vault{FungibleToken.Balance}>(/public/flowTokenVault).check()
  return vaultRef
}