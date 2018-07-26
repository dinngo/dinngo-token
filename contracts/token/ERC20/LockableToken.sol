pragma solidity ^0.4.24;


import "../../access/Whitelist.sol";
import "../../lifecycle/Lockable.sol";

import "./StandardToken.sol";


/**
 * @title LockableToken
 * @dev Manage the transfer ability of address with whitelist and lock
 */
contract LockableToken is StandardToken, Lockable, Whitelist {

    constructor(address _address) public {
        require(_address != address(0));
        addToWhitelist(_address);
    }

    /**
     * @dev Check if the sender is unlocked if the address is not whitelisted
     */
    modifier whenTransferrable() {
        if (whitelist[msg.sender] != true)
            require(isUnlocked());
        _;
    }

    function transfer(address _to, uint256 _value) public whenTransferrable returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenTransferrable returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public whenTransferrable returns (bool) {
        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue) public whenTransferrable returns (bool) {
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public whenTransferrable returns (bool) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }
}
