/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: '/Users/admin/GitHub/defi/linkswap-truffle/contracts/LinkswapPair.sol',
  codeHash:
    '0x6853590390ca843c459d11f9e8e66ecdbb47109e3f0638c371d54689c0191fdd',
  paths: { sources: 'src' },
  solidity: {
    version: '0.6.6',
    settings: {
      remappings: [],
      optimizer: { enabled: true, runs: 200 },
      libraries: { src: {} },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
