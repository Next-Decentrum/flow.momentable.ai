import Momentables from "../../contracts/Momentables.cdc"

// This scripts returns the number of Momentables currently in existence.

pub fun main(): UInt64 {    
    return Momentables.totalSupply
}
