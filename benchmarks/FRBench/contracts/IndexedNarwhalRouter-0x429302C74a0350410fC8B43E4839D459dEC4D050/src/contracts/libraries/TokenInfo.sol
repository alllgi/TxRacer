pragma solidity >=0.5.0;

library TokenInfo {
  function unpack(bytes32 tokenInfo)
    internal
    pure
    returns (address token, bool useSushiNext)
  {
    assembly {
      function __shr_assembly_transpiled(x_transpiled, y_transpiled)
        -> r_transpiled
      {
        let divisor_transpiled := exp(2, x_transpiled)
        r_transpiled := div(y_transpiled, divisor_transpiled)
      }
      token := __shr_assembly_transpiled(8, tokenInfo)
      useSushiNext := byte(31, tokenInfo)
    }
  }

  function pack(address token, bool sushi)
    internal
    pure
    returns (bytes32 tokenInfo)
  {
    assembly {
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
      tokenInfo := or(__shl_assembly_transpiled(8, token), sushi)
    }
  }

  function readToken(bytes32 tokenInfo) internal pure returns (address token) {
    assembly {
      function __shr_assembly_transpiled(x_transpiled, y_transpiled)
        -> r_transpiled
      {
        let divisor_transpiled := exp(2, x_transpiled)
        r_transpiled := div(y_transpiled, divisor_transpiled)
      }
      token := __shr_assembly_transpiled(8, tokenInfo)
    }
  }

  function readSushi(bytes32 tokenInfo)
    internal
    pure
    returns (bool useSushiNext)
  {
    assembly {
      useSushiNext := byte(31, tokenInfo)
    }
  }
}
