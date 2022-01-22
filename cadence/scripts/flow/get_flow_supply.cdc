import FlowToken from "../../contracts/standard/FlowToken.cdc"

pub fun main(): UFix64 {
    let supply = FlowToken.totalSupply
    return supply
}