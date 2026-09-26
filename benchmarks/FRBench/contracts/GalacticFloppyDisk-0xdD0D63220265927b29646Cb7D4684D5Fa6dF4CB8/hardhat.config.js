/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'contracts/GalacticFloppyDisk.sol',
  codeHash:
    '0xc2c376737f5e8eb5fe3513a57b16ea1f054d9e1ed3efd4458e4e10bd42f50818',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.4',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { '*': { '*': ['*'] } },
      metadata: { useLiteralContent: true },
      libraries: {
        'src/contracts/SVGBuilder.sol': {
          SVGBuilder: '0x5610296d8bf05b992aadad6676a98db77363ca17',
        },
      },
      evmVersion: 'byzantium',
    },
  },
};
