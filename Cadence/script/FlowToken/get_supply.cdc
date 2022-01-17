import FlowToken from 0x7e60df042a9c0868

pub fun main(): UFix64 {
    let supply = FlowToken.totalSupply
    return supply
}