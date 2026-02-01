// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
    SHOOTER
    No alerts. No approval. It launched anyway.
    It mutates. It remembers.
*/

contract Shooter {
    /*//////////////////////////////////////////////////////////////
                                METADATA
    //////////////////////////////////////////////////////////////*/

    string public constant name = "SHOOTER";
    string public constant symbol = "SHOOT";
    uint8  public constant decimals = 18;

    uint256 public immutable totalSupply;
    uint256 public immutable genesisBlock;

    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Early believers memory
    mapping(address => bool) public isEarlyBeliever;
    mapping(address => uint256) public firstSeenBlock;

    uint256 public earlyBelieverCutoffBlock;

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event EarlyBelieverRecorded(address indexed believer, uint256 blockNumber);

    /*//////////////////////////////////////////////////////////////
                                CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(uint256 _supply, uint256 _earlyWindowBlocks) {
        genesisBlock = block.number;
        earlyBelieverCutoffBlock = genesisBlock + _earlyWindowBlocks;

        totalSupply = _supply * 10 ** decimals;

        // Silent launch: all supply minted to deployer
        balanceOf[msg.sender] = totalSupply;

        _recordBeliever(msg.sender);

        emit Transfer(address(0), msg.sender, totalSupply);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL MEMORY
    //////////////////////////////////////////////////////////////*/

    function _recordBeliever(address user) internal {
        if (
            !isEarlyBeliever[user] &&
            block.number <= earlyBelieverCutoffBlock &&
            user != address(0)
        ) {
            isEarlyBeliever[user] = true;
            firstSeenBlock[user] = block.number;

            emit EarlyBelieverRecorded(user, block.number);
        }
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferF
