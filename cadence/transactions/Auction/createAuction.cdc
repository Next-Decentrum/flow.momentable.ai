import Auction from "../../contracts/Auction.cdc"

transaction(
 startTime: UFix64, 
 duration: UFix64, 
 startingPrice: UFix64, 
 bidStep: UFix64, 
 nftCollection: @Momentables.Collection
 ) {
    
    // local variable for storing the Auction Collection reference
    let auction: &Auction.AuctionCollection

    prepare(signer: AuthAccount) {

        // borrow a reference to the Auction Collection resource in storage
        self.auction = signer.borrow<&Momentables.AuctionCollection>(from: Auction.AuctionCollectionStoragePath)
            ?? panic("Could not borrow a reference to the Auction Collection")
    }

    execute {

        // create an auction 
        self.auction.createAuction(
            startTime: startTime, 
            duration: duration, 
            startingPrice: startingPrice, 
            bidStep: bidStep, 
            nftCollection: nftCollection)
    }
}