import NonFungibleToken from "./standard/NonFungibleToken.cdc"

// Momentables
// NFT items for Momentables!
//
pub contract Momentables: NonFungibleToken {

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
    // The total number of Momentables that have been minted
    //
    pub var totalSupply: UInt64


    pub struct Creator{
        pub let creatorName: String
        pub let creatorAddress: Address
        pub let creatorRoyalty: UFix64

        init(creatorName: String, creatorAddress: Address, creatorRoyalty: UFix64){
            self.creatorName = creatorName
            self.creatorAddress = creatorAddress
            self.creatorRoyalty = creatorRoyalty
        }
    }

      pub struct Collaborator{
        pub let collaboratorName: String
        pub let collaboratorAddress: Address
        pub let collaboratorRoyalty: UFix64

        init(collaboratorName: String, collaboratorAddress: Address, collaboratorRoyalty: UFix64){
            self.collaboratorName = collaboratorName
            self.collaboratorAddress = collaboratorAddress
            self.collaboratorRoyalty = collaboratorRoyalty
        }
    }

    // NFT
    // A Momentable Item as an NFT
    //
    pub resource NFT: NonFungibleToken.INFT {
        // The token's ID
        pub let id: UInt64
        // The token's type, e.g. 3 == Hat
        pub let momentableId: String

        pub let metadata: {String: String}

        pub let creator: Creator

        pub let collaborators: [Collaborator]

        // initializer
        //
        init(initID: UInt64, initMomentableId: String, metadata: {String: String}, creator: Creator, collaborators: [Collaborator]) {
            self.id = initID
            self.momentableId = initMomentableId
            self.metadata = metadata
            self.creator = creator
            self.collaborators = collaborators
        }
    }

    // This is the interface that users can cast their Momentables Collection as
    // to allow others to deposit Momentables into their Collection. It also allows for reading
    // the details of Momentables in the Collection.
    pub resource interface MomentablesCollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowMomentables(id: UInt64): &Momentables.NFT? {
            // If the result isn't nil, the id of the returned reference
            // should be the same as the argument to the function
            post {
                (result == nil) || (result?.id == id):
                    "Cannot borrow Momentables reference: The ID of the returned reference is incorrect"
            }
        }
    }

    // Collection
    // A collection of Momentables NFTs owned by an account
    //
    pub resource Collection: MomentablesCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
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
            let token <- token as! @Momentables.NFT

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

        // borrowMomentables
        // Gets a reference to an NFT in the collection as a Momentable,
        // exposing all of its fields (including the momentableId).
        // This is safe as there are no functions that can be called on the Momentables.
        //
        pub fun borrowMomentables(id: UInt64): &Momentables.NFT? {
            if self.ownedNFTs[id] != nil {
                let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
                return ref as! &Momentables.NFT
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
		pub fun mintNFT(recipient: &{NonFungibleToken.CollectionPublic}, momentableId: String, metadata: {String: String}, creator: Creator, collaborators: [Collaborator]) {
            emit Minted(id: Momentables.totalSupply, momentableId: momentableId)

			// deposit it in the recipient's account using their reference
			recipient.deposit(token: <-create Momentables.NFT(initID: Momentables.totalSupply, initMomentableId: momentableId, metadata: metadata, creator: creator, collaborators: collaborators))

            Momentables.totalSupply = Momentables.totalSupply + (1 as UInt64)
		}
	}

    // fetch
    // Get a reference to a Momentables from an account's Collection, if available.
    // If an account does not have a Momentables.Collection, panic.
    // If it has a collection but does not contain the itemID, return nil.
    // If it has a collection and that collection contains the itemID, return a reference to that.
    //
    pub fun fetch(_ from: Address, itemID: UInt64): &Momentables.NFT? {
        let collection = getAccount(from)
            .getCapability(Momentables.CollectionPublicPath)
            .borrow<&Momentables.Collection{Momentables.MomentablesCollectionPublic}>()
            ?? panic("Couldn't get collection")
        // We trust Momentables.Collection.borowMomentables to get the correct itemID
        // (it checks it before returning it).
        return collection.borrowMomentables(id: itemID)
    }

    // initializer
    //
	init() {
        // Set our named paths
        self.CollectionStoragePath = /storage/MomentablesCollection
        self.CollectionPublicPath = /public/MomentablesCollection
        self.MinterStoragePath = /storage/MomentablesMinter

        // Initialize the total supply
        self.totalSupply = 0

        // Create a Minter resource and save it to storage
        let minter <- create NFTMinter()
        self.account.save(<-minter, to: self.MinterStoragePath)

        emit ContractInitialized()
	}
}