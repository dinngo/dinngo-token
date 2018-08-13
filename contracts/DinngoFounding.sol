pragma solidity ^0.4.24;


import "./ownership/Ownable.sol";
import "./math/SafeMath.sol";
import "./token/ERC20/SafeERC20.sol";


/**
 * @title DinngoFounding
 * @notice DinngoFounding contract holds the DGO token that is reserved for founding team.
 * Token is locked for at least 1 year.
 */
contract DinngoFounding is Ownable {
    event AddUser(address user, uint256 time, uint256 amount);
    event RemoveUser(address user);
    event Claim(address user, uint256 amount);

    using SafeERC20 for ERC20Basic;
    using SafeMath for uint256;

    mapping(address => uint256) startTime;
    mapping(address => uint256) totalAmount;
    mapping(address => uint256) claimedAmount;

    ERC20Basic public token;

    constructor(ERC20Basic _token) public {
        token = _token;
    }

    function () public payable {
        revert();
    }

    /**
     * @notice Add new recruits
     * @param user The user address of new recruit
     * @param time The onboard time
     * @param amount The amount of package
     */
    function addUser(address user, uint256 time, uint256 amount) external onlyOwner {
        startTime[user] = time;
        totalAmount[user] = amount;
        emit AddUser(user, time, amount);
    }

    /**
     * @notice Remove the resignee
     * @dev The resignee remains the current amount of payable
     * @param user The user address of resignee
     */
    function removeUser(address user) external onlyOwner {
        startTime[user] = 0;
        totalAmount[user] = payableAmount(user);
        emit RemoveUser(user);
    }

    /**
     * @notice Claim the available balance
     */
    function claim() external {
        require(totalAmount[msg.sender] > 0);
        uint256 availableAmount = payableAmount(msg.sender).sub(claimedAmount[msg.sender]);
        require(availableAmount > 0);

        token.safeTransfer(msg.sender, availableAmount);
        claimedAmount[msg.sender] = claimedAmount[msg.sender].add(availableAmount);
        emit Claim(msg.sender, availableAmount);
    }

    /**
     * @notice Calculate the given user's payable amount base on the time interval.
     * The first payable time is after 1 year for 25% of total amount. After that,
     * pay every 90 days for 25% * 25% of total amount.
     * @param user The user address to be queried
     * @return ret The payable amount
     */
    function payableAmount(address user) public view returns (uint256 ret) {
        uint256 payableUnit = totalAmount[user].div(16);
        uint256 payableTime;
        uint256 interval = now.sub(startTime[user]);
        if (interval < 365 days) {
            ret = 0;
            return;
        } else {
            payableTime = 4;
        }
        payableTime = payableTime.add(interval.sub(365 days).div(90 days));
        payableTime = payableTime > 16 ? 16 : payableTime;
        ret = payableUnit.mul(payableTime);
    }
}
