import NonFungibleToken from 0x631e88ae7f1d7c20

// MomentablesV2
// NFT items for MomentablesV2!
//
pub contract MomentablesV2: NonFungibleToken {

    // Events
    //
    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)
    pub event Minted(id: UInt64, momentableId: String)

    // Named Paths
    //
    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath
    pub let MinterStoragePath: StoragePath

    // totalSupply
    // The total number of MomentablesV2 that have been minted
    //
    pub var totalSupply: UInt64

    // NFT
    // A Momentable Item as an NFT
    //

    pub struct Royalty {
        pub let receiverAddress: Address
        pub var value: UFix64

        init(receiverAddress:Address, value:UFix64) {
            self.receiverAddress = receiverAddress
            self.value = value
        }
    }

    pub struct Creator {
        pub let creatorName: String
        pub let royalty: Royalty

        init(creatorName: String, royalty:Royalty){
         self.creatorName = creatorName
         self.royalty = royalty
        }

    }

    pub struct Collaborator{
        pub let collaboratorName: String
        pub let royalty: Royalty

        init(collaboratorName: String, royalty: Royalty){
          self.collaboratorName = collaboratorName
          self.royalty = royalty
        }
    }


    pub resource NFT: NonFungibleToken.INFT {
        // The token's ID
        pub let id: UInt64
        // The token's type, e.g. 3 == Hat
        pub let momentableId: String
        // The token's metadata
        pub let metadata: {String : AnyStruct}

        pub let creator: Creator

        // The royality associated with NFTs
        pub let collaborators : [Collaborator]
        // initializer
        //
        init(initID: UInt64, initMomentableId: String, metadata:{String : AnyStruct},creator:Creator, collaborators:[Collaborator]) {
            self.id = initID
            self.momentableId = initMomentableId
            self.metadata = metadata
            self.creator = creator
            self.collaborators = collaborators
        }
    }

    // This is the interface that users can cast their MomentablesV2 Collection as
    // to allow others to deposit MomentablesV2 into their Collection. It also allows for reading
    // the details of MomentablesV2 in the Collection.
    pub resource interface MomentablesV2CollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowMomentablesV2(id: UInt64): &MomentablesV2.NFT? {
            // If the result isn't nil, the id of the returned reference
            // should be the same as the argument to the function
            post {
                (result == nil) || (result?.id == id):
                    "Cannot borrow MomentablesV2 reference: The ID of the returned reference is incorrect"
            }
        }
    }

    // Collection
    // A collection of MomentablesV2 NFTs owned by an account
    //
    pub resource Collection: MomentablesV2CollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
        // dictionary of NFT conforming tokens
        // NFT is a resource type with an `UInt64` ID field
        //
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        // withdraw
        // Removes an NFT from the collection and moves it to the caller
        //
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <-token
        }

        // deposit
        // Takes a NFT and adds it to the collections dictionary
        // and adds the ID to the id array
        //
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @MomentablesV2.NFT

            let id: UInt64 = token.id

            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[id] <- token

            emit Deposit(id: id, to: self.owner?.address)

            destroy oldToken
        }

        // getIDs
        // Returns an array of the IDs that are in the collection
        //
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        // borrowNFT
        // Gets a reference to an NFT in the collection
        // so that the caller can read its metadata and call its methods
        //
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        // borrowMomentablesV2
        // Gets a reference to an NFT in the collection as a Momentable,
        // exposing all of its fields (including the momentableId).
        // This is safe as there are no functions that can be called on the MomentablesV2.
        //
        pub fun borrowMomentablesV2(id: UInt64): &MomentablesV2.NFT? {
            if self.ownedNFTs[id] != nil {
                let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
                return ref as! &MomentablesV2.NFT
            } else {
                return nil
            }
        }

        // destructor
        destroy() {
            destroy self.ownedNFTs
        }

        // initializer
        //
        init () {
            self.ownedNFTs <- {}
        }
    }

    // createEmptyCollection
    // public function that anyone can call to create a new empty collection
    //
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create Collection()
    }

    // NFTMinter
    // Resource that an admin or something similar would own to be
    // able to mint new NFTs
    //
	pub resource NFTMinter {

		// mintNFT
        // Mints a new NFT with a new ID
		// and deposit it in the recipients collection using their collection reference
        //
		pub fun mintNFT(recipient: &{NonFungibleToken.CollectionPublic}, momentableId: String, metadata:{String:AnyStruct}, creator:Creator, collaborators:[Collaborator]) {
            emit Minted(id: MomentablesV2.totalSupply, momentableId: momentableId)

			// deposit it in the recipient's account using their reference
			recipient.deposit(token: <-create MomentablesV2.NFT(initID: MomentablesV2.totalSupply, initMomentableId: momentableId, metadata: metadata,creator: creator, collaborators:collaborators))

            MomentablesV2.totalSupply = MomentablesV2.totalSupply + (1 as UInt64)
		}
	}

    // fetch
    // Get a reference to a MomentablesV2 from an account's Collection, if available.
    // If an account does not have a MomentablesV2.Collection, panic.
    // If it has a collection but does not contain the itemID, return nil.
    // If it has a collection and that collection contains the itemID, return a reference to that.
    //
    pub fun fetch(_ from: Address, itemID: UInt64): &MomentablesV2.NFT? {
        let collection = getAccount(from)
            .getCapability(/public/MomentablesV2Collection)
            .borrow<&MomentablesV2.Collection{MomentablesV2.MomentablesV2CollectionPublic}>()
            ?? panic("Couldn't get collection")
        // We trust MomentablesV2.Collection.borowMomentablesV2 to get the correct itemID
        // (it checks it before returning it).
        return collection.borrowMomentablesV2(id: itemID)
    }

    // initializer
    //
	init() {
        // Set our named paths
        self.CollectionStoragePath = /storage/MomentablesV2Collectionss
        self.CollectionPublicPath = /public/MomentablesV2Collectionss
        self.MinterStoragePath = /storage/MomentablesV2Minterss

        // Initialize the total supply
        self.totalSupply = 0

        // Create a Minter resource and save it to storage
        let minter <- create NFTMinter()
        self.account.save(<-minter, to: /storage/MomentablesV2Minter)

        emit ContractInitialized()
	}
}
 