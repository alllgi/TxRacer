/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'SwapsImplUniswapV2_ETH.sol',
  codeHash:
    '0xaf27be9d34e8d9976b2695d580826c5c90f10698acf212d94aecf2b4afc14f70',
  paths: { sources: 'src' },
  solidity: {
    version: '0.5.17',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
