pragma solidity ^0.4.24;


import "../ownership/Ownable.sol";


/**
 * @title State
 * @dev Manage the state of crowdsale
 */
contract State is Ownable {

    enum States { Prepare, InProgress, Finalized }

    States public state;

    event Started(uint256 time);
    event Finalized(uint256 time);

    /**
     * @dev Check if the crowdsale matches the given the state
     * @param _state The state to be matched
     */
    function isState(States _state) public view returns (bool) {
        return state == _state;
    }

    constructor() public {
        state = States.Prepare;
    }

    /**
     * @dev Starts the crowdsale
     */
    function start() public onlyOwner {
        require(isState(States.Prepare));
        state = States.InProgress;
        emit Started(now);
    }

    /**
     * @dev finalize the crowdsale
     */
    function finalize() public onlyOwner {
        require(isState(States.InProgress));
        state = States.Finalized;
        emit Finalized(now);
    }

}

