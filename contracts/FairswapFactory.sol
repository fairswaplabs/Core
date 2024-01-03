pragma solidity =0.5.16;

import './interfaces/IFairswapFactory.sol';
import './FairswapPair.sol';

contract FairswapFactory is IFairswapFactory {
    address public feeTo;
    address public feeToSetter;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;
    uint public feeRate;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor(address _feeToSetter, uint256 _feeRate) public {
        feeToSetter = _feeToSetter;
        feeRate = _feeRate;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, 'Fairswap: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'Fairswap: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'Fairswap: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(FairswapPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IFairswapPair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeRate(uint _feeRate) external {
        require(msg.sender == feeToSetter, 'Fairswap: FORBIDDEN');
        require(_feeRate < 1000, 'Fairswap: FEE RATE TOO HIGH');
        feeRate = _feeRate;
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'Fairswap: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'Fairswap: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }
}
