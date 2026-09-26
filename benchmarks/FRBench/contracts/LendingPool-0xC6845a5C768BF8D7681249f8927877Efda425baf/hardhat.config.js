/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/protocol/lendingpool/LendingPool.sol',
  codeHash:
    '0x87993a151eb914f4f1e846af09568979b15dc819f27e8e80e42cab73063f8f25',
  paths: { sources: 'src' },
  solidity: {
    version: '0.6.12',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      libraries: {
        'src/contracts/protocol/libraries/logic/ReserveLogic.sol': {
          ReserveLogic: '0xe58575ba47a348e3c2f9b7ec3eccfbb189ccc6ec',
        },
        'src/contracts/protocol/libraries/logic/ValidationLogic.sol': {
          ValidationLogic: '0xf5543cdd5f551635e13ebe07e47d01d0fc9cbbd5',
        },
      },
      evmVersion: 'byzantium',
    },
  },
};
