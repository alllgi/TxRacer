/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: '/D/Data/4. Coding/Solidity/Nakamoto/polkastrategies/contracts/strategies/Harvest/HarvestSC.sol',
  codeHash:
    '0x8be0decc4a9f68ea51492a27acbe4defe8e5e823d6b31f02219c7918fb50d18c',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.4',
    settings: {
      remappings: [],
      optimizer: { enabled: true, runs: 200 },
      libraries: {},
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
