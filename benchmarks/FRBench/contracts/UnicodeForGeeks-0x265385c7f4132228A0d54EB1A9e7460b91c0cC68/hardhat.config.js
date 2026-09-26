/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  main: 'UnicodeForGeeks.sol',
  codeHash:
    '0x78c41a536fdc87ad746b297cd9ea4dc876ec2f066d5d1ad647d966133998ff25',
  paths: { sources: 'src' },
  solidity: {
    version: '0.8.7',
    settings: {
      optimizer: { enabled: true, runs: 1 },
      libraries: {
        'src/UnicodeForGeeks.sol': {
          UnicodeMap: '0xfab7e2fb81b083f49fd7089ef3db68e8bbad1263',
        },
      },
      outputSelection: { '*': { '*': ['*'] } },
      evmVersion: 'byzantium',
    },
  },
};
