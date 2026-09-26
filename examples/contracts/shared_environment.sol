pragma solidity 0.4.26;


contract SharedDependency {
    uint256 public total;
    function add(uint256 amount) public { total += amount; }
}

contract SharedApplication {
    SharedDependency public dependency;
    SharedApplication public peer;
    uint256 public initialized;

    constructor(address source) public { dependency = SharedDependency(source); }

    function initialize(uint256 value) public {
        require(initialized == 0 && value != 0);
        initialized = value;
    }

    function connect(address other) public {
        require(SharedApplication(other).initialized() != 0);
        peer = SharedApplication(other);
    }

    function touch(uint256 amount) public {
        require(initialized != 0);
        dependency.add(amount);
    }

    function observed() public view returns (uint256) { return dependency.total(); }
}
