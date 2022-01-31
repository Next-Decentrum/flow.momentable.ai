import {
  deployContractByName,
  executeScript,
  mintFlow,
  sendTransaction,
} from 'flow-js-testing';

import {
  getMomentablesAdminAddress,
  sendTransactionWithErrorRaised,
  deployContractByNameWithErrorRaised,
} from './common';

// Momentables types
export const momentableId = '61d8a32f26beea70ef4ad832';

/*
 * Deploys NonFungibleToken and Momentables contracts to MomentablesAdmin.
 * @throws Will throw an error if transaction is reverted.
 * @returns {Promise<*>}
 * */
export const deployMomentables = async () => {
  const MomentablesAdmin = await getMomentablesAdminAddress();
  await mintFlow(MomentablesAdmin, '10.0');

  await deployContractByNameWithErrorRaised({
    to: MomentablesAdmin,
    name: 'NonFungibleToken',
  });

  await deployContractByNameWithErrorRaised({
    to: MomentablesAdmin,
    name: 'MetadataViews',
  });

  const addressMap = {
    NonFungibleToken: MomentablesAdmin,
    MetadataViews: MomentablesAdmin,
  };

  return deployContractByNameWithErrorRaised({
    to: MomentablesAdmin,
    name: 'Momentables',
    addressMap,
  });
};

/*
 * Setups Momentables collection on account and exposes public capability.
 * @param {string} account - account address
 * @throws Will throw an error if transaction is reverted.
 * @returns {Promise<*>}
 * */
export const setupMomentablesOnAccount = async (account) => {
  const name = 'Momentables/setup_account';
  const signers = [account];

  return sendTransactionWithErrorRaised({ name, signers });
};

/*
 * Returns Momentables supply.
 * @throws Will throw an error if execution will be halted
 * @returns {UInt64} - number of NFT minted so far
 * */
export const getMomentablesupply = async () => {
  const name = 'Momentables/get_momentable_supply';

  return executeScript({ name });
};

/*
 * Mints Momentable of a specific **itemType** and sends it to **recipient**.
 * @param {UInt64} itemType - type of NFT to mint
 * @param {string} recipient - recipient account address
 * @throws Will throw an error if execution will be halted
 * @returns {Promise<*>}
 * */
export const mintMomentable = async (
  recipient,
  momentableId,
  momentableName,
  description,
  imageCID,
  directoryPath,
  traits,
  creatorName,
  creatorAddress,
  creatorRoyalty,
  collaboratorNames,
  collaboratorAddresses,
  collaboratorRoyalties,
  momentableCollectionDetails
) => {
  const MomentablesAdmin = await getMomentablesAdminAddress();

  const name = 'Momentables/mint_momentable';
  const args = [
    recipient,
    momentableId,
    momentableName,
    description,
    imageCID,
    directoryPath,
    traits,
    creatorName,
    creatorAddress,
    creatorRoyalty,
    collaboratorNames,
    collaboratorAddresses,
    collaboratorRoyalties,
    momentableCollectionDetails,
  ];
  const signers = [MomentablesAdmin];

  return sendTransactionWithErrorRaised({ name, args, signers });
};

/*
 * Transfers Momentable NFT with id equal **itemId** from **sender** account to **recipient**.
 * @param {string} sender - sender address
 * @param {string} recipient - recipient address
 * @param {UInt64} itemId - id of the item to transfer
 * @throws Will throw an error if execution will be halted
 * @returns {Promise<*>}
 * */
export const transferMomentable = async (sender, recipient, itemId) => {
  const name = 'Momentables/transfer_momentable';
  const args = [recipient, itemId];
  const signers = [sender];

  return sendTransaction({ name, args, signers });
};

/*
 * Returns the Momentable NFT with the provided **id** from an account collection.
 * @param {string} account - account address
 * @param {UInt64} itemID - NFT id
 * @throws Will throw an error if execution will be halted
 * @returns {UInt64}
 * */
export const getMomentable = async (account, itemID) => {
  const name = 'Momentables/get_Momentable';
  const args = [account, itemID];

  return executeScript({ name, args });
};

/*
 * Returns the number of Momentables in an account's collection.
 * @param {string} account - account address
 * @throws Will throw an error if execution will be halted
 * @returns {UInt64}
 * */
export const getMomentableCount = async (account) => {
  const name = 'Momentables/get_collection_length';
  const args = [account];

  return executeScript({ name, args });
};
