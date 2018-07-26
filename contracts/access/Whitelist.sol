pragma solidity ^0.4.24;


import "../ownership/Ownable.sol";


/**
 * @title Whitelist
 * @dev Base contract to manage a whitelist of user
 */
contract Whitelist is Ownable {
    event AddedToWhitelist(address indexed user);
    event RemovedFromWhitelist(address indexed user);

    mapping (address => bool) public whitelist;

    modifier whenWhitelisted(address _user) {
        require(whitelist[_user]);
        _;
    }

    modifier whenNotWhitelisted(address _user) {
        require(whitelist[_user] != true);
        _;
    }

    /**
     * @dev Add the Given address to the whitelist
     * @param _user The address to be added
     */
    function addToWhitelist(address _user) public onlyOwner whenNotWhitelisted(_user) {
        require(_user != address(0));
        whitelist[_user] = true;
        emit AddedToWhitelist(_user);
    }

    /**
     * @dev Assign the given address as not whitelisted
     * @param _user The address to be assigned
     */
    function removeFromWhitelist(address _user) public onlyOwner whenWhitelisted(_user) {
        whitelist[_user] = false;
        emit RemovedFromWhitelist(_user);
    }
}
