pragma solidity ^0.4.24;


import "../../lifecycle/State.sol";
import "../Crowdsale.sol";


/**
 * @title StatefulCrowdsale
 * @dev Extension of Crowdsale where an owner can do extra work
 * after finishing.
 */
contract StatefulCrowdsale is State, Crowdsale {

    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
        require(isState(States.InProgress));
        super._preValidatePurchase(_beneficiary, _weiAmount);
    }

}
