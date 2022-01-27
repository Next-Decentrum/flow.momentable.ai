import path from 'path';

import {
  emulator,
  init,
  getAccountAddress,
  shallPass,
  shallResolve,
  shallRevert,
} from 'flow-js-testing';

import { getMomentablesAdminAddress } from '../src/common';
import {
  deployMomentables,
  getMomentableCount,
  getMomentablesupply,
  mintMomentable,
  setupMomentablesOnAccount,
  transferMomentable,
} from '../src/Momentables';
import { arg } from '@onflow/fcl';
import * as t from '@onflow/types';

// We need to set timeout for a higher number, because some transactions might take up some time
jest.setTimeout(50000);

let mintArgs = {
  recepient: '0x01',
  momentableId: '61d8a32f26beea70ef4ad832',
  momentableName: 'Edjo',
  description:
    'Each crypto pharaoh is cryptographically unique, programmatically brought to life, endowed with a rare combination of sacred backgrounds, majestic costumes, power neckpieces, healing accessories, magical staffs, immortal tattoos and much more. All Crypto Pharaohs are remarkable, magical, and powerful.Some are rarer than other',
  imageCID: 'QmU351M14k5n5VszC6KXmqMVDnPH8BRWwhW6Suur9bwhtw',
  traits: {
    'Divine Skin Tone': {
      rarity: '4.61%',
      name: 'Brown',
      primaryPower: 'Constitution 3d8',
      secondaryPower: 'Strength 3d6',
      additionalData: 'Nobility',
    },
  },
  creatorName: 'Creator-1',
  creatorAddress: '0x01cf0e2f2f715450',
  creatorRoyalty: 2.0,
  collaboratorNames: ['Collab-1', 'Collab-2'],
  collaboratorAddresses: [0x01, 0x02],
  collaboratorRoyalties: [1.2, 2.4],
};

describe('Momentables', () => {
  // Instantiate emulator and path to Cadence files 0x01cf0e2f2f715450
  beforeEach(async () => {
    const basePath = path.resolve(__dirname, '../../');
    const port = 8080;
    await init(basePath, { port });
    await emulator.start(port, false);
    return await new Promise((r) => setTimeout(r, 1000));
  });

  // Stop emulator, so it could be restarted
  afterEach(async () => {
    await emulator.stop();
    return await new Promise((r) => setTimeout(r, 1000));
  });

  it('should deploy Momentables contract', async () => {
    await deployMomentables();
  });

  it('supply should be 0 after contract is deployed', async () => {
    // Setup
    await deployMomentables();
    const MomentablesAdmin = await getMomentablesAdminAddress();

    await shallPass(setupMomentablesOnAccount(MomentablesAdmin));

    await shallResolve(async () => {
      const supply = await getMomentablesupply();
      expect(supply[0]).toBe(0);
    });
  });

  it('should be able to mint a Momentable', async () => {
    // Setup
    await deployMomentables();
    const MomentablesAdmin = await getMomentablesAdminAddress();

    const Alice = await getAccountAddress('Alice');
    await setupMomentablesOnAccount(Alice);

    const Bob = await getAccountAddress('Bob');
    await setupMomentablesOnAccount(Bob);

    // Mint instruction for Alice account shall be resolved

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
      'Power Tattoo': {
        rarity: '4.01%',
        name: 'Warriors Scabbard',
        primaryPower: 'Strength 3d8',
        secondaryPower: 'Constitution 2d4',
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
  });

  it('should be able to create a new empty NFT Collection', async () => {
    // Setup
    await deployMomentables();
    const Alice = await getAccountAddress('Alice');
    await setupMomentablesOnAccount(Alice);

    // shall be able te read Alice collection and ensure it's empty
    await shallResolve(async () => {
      const itemCount = await getMomentableCount(Alice);
      expect(itemCount[0]).toBe(0);
    });
  });

  it("should not be able to withdraw an NFT that doesn't exist in a collection", async () => {
    // Setup
    await deployMomentables();
    const Alice = await getAccountAddress('Alice');
    const Bob = await getAccountAddress('Bob');
    await setupMomentablesOnAccount(Alice);
    await setupMomentablesOnAccount(Bob);

    // Transfer transaction shall fail for non-existent item
    await shallRevert(transferMomentable(Alice, Bob, 1337));
  });

  it('should be able to withdraw an NFT and deposit to another accounts collection', async () => {
    await deployMomentables();
    const MomentablesAdmin = await getMomentablesAdminAddress();

    const Alice = await getAccountAddress('Alice');
    const Bob = await getAccountAddress('Bob');
    await setupMomentablesOnAccount(Alice);
    await setupMomentablesOnAccount(Bob);

    // Mint instruction for Alice account shall be resolved
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

    // Transfer transaction shall pass
    await shallPass(transferMomentable(Alice, Bob, 0));
  });
});
