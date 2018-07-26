pragma solidity ^0.4.24;


import "../../ownership/Ownable.sol";
import "../Crowdsale.sol";


/**
 * @title CappedCrowdsale
 * @dev Define the personal cap of each purchase.
 */

contract CappedCrowdsale is Ownable, Crowdsale {
    using SafeMath for uint256;

    uint256 minCap;
    // uint256 maxCap;

    modifier whenGreaterThan(uint256 _value) {
        require(_value >= minCap);
        _;
    }

    // modifier whenLessThan(uint256 _value) {
    //    require(_value <= maxCap);
    //    _;
    // }

    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal whenGreaterThan(_weiAmount) {
        super._preValidatePurchase(_beneficiary, _weiAmount);
    }
}
