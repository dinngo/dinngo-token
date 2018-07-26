pragma solidity ^0.4.24;


import "./token/ERC20/LockableToken.sol";
import "./token/ERC20/PausableToken.sol";


///////////////////////
// Custom Token section
///////////////////////

/**
 * @title DinngoToken
 * @dev Dinngo token contract
 */
contract DinngoToken is LockableToken, PausableToken {
    string constant public name = "Dinngo";
    string constant public symbol = "DGO";
    uint8 constant public decimals = 18;
    string constant public version = "1.0";

    constructor(address customWallet) public
        LockableToken(customWallet)
    {
        require(customWallet != address(0));
        totalSupply_ = 2 * 10 ** (8 + uint256(decimals));
        balances[customWallet] = totalSupply_;
        emit Transfer(address(0), customWallet, totalSupply_);
    }

    function () public payable {
        revert();
    }
}
