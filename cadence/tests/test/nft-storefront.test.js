import path from 'path';

import {
  emulator,
  init,
  getAccountAddress,
  shallPass,
  mintFlow,
} from 'flow-js-testing';

import { toUFix64 } from '../src/common';
import { getMomentablesAdminAddress } from '../src/common';
import {
  getMomentableCount,
  mintMomentable,
  getMomentable,
  setupMomentablesOnAccount,
} from '../src/Momentables';
import {
  deployNFTStorefront,
  createListing,
  purchaseListing,
  removeListing,
  setupStorefrontOnAccount,
  getListingCount,
} from '../src/nft-storefront';

// We need to set timeout for a higher number, because some transactions might take up some time
jest.setTimeout(500000);

describe('NFT Storefront', () => {
  beforeEach(async () => {
    const basePath = path.resolve(__dirname, '../../');
    const port = 7003;
    await init(basePath, { port });
    await emulator.start(port, false);
    return await new Promise((r) => setTimeout(r, 1000));
  });

  // Stop emulator, so it could be restarted
  afterEach(async () => {
    await emulator.stop();
    return await new Promise((r) => setTimeout(r, 1000));
  });

  it('should deploy NFTStorefront contract', async () => {
    await shallPass(deployNFTStorefront());
  });

  it('should be able to create an empty Storefront', async () => {
    // Setup
    await deployNFTStorefront();
    const Alice = await getAccountAddress('Alice');

    await shallPass(setupStorefrontOnAccount(Alice));
  });

  it('should be able to create a listing', async () => {
    // Setup
    await deployNFTStorefront();

    const MomentablesAdmin = await getMomentablesAdminAddress();

    const Alice = await getAccountAddress('Alice');
    const Bob = await getAccountAddress('Bob');
    await setupStorefrontOnAccount(Alice);

    // Mint Momentable for Alice's account (Creator=Admin, Recepient=Alice and Collaborator=Bob)
    await setupMomentablesOnAccount(Alice);
    await setupMomentablesOnAccount(Bob);

    const recepient = Alice;
    const momentableId = '61d8a32f26beea70ef4ad832';
    const momentableName = 'Edjo';
    const description =
      'Each crypto pharaoh is cryptographically unique, programmatically brought to life, endowed with a rare combination of sacred backgrounds, majestic costumes, power neckpieces, healing accessories, magical staffs, immortal tattoos and much more. All Crypto Pharaohs are remarkable, magical, and powerful.Some are rarer than other';
    const imageCID = 'QmU351M14k5n5VszC6KXmqMVDnPH8BRWwhW6Suur9bwhtw';
    const traits = {
      'Divine Skin Tone': {
        rarity: '4.61%',
        name: 'Brown',
        primaryPower: 'Constitution 3d8',
        secondaryPower: 'Strength 3d6',
        additionalData: 'Nobility',
      },
    };
    const creatorName = 'Creator-1';
    const creatorAddress = MomentablesAdmin;
    const creatorRoyalty = 2.0;
    const collaboratorNames = ['Collab-1'];
    const collaboratorAddresses = [Bob];
    const collaboratorRoyalties = [2.4];

    await shallPass(
      mintMomentable(
        recepient,
        momentableId,
        momentableName,
        description,
        imageCID,
        traits,
        creatorName,
        creatorAddress,
        creatorRoyalty,
        collaboratorNames,
        collaboratorAddresses,
        collaboratorRoyalties
      )
    );

    const itemID = 0;

    await shallPass(createListing(Alice, itemID, toUFix64(1.11)));
  });

  it('should be able to accept a listing', async () => {
    // Setup
    await deployNFTStorefront();

    // Setup seller account
    const MomentablesAdmin = await getMomentablesAdminAddress();

    const Alice = await getAccountAddress('Alice');
    const Bob = await getAccountAddress('Bob');
    await setupStorefrontOnAccount(Alice);

    // Mint Momentable for Alice's account (Creator=Admin, Recepient=Alice and Collaborator=Bob)
    await setupMomentablesOnAccount(Alice);
    await setupMomentablesOnAccount(Bob);

    const recepient = Alice;
    const momentableId = '61d8a32f26beea70ef4ad832';
    const momentableName = 'Edjo';
    const description =
      'Each crypto pharaoh is cryptographically unique, programmatically brought to life, endowed with a rare combination of sacred backgrounds, majestic costumes, power neckpieces, healing accessories, magical staffs, immortal tattoos and much more. All Crypto Pharaohs are remarkable, magical, and powerful.Some are rarer than other';
    const imageCID = 'QmU351M14k5n5VszC6KXmqMVDnPH8BRWwhW6Suur9bwhtw';
    const traits = {
      'Divine Skin Tone': {
        rarity: '4.61%',
        name: 'Brown',
        primaryPower: 'Constitution 3d8',
        secondaryPower: 'Strength 3d6',
        additionalData: 'Nobility',
      },
    };
    const creatorName = 'Creator-1';
    const creatorAddress = MomentablesAdmin;
    const creatorRoyalty = 2.0;
    const collaboratorNames = ['Collab-1'];
    const collaboratorAddresses = [Bob];
    const collaboratorRoyalties = [2.4];

    await shallPass(
      mintMomentable(
        recepient,
        momentableId,
        momentableName,
        description,
        imageCID,
        traits,
        creatorName,
        creatorAddress,
        creatorRoyalty,
        collaboratorNames,
        collaboratorAddresses,
        collaboratorRoyalties
      )
    );

    const itemId = 0;

    // Setup buyer account
    const John = await getAccountAddress('John');
    await setupStorefrontOnAccount(John);

    await shallPass(mintFlow(John, toUFix64(100)));

    // John shall be able to buy from Alice
    const sellItemTransactionResult = await shallPass(
      createListing(Alice, itemId, toUFix64(1.11))
    );

    const listingAvailableEvent = sellItemTransactionResult.events[0];
    const listingResourceID = listingAvailableEvent.data.listingResourceID;

    await shallPass(purchaseListing(John, listingResourceID, Alice));

    const itemCount = await getMomentableCount(John);
    expect(itemCount[0]).toBe(1);

    const listingCount = await getListingCount(Alice);
    expect(listingCount).toBe(0);
  });

  it('should be able to remove a listing', async () => {
    // Deploy contracts
    await shallPass(deployNFTStorefront());

    // Setup Alice account
    const Alice = await getAccountAddress('Alice');
    await shallPass(setupStorefrontOnAccount(Alice));

    const MomentablesAdmin = await getMomentablesAdminAddress();

    // Mint Momentable for Alice's account (Creator=Admin, Recepient=Alice and Collaborator=Bob)
    const Bob = await getAccountAddress('Bob');
    await setupMomentablesOnAccount(Alice);
    await setupMomentablesOnAccount(Bob);

    const recepient = Alice;
    const momentableId = '61d8a32f26beea70ef4ad832';
    const momentableName = 'Edjo';
    const description =
      'Each crypto pharaoh is cryptographically unique, programmatically brought to life, endowed with a rare combination of sacred backgrounds, majestic costumes, power neckpieces, healing accessories, magical staffs, immortal tattoos and much more. All Crypto Pharaohs are remarkable, magical, and powerful.Some are rarer than other';
    const imageCID = 'QmU351M14k5n5VszC6KXmqMVDnPH8BRWwhW6Suur9bwhtw';
    const traits = {
      'Divine Skin Tone': {
        rarity: '4.61%',
        name: 'Brown',
        primaryPower: 'Constitution 3d8',
        secondaryPower: 'Strength 3d6',
        additionalData: 'Nobility',
      },
    };
    const creatorName = 'Creator-1';
    const creatorAddress = MomentablesAdmin;
    const creatorRoyalty = 2.0;
    const collaboratorNames = ['Collab-1'];
    const collaboratorAddresses = [Bob];
    const collaboratorRoyalties = [2.4];

    await shallPass(
      mintMomentable(
        recepient,
        momentableId,
        momentableName,
        description,
        imageCID,
        traits,
        creatorName,
        creatorAddress,
        creatorRoyalty,
        collaboratorNames,
        collaboratorAddresses,
        collaboratorRoyalties
      )
    );

    const itemId = 0;

    await getMomentable(Alice, itemId);

    // Listing item for sale shall pass
    const sellItemTransactionResult = await shallPass(
      createListing(Alice, itemId, toUFix64(1.11))
    );

    const listingAvailableEvent = sellItemTransactionResult.events[0];
    const listingResourceID = listingAvailableEvent.data.listingResourceID;

    // Alice shall be able to remove item from sale
    await shallPass(removeListing(Alice, listingResourceID));

    const listingCount = await getListingCount(Alice);
    expect(listingCount).toBe(0);
  });
});
