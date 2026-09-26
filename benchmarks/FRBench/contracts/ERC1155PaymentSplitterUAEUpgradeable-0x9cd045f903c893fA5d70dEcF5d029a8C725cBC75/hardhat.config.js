/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/ERC1155PaymentSplitterUAEUpgradeable.sol',
  codeHash:
    '0x937c345b6c2a2080f88c33929bef9400b1f70852c86e7c9653c20e8aceebae5a',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.4',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      libraries: {},
      evmVersion: 'byzantium',
    },
  },
};
