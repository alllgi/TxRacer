/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: '/Users/boss/Desktop/PlasmaSwap-prod-master/plasmaswap-periphery/contracts/PlasmaswapRouter.sol',
  codeHash:
    '0x935e8f61b24dcf34234bdc7509ed15232cb7e111e28fea33029d3e2e6c1dba9f',
  paths: { sources: 'src' },
  solidity: {
    version: '0.6.6',
    settings: {
      remappings: [],
      optimizer: { enabled: true, runs: 200 },
      libraries: {},
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
