pragma solidity ^0.4.21;


//////////////////
// Library section
//////////////////

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
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
 * @title Timelock
 * @dev Manage the time lock of token
 */
contract Timelock is Ownable {
    using SafeMath for uint256;

    mapping (address => bool) lockUser;
    mapping (address => uint256) lockTime;

    uint256 public finalTime;

    function Timelock() public {
        finalTime = 0;
    }

    /**
     * @dev Record the finalized time as the reference of time lock.
     */
    function finalize() public {
        require(finalTime == 0);
        finalTime = now;
    }

    /**
     * @dev Return the time to be locked of the given address
     * @param _user The address of the user to be queried
     */
    function getTimelock(address _user) public view returns (uint256) {
        require(lockUser[_user]);
        return lockTime[_user];
    }

    /**
     * @dev Set the given address as locked and assign the time
     * @param _user The address to be locked
     * @param _time The time length to be locked
     */
    function setTimelock(address _user, uint256 _time) public onlyOwner {
        lockUser[_user] = true;
        lockTime[_user] = _time;
    }

    /**
     * @dev Check if the address is unlocked
     * @param _user The address to be queried
     */
    function isUnlocked(address _user) public view returns (bool) {
        return finalTime != 0 && (!lockUser[_user] == true || now >= finalTime.add(lockTime[_user]));
    }
}


/**
 * @title OwnerPausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
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
    function pause() public onlyOwner {
        require(!paused);
        paused = true;
        emit Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner {
        require(paused);
        paused = false;
        emit Unpause();
    }
}

contract Whitelist is Ownable {
    event AddedToWhitelist(address indexed user);
    event RemovedFromWhitelist(address indexed user);

    mapping (address => bool) internal _data;

    modifier whenWhitelisted(address _user) {
        require(_data[_user]);
        _;
    }

    modifier whenNotWhitelisted(address _user) {
        require(_data[_user] != true);
        _;
    }

    /**
     * @dev Add the Given address to the whitelist
     * @param _user The address to be added
     */
    function addToWhitelist(address _user) public onlyOwner whenNotWhitelisted(_user) {
        _data[_user] = true;
        emit AddedToWhitelist(_user);
    }

    /**
     * @dev Assign the given address as not whitelisted
     * @param _user The address to be assigned
     */
    function removeFromWhitelist(address _user) public onlyOwner whenWhitelisted(_user) {
        _data[_user] = false;
        emit RemovedFromWhitelist(_user);
    }

    /**
     * @dev Check if the address is whitelisted
     * @param _user The address to be checked
     */
    function isWhitelisted(address _user) public view returns (bool) {
        return _data[_user] == true;
    }
}


/**
 * @title State
 * @dev Manage the state of token
 */
contract State is Ownable {

    enum States { Prepare, InProgress, Finalized }

    States public state;

    event Started(uint256 time);
    event Finalized(uint256 time);

    function isState(States _state) public view returns (bool) {
        return _state == state;
    }

    function State() public {
        state = States.Prepare;
    }

    function start() public onlyOwner {
        state = States.InProgress;
        emit Started(now);
    }

    /**
     * @dev finalize the token and record the finalized time
     */
    function finalize() public onlyOwner{
        state = States.Finalized;
        emit Finalized(now);
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


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    uint256 totalSupply_;

    /**
     * @dev total number of tokens in existence
     */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    /**
     * @dev transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param _owner The address to query the the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) internal allowed;


    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    *
    * Beware that changing an allowance with this method brings the risk that someone may use both the old
    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
    * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    * @param _spender The address which will spend the funds.
    * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
    * @dev Function to check the amount of tokens that an owner allowed to a spender.
    * @param _owner address The address which owns the funds.
    * @param _spender address The address which will spend the funds.
    * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     *
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _addedValue The amount of tokens to increase the allowance by.
     */
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     *
     * approve should be called when allowed[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}


///////////////////////
// Custom Token section
///////////////////////

contract TimelockToken is Whitelist, Timelock, StandardToken {

    function TimelockToken(address _address) public {
        addToWhitelist(_address);
    }

    modifier whenTransferrable() {
        if (isWhitelisted(msg.sender) != true)
            require(isUnlocked(msg.sender));
        _;
    }

    function transfer(address _to, uint256 _value) public whenTransferrable returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenTransferrable returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }
}

/**
 * @title Pausable token
 * @dev StandardToken modified with pausable transfers.
 **/
contract PausableToken is Pausable, StandardToken {

    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }
}


contract CustomToken is TimelockToken, PausableToken {
    string constant public name = "Token";
    string constant public symbol = "TOK";
    uint8 constant public decimals = 18;
    string constant public version = "1.0";

    function CustomToken(address customWallet) public
        TimelockToken(customWallet)
        Pausable(false)
    {
        totalSupply_ = 2 * 10 ** (8 + uint256(decimals));
        balances[customWallet] = totalSupply_;
    }

    function () public payable {
        revert();
    }
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
 */
contract Crowdsale {
    using SafeMath for uint256;

    // The token being sold
    CustomToken public token;

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
     */
    function Crowdsale(uint256 _rate, address _wallet) public {
        require(_rate > 0);
        require(_wallet != address(0));

        rate = _rate;
        wallet = _wallet;
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
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal whenWhitelisted(_beneficiary) {
        super._preValidatePurchase(_beneficiary, _weiAmount);
    }

}


/**
 * @title StatedCrowdsale
 * @dev Extension of Crowdsale where an owner can do extra work
 * after finishing.
 */
contract StatedCrowdsale is State, Crowdsale {

    function finalize() public onlyOwner {
        super.finalize();
        token.finalize();
        token.transferOwnership(msg.sender);
    }

    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
        require(isState(States.InProgress));
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


contract PausableCrowdsale is Pausable, Crowdsale {
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal whenNotPaused {
        super._preValidatePurchase(_beneficiary, _weiAmount);
    }
}


contract CustomCrowdsale is
    WhitelistedCrowdsale,
    StatedCrowdsale,
    PausableCrowdsale,
    CappedCrowdsale {
    event RateChanged(uint256 oldRate, uint256 newRate);
    event TokenWalletChanged(address indexed oldWallet, address indexed newWallet);
    event FundsWalletChanged(address indexed oldWallet, address indexed newWallet);

    address public tokenWallet;

    function CustomCrowdsale(uint256 _rate, address _tokenWallet, address _fundsWallet) public
        Pausable(false)
        Crowdsale(_rate, _fundsWallet)
    {
        tokenWallet = _tokenWallet;
        token = new CustomToken(_tokenWallet);
        token.addToWhitelist(address(this));
        minCap = 0.1 ether;
    }

    function changeRate(uint256 _rate) public onlyOwner {
        emit RateChanged(rate, _rate);
        rate = _rate;
    }

    function changeTokenWallet(address _wallet) public onlyOwner {
        emit TokenWalletChanged(tokenWallet, _wallet);
        tokenWallet = _wallet;
    }

    function changeFundsWallet(address _wallet) public onlyOwner {
        emit FundsWalletChanged(wallet, _wallet);
        wallet = _wallet;
    }

    function addToWhitelistWithTime(address _user, uint256 _time) public onlyOwner {
        addToWhitelist(_user);
        token.setTimelock(_user, _time);
    }

    function allowManyToWhitelistWithTime(address[] _users, uint256 _time) public onlyOwner {
        for (uint256 i = 0; i < _users.length; i++) {
            addToWhitelist(_users[i]);
            token.setTimelock(_users[i], _time);
        }
    }

    function presale(address _beneficiary, uint256 _tokenAmount, uint256 _time) public onlyOwner {
        _deliverTokens(_beneficiary, _tokenAmount);
        token.setTimelock(_beneficiary, _time);
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
