pragma solidity ^0.4.24;


import "../ownership/Ownable.sol";


/**
 * @title Lockable
 * @dev Base contract to unlock a contract which is initially locked
 */
contract Lockable is Ownable {
    event Lock();
    event Unlock();

    bool public locked = true;

    constructor() public {
    }

    /**
     * @notice Unlock the contract
     */
    function unlock() external onlyOwner {
        require(locked);
        locked = false;
        emit Unlock();
    }

    /**
     * @dev Check if the address is unlocked.
     */
    function isUnlocked() public view returns (bool) {
        return !locked;
    }
}
