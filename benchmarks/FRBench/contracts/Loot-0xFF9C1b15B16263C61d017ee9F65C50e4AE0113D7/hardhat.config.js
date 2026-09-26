/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'Loot.sol',
  codeHash:
    '0xc6ad53bb8ac69d66fe1861fe265aebdf6a613eef8f853522b8df19dda4f7f165',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.4',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
