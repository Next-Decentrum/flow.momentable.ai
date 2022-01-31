import FUSD from "../../contracts/FUSD.cdc"

pub fun main(): UFix64 {
    let supply = FUSD.totalSupply
    return supply
}