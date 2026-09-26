/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <brecht@loopring.org>
pragma solidity ^0.8.4;

library Base64 {
  bytes internal constant TABLE =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

  /// @notice Encodes some bytes to the base64 representation
  function encode(bytes memory data) internal pure returns (string memory) {
    uint256 len = data.length;
    if (len == 0) return "";

    // multiply by 4/3 rounded up
    uint256 encodedLen = 4 * ((len + 2) / 3);

    // Add some extra buffer at the end
    bytes memory result = new bytes(encodedLen + 32);

    bytes memory table = TABLE;

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
      let tablePtr := add(table, 1)
      let resultPtr := add(result, 32)

      for {
        let i := 0
      } lt(i, len) {

      } {
        i := add(i, 3)
        let input := and(mload(add(data, i)), 0xffffff)

        let out := mload(
          add(tablePtr, and(__shr_assembly_transpiled(18, input), 0x3F))
        )
        out := __shl_assembly_transpiled(8, out)
        out := add(
          out,
          and(
            mload(
              add(tablePtr, and(__shr_assembly_transpiled(12, input), 0x3F))
            ),
            0xFF
          )
        )
        out := __shl_assembly_transpiled(8, out)
        out := add(
          out,
          and(
            mload(
              add(tablePtr, and(__shr_assembly_transpiled(6, input), 0x3F))
            ),
            0xFF
          )
        )
        out := __shl_assembly_transpiled(8, out)
        out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
        out := __shl_assembly_transpiled(224, out)

        mstore(resultPtr, out)

        resultPtr := add(resultPtr, 4)
      }

      switch mod(len, 3)
      case 1 {
        mstore(sub(resultPtr, 2), __shl_assembly_transpiled(240, 0x3d3d))
      }
      case 2 {
        mstore(sub(resultPtr, 1), __shl_assembly_transpiled(248, 0x3d))
      }

      mstore(result, encodedLen)
    }

    return string(result);
  }
}
