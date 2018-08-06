const DinngoToken = artifacts.require("./DinngoToken.sol");

module.exports = function(deployer) {
    const tokenWallet = /* token wallet address */;
    deployer.deploy(DinngoToken, tokenWallet);
};
