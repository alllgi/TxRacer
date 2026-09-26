// SPDX-License-Identifier: MIT

/// @title Base64
/// @author Brecht Devos - <brecht@loopring.org>
/// @notice Provides a function for encoding some bytes in base64
library Base64 {
  string internal constant TABLE =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

  function encode(bytes memory data) internal pure returns (string memory) {
    if (data.length == 0) return "";

    // load the table into memory
    string memory table = TABLE;

    // multiply by 4/3 rounded up
    uint256 encodedLen = 4 * ((data.length + 2) / 3);

    // add some extra buffer at the end required for the writing
    string memory result = new string(encodedLen + 32);

    assembly {
      function __shr_assembly_transpiled(x_transpiled, y_transpiled)
        -> r_transpiled
      {
        let divisor_transpiled := exp(2, x_transpiled)
        r_transpiled := div(y_transpiled, divisor_transpiled)
      }
      function __shl_assembly_transpiled(x_transpiled, y_transpiled)
        -> r_transpiled
      {
        let divisor_transpiled := exp(2, x_transpiled)
        let mask_transpiled := sub(0, slt(y_transpiled, 0))
        r_transpiled := xor(
          div(xor(y_transpiled, mask_transpiled), divisor_transpiled),
          mask_transpiled
        )
      }
      // set the actual output length
      mstore(result, encodedLen)

      // prepare the lookup table
      let tablePtr := add(table, 1)

      // input ptr
      let dataPtr := data
      let endPtr := add(dataPtr, mload(data))

      // result ptr, jump over length
      let resultPtr := add(result, 32)

      // run over the input, 3 bytes at a time
      for {

      } lt(dataPtr, endPtr) {

      } {
        dataPtr := add(dataPtr, 3)

        // read 3 bytes
        let input := mload(dataPtr)

        // write 4 characters
        mstore(
          resultPtr,
          __shl_assembly_transpiled(
            248,
            mload(
              add(tablePtr, and(__shr_assembly_transpiled(18, input), 0x3F))
            )
          )
        )
        resultPtr := add(resultPtr, 1)
        mstore(
          resultPtr,
          __shl_assembly_transpiled(
            248,
            mload(
              add(tablePtr, and(__shr_assembly_transpiled(12, input), 0x3F))
            )
          )
        )
        resultPtr := add(resultPtr, 1)
        mstore(
          resultPtr,
          __shl_assembly_transpiled(
            248,
            mload(add(tablePtr, and(__shr_assembly_transpiled(6, input), 0x3F)))
          )
        )
        resultPtr := add(resultPtr, 1)
        mstore(
          resultPtr,
          __shl_assembly_transpiled(248, mload(add(tablePtr, and(input, 0x3F))))
        )
        resultPtr := add(resultPtr, 1)
      }

      // padding with '='
      switch mod(mload(data), 3)
      case 1 {
        mstore(sub(resultPtr, 2), __shl_assembly_transpiled(240, 0x3d3d))
      }
      case 2 {
        mstore(sub(resultPtr, 1), __shl_assembly_transpiled(248, 0x3d))
      }
    }

    return result;
  }
}
