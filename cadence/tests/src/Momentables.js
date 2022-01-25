import {
  deployContractByName,
  executeScript,
  mintFlow,
  sendTransaction,
} from 'flow-js-testing';

import { getMomentablesAdminAddress } from './common';

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

  await deployContractByName({
    to: MomentablesAdmin,
    name: 'NonFungibleToken',
  });

  const addressMap = { NonFungibleToken: MomentablesAdmin };
  return deployContractByName({
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

  return sendTransaction({ name, signers });
};

/*
 * Returns Momentables supply.
 * @throws Will throw an error if execution will be halted
 * @returns {UInt64} - number of NFT minted so far
 * */
export const getMomentablesupply = async () => {
  const name = 'Momentables/get_Momentables_supply';

  return executeScript({ name });
};

/*
 * Mints Momentable of a specific **itemType** and sends it to **recipient**.
 * @param {UInt64} itemType - type of NFT to mint
 * @param {string} recipient - recipient account address
 * @throws Will throw an error if execution will be halted
 * @returns {Promise<*>}
 * */
export const mintMomentable = async ({
  recipient,
  momentableId,
  name,
  description,
  imageCID,
  traits,
  creatorName,
  creatorAddress,
  creatorRoyalty,
  collaboratorNames,
  collaboratorAddresses,
  collaboratorRoyalties,
}) => {
  const MomentablesAdmin = await getMomentablesAdminAddress();

  const contractName = 'Momentables/mint_momentable';
  const args = [
    recipient,
    momentableId,
    name,
    description,
    imageCID,
    traits,
    creatorName,
    creatorAddress,
    creatorRoyalty,
    collaboratorNames,
    collaboratorAddresses,
    collaboratorRoyalties,
  ];
  const signers = [MomentablesAdmin];

  return sendTransaction({ contractName, args, signers });
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
  const name = 'Momentables/transfer_Momentable';
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
