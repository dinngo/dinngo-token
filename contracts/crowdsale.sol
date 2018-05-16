pragma solidity ^0.4.21;


//////////////////
// Library section
//////////////////

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 * @dev Based on the code from OpenZeppelin: https://github.com/OpenZeppelin/openzeppelin-solidity
 */
library SafeMath {

    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
     * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


////////////////////
// Utilities section
////////////////////

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 * @dev Based on the code from OpenZeppelin: https://github.com/OpenZeppelin/openzeppelin-solidity
 */
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 * @dev Based on the code from OpenZeppelin: https://github.com/OpenZeppelin/openzeppelin-solidity
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused;

    function Pausable(bool _paused) public {
        paused = _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }
}


/**
 * @title State
 * @dev Manage the state transition in different stages of the crowdsale
 */
contract State is Ownable {
    using SafeMath for uint256;

    uint256 public timeInterval;
    uint256 public unlockTime;

    enum States { Prepare, InProgress, Finalized }

    States public state;

    event Started(uint256 time);
    event Finalized(uint256 time);

    modifier whenState(States _state) {
        require(state == _state);
        _;
    }

    function isUnlocked() whenState(States.Finalized) public view returns(bool) {
        return (now >= unlockTime);
    }

    function checkUnlocked() internal view {
        require(state == States.Finalized);
        require(now >= unlockTime);
    }

    function State(uint256 time) public {
        state = States.Prepare;
        timeInterval = time;
    }

    function start() public onlyOwner {
        state = States.InProgress;
        emit Started(now);
    }

    /**
     * @dev finalize the token and record the finalized time
     */
    function finalize() public onlyOwner {
        state = States.Finalized;
        unlockTime = timeInterval.add(now);
        emit Finalized(now);
    }
}


/**
 * @title Whitelist
 * @dev Manage a map of whitelisted users
 */
contract Whitelist is Ownable {
    event Allow(address indexed user);
    event Disallow(address indexed user);

    mapping (address => bool) public whitelist;

    modifier whenAllowed(address _user) {
        require(whitelist[_user]);
        _;
    }

    modifier whenNotAllowed(address _user) {
        require(whitelist[_user] != true);
        _;
    }

    function allow(address _user) public onlyOwner whenNotAllowed(_user) {
        require(_user != address(0));
        whitelist[_user] = true;
        emit Allow(_user);
    }

    function disallow(address _user) public onlyOwner whenAllowed(_user) {
        require(_user != address(0));
        whitelist[_user] = false;
        emit Disallow(_user);
    }
}

//////////////////////
// ERC20 Token section
//////////////////////

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

////////////////////
// Crowdsale section
////////////////////

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale,
 * allowing investors to purchase tokens with ether. This contract implements
 * such functionality in its most fundamental form and can be extended to provide additional
 * functionality and/or custom behavior.
 * The external interface represents the basic interface for purchasing tokens, and conform
 * the base architecture for crowdsales. They are *not* intended to be modified / overriden.
 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override
 * the methods to add functionality. Consider using 'super' where appropiate to concatenate
 * behavior.
 * @dev Based on the code from OpenZeppelin: https://github.com/OpenZeppelin/openzeppelin-solidity
 */
contract Crowdsale {
    using SafeMath for uint256;

    // The token being sold
    ERC20 public token;

    // Address where funds are collected
    address public wallet;

    // How many token units a buyer gets per wei
    uint256 public rate;

    // Amount of wei raised
    uint256 public weiRaised;

    /**
    * Event for token purchase logging
    * @param purchaser who paid for the tokens
        * @param beneficiary who got the tokens
    * @param value weis paid for purchase
    * @param amount amount of tokens purchased
     */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    /**
    * @param _rate Number of token units a buyer gets per wei
    * @param _wallet Address where collected funds will be forwarded to
    * @param _token Address of the token being sold
     */
    function Crowdsale(uint256 _rate, address _wallet, ERC20 _token) public {
        require(_rate > 0);
        require(_wallet != address(0));
        require(_token != address(0));

        rate = _rate;
        wallet = _wallet;
        token = _token;
    }

    // -----------------------------------------
    // Crowdsale external interface
    // -----------------------------------------

    /**
     * @dev fallback function ***DO NOT OVERRIDE***
     */
    function () external payable {
        buyTokens(msg.sender);
    }

    /**
    * @dev low level token purchase ***DO NOT OVERRIDE***
    * @param _beneficiary Address performing the token purchase
    */
    function buyTokens(address _beneficiary) public payable {

        uint256 weiAmount = msg.value;
        _preValidatePurchase(_beneficiary, weiAmount);

        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount);

        // update state
        weiRaised = weiRaised.add(weiAmount);

        _processPurchase(_beneficiary, tokens);
        emit TokenPurchase(
            msg.sender,
            _beneficiary,
            weiAmount,
            tokens
        );

        _updatePurchasingState(_beneficiary, weiAmount);

        _forwardFunds();
        _postValidatePurchase(_beneficiary, weiAmount);
    }

    // -----------------------------------------
    // Internal interface (extensible)
    // -----------------------------------------

    /**
     * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use super to concatenate validations.
     * @param _beneficiary Address performing the token purchase
     * @param _weiAmount Value in wei involved in the purchase
     */
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
        require(_beneficiary != address(0));
        require(_weiAmount != 0);
    }

    /**
     * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
     * @param _beneficiary Address performing the token purchase
     * @param _weiAmount Value in wei involved in the purchase
     */
    function _postValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
        // optional override
    }

    /**
     * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
     * @param _beneficiary Address performing the token purchase
     * @param _tokenAmount Number of tokens to be emitted
     */
    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
        token.transfer(_beneficiary, _tokenAmount);
    }

    /**
     * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
     * @param _beneficiary Address receiving the tokens
     * @param _tokenAmount Number of tokens to be purchased
     */
    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
        _deliverTokens(_beneficiary, _tokenAmount);
    }

    /**
     * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
     * @param _beneficiary Address receiving the tokens
     * @param _weiAmount Value in wei involved in the purchase
     */
    function _updatePurchasingState(address _beneficiary, uint256 _weiAmount) internal {
        // optional override
    }

    /**
     * @dev Override to extend the way in which ether is converted to tokens.
     * @param _weiAmount Value in wei to be converted into tokens
     * @return Number of tokens that can be purchased with the specified _weiAmount
     */
    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        return _weiAmount.mul(rate);
    }

    /**
     * @dev Determines how ETH is stored/forwarded on purchases.
     */
    function _forwardFunds() internal {
        wallet.transfer(msg.value);
    }
}


///////////////////////////
// Custom Crowdsale section
///////////////////////////


/**
 * @title WhitelistedCrowdsale
 * @dev Crowdsale in which only whitelisted users can contribute.
 */
contract WhitelistedCrowdsale is Whitelist, Crowdsale {
    /**
     * @dev Extend parent behavior requiring beneficiary to be in whitelist.
     * @param _beneficiary Token beneficiary
     * @param _weiAmount Amount of wei contributed
     */
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal whenAllowed(_beneficiary) {
        super._preValidatePurchase(_beneficiary, _weiAmount);
    }

}


/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowdsale where an owner can do extra work
 * after finishing.
 */
contract FinalizableCrowdsale is State, Crowdsale {
    using SafeMath for uint256;

    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal whenState(States.InProgress) {
        super._preValidatePurchase(_beneficiary, _weiAmount);
    }

}


/**
 * @title CappedCrowdsale
 * @dev Define the personal cap of each purchase.
 */

contract CappedCrowdsale is Ownable, Crowdsale {
    using SafeMath for uint256;

    uint256 minCap;
    uint256 maxCap;

    modifier whenGreaterThan(uint256 _value) {
        require(_value >= minCap);
        _;
    }

    modifier whenLessThan(uint256 _value) {
        require(_value <= maxCap);
        _;
    }

    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal whenGreaterThan(_weiAmount) {
        super._preValidatePurchase(_beneficiary, _weiAmount);
    }
}

/**
 * @title PausableCrowdsale
 * @dev Make the entire crowdsale process pausable.
 */
contract PausableCrowdsale is Pausable, Crowdsale {
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal whenNotPaused {
        super._preValidatePurchase(_beneficiary, _weiAmount);
    }
}


/**
 * @title CustomCrowdsale
 * @dev The customized Dinngo crowdsale
 */
contract CustomCrowdsale is
    WhitelistedCrowdsale,
    FinalizableCrowdsale,
    PausableCrowdsale,
    CappedCrowdsale {
    event RateChanged(uint256 oldRate, uint256 newRate);
    event TokenWalletChanged(address indexed oldWallet, address indexed newWallet);
    event FundsWalletChanged(address indexed oldWallet, address indexed newWallet);

    address public tokenWallet;

    function CustomCrowdsale(uint256 _rate, address _tokenWallet, address _fundsWallet, ERC20 _token) public
        State(1 days)
        Pausable(false)
        Crowdsale(_rate, _fundsWallet, _token)
    {
        tokenWallet = _tokenWallet;
        minCap = 0.1 ether;
    }

    function changeRate(uint256 _rate) public onlyOwner {
        emit RateChanged(rate, _rate);
        rate = _rate;
    }

    function changeTokenWallet(address _wallet) public onlyOwner {
        require(_wallet != address(0));
        require(_wallet != tokenWallet);
        emit TokenWalletChanged(tokenWallet, _wallet);
        tokenWallet = _wallet;
    }

    function changeFundsWallet(address _wallet) public onlyOwner {
        require(_wallet != address(0));
        require(_wallet != wallet);
        emit FundsWalletChanged(wallet, _wallet);
        wallet = _wallet;
    }

    /**
     * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
     * @param _beneficiary Address performing the token purchase
     * @param _tokenAmount Number of tokens to be emitted
     */
    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
        token.transferFrom(tokenWallet, _beneficiary, _tokenAmount);
    }
}
