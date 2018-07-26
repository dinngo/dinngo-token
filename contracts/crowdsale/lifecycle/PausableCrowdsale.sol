pragma solidity ^0.4.24;


import "../../lifecycle/Pausable.sol";
import "../Crowdsale.sol";


contract PausableCrowdsale is Pausable, Crowdsale {
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal whenNotPaused {
        super._preValidatePurchase(_beneficiary, _weiAmount);
    }
}
