pragma solidity ^0.4.24;


import "./ownership/Ownable.sol";
import "./math/SafeMath.sol";
import "./token/ERC20/SafeERC20.sol";


/**
 * @title DinngoCompany
 * @notice DinngoCompany contract holds the DGO token that is reserved for company operation.
 * Token is locked for at least 1 year.
 */
contract DinngoCompany is Ownable {
    event Claim(address user, uint256 amount);
    event ChangeWallet(address oldWallet, address newWallet);

    using SafeERC20 for ERC20Basic;
    using SafeMath for uint256;

    ERC20Basic public token;
    uint256 public startTime;
    address public wallet;

    constructor(ERC20Basic _token, address _wallet) public {
       token = _token;
       wallet = _wallet;
       startTime = now;
    }

    function () public payable {
        revert();
    }

    /**
     * @notice Claim the available balance
     * @param amount The amount to claim
     */
    function claim(uint256 amount) external {
        require(now > startTime.add(365 days));
        require(msg.sender == wallet);

        token.safeTransfer(msg.sender, amount);
        emit Claim(msg.sender, amount);
    }

    /**
     * @notice Change the wallet address
     * @param _wallet The new wallet address
     */
    function changeWallet(address _wallet) external onlyOwner {
        emit ChangeWallet(wallet, _wallet);
        wallet = _wallet;
    }
}
