// SPDX-License-Identifier: BlueOak-1.0.0
pragma solidity 0.8.17;

abstract contract PreventTampering {
    modifier revertOnCodeHashChange() {
        bytes32 hashBefore;
        assembly {
            hashBefore := extcodehash(address())
        }
        _;
        bytes32 hashPostExecution;
        assembly {
            hashPostExecution := extcodehash(address())
        }
        require(hashPostExecution == hashBefore, "PreventTampering: Code has changed");
    }
}


contract SelfDestruct {
    function destroy() external {
        selfdestruct(payable(msg.sender));
    }
    function doNothing() external {}
}

contract TestPreventTampering is PreventTampering {
    function shouldNotRevert() external {
        SelfDestruct selfDestruct = new SelfDestruct();
        address(selfDestruct).delegatecall(abi.encodeWithSelector(selfDestruct.destroy.selector));
    }
    function shouldRevert() revertOnCodeHashChange() external {
        SelfDestruct selfDestruct = new SelfDestruct();
        address(selfDestruct).delegatecall(abi.encodeWithSelector(selfDestruct.destroy.selector));
    }
    function markedRevertOnCodeHashChangeDontRevert() revertOnCodeHashChange() external {
        SelfDestruct selfDestruct = new SelfDestruct();
        address(selfDestruct).delegatecall(abi.encodeWithSelector(selfDestruct.doNothing.selector));
    }
}