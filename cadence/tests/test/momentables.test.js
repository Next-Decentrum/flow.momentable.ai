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

// We need to set timeout for a higher number, because some transactions might take up some time
jest.setTimeout(50000);

const mintArgs = {
  recepient: 0xf8d6e0586b0a20c7,
  momentableId: '61d8a32f26beea70ef4ad832',
  name: 'Edjo',
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
  // Instantiate emulator and path to Cadence files
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
    const MomentableAdmin = await getMomentablesAdminAddress();
    await shallPass(setupMomentablesOnAccount(MomentableAdmin));

    await shallResolve(async () => {
      const supply = await getMomentablesupply();
      expect(supply).toBe(0);
    });
  });

  it('should be able to mint a Momentable', async () => {
    // Setup
    await deployMomentables();
    const Alice = await getAccountAddress('Alice');
    await setupMomentablesOnAccount(Alice);

    // Mint instruction for Alice account shall be resolved

    const recepient = 0xf8d6e0586b0a20c7;
    const momentableId = '61d8a32f26beea70ef4ad832';
    const name = 'Edjo';
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
    const creatorAddress = '0x01cf0e2f2f715450';
    const creatorRoyalty = 2.0;
    const collaboratorNames = ['Collab-1', 'Collab-2'];
    const collaboratorAddresses = [0x01, 0x02];
    const collaboratorRoyalties = [1.2, 2.4];

    await shallPass(mintMomentable(mintArgs)); //Update with actual params
  });

  it('should be able to create a new empty NFT Collection', async () => {
    // Setup
    await deployMomentables();
    const Alice = await getAccountAddress('Alice');
    await setupMomentablesOnAccount(Alice);

    // shall be able te read Alice collection and ensure it's empty
    await shallResolve(async () => {
      const itemCount = await getMomentableCount(Alice);
      expect(itemCount).toBe(0);
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
    const Alice = await getAccountAddress('Alice');
    const Bob = await getAccountAddress('Bob');
    await setupMomentablesOnAccount(Alice);
    await setupMomentablesOnAccount(Bob);

    // Mint instruction for Alice account shall be resolved
    await shallPass(mintMomentable(mintArgs));

    // Transfer transaction shall pass
    await shallPass(transferMomentable(Alice, Bob, 0));
  });
});
