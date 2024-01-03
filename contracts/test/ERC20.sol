pragma solidity =0.5.16;

import '../FairswapERC20.sol';

contract ERC20 is FairswapERC20 {
    constructor(uint _totalSupply) public {
        _mint(msg.sender, _totalSupply);
    }
}
