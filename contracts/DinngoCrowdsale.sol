pragma solidity ^0.4.24;


import "./crowdsale/lifecycle/PausableCrowdsale.sol";
import "./crowdsale/lifecycle/StatefulCrowdsale.sol";
import "./crowdsale/validation/CappedCrowdsale.sol";
import "./crowdsale/validation/WhitelistedCrowdsale.sol";
import "./token/ERC20/ERC20.sol";


/**
 * @title DinngoCrowdsale
 * @dev Dinngo crowdsale contract
 */
contract DinngoCrowdsale is
    WhitelistedCrowdsale,
    StatefulCrowdsale,
    PausableCrowdsale,
    CappedCrowdsale {
    event RateChanged(uint256 oldRate, uint256 newRate);
    event TokenWalletChanged(address indexed oldWallet, address indexed newWallet);
    event FundsWalletChanged(address indexed oldWallet, address indexed newWallet);

    address public tokenWallet;

    uint256 public bonus = 1000; // ratio to base
    uint256 public base = 10000; // ex: 1000/10000 = 10%

    constructor(ERC20 _token, uint256 _rate, address _tokenWallet, address _fundsWallet) public
        Crowdsale(_rate, _fundsWallet, _token)
    {
        require(_tokenWallet != address(0));
        require(_fundsWallet != address(0));
        tokenWallet = _tokenWallet;
        minCap = 0.1 ether;
    }

    /**
     * @dev Change the rate of purchasing of DGO/ETH
     * @param _rate The rate to be assigned
     */
    function changeRate(uint256 _rate) public onlyOwner {
        emit RateChanged(rate, _rate);
        rate = _rate;
    }

    /**
     * @dev Change the address of receiving Eth
     * @param _wallet The wallet address to be assigned
     */
    function changeFundsWallet(address _wallet) public onlyOwner {
        require(_wallet != address(0));
        wallet = _wallet;
        emit FundsWalletChanged(wallet, _wallet);
    }

    /**
     * @dev Transfer the presale token to wallet and assign timelock
     * @param _beneficiary The address to be given
     * @param _tokenAmount The token amount to be given
     */
    function presale(address _beneficiary, uint256 _tokenAmount) public onlyOwner {
        require(_beneficiary != address(0));
        require(_tokenAmount != 0);
        _deliverTokens(_beneficiary, _tokenAmount);
    }

    /**
     * @dev Override to extend the way in which ether is converted to tokens.
     * @param _weiAmount Value in wei to be converted into tokens
     * @return Number of tokens that can be purchased with the specified _weiAmount
     */
    function _getTokenAmount(uint256 _weiAmount)
        internal view returns (uint256)
    {
        return _weiAmount.mul(rate).mul(bonus.add(base)).div(base);
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
