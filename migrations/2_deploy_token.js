const DinngoToken = artifacts.require("./DinngoToken.sol");

module.exports = function(deployer) {
    const tokenWallet = "0xe46c697f989c0aeec08bbdb765059dce8b065e03";
    deployer.deploy(DinngoToken, tokenWallet);
};
