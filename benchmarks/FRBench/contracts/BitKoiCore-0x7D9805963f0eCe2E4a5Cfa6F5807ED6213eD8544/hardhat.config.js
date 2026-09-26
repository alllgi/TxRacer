/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'BitKoiCore.sol',
  codeHash:
    '0x336089426a5c3d58c1b406736157c104fa886d26e93e826878cc2b798776bac3',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.7',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
