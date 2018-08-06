const DinngoCrowdsale = artifacts.require("./DinngoCrowdsale.sol");
let DinngoToken = artifacts.require("./DinngoToken.sol");

module.exports = function(deployer) {
    const rate = 2125;
    const tokenWallet = /* token wallet address */;
    const fundsWallet = /* funds wallet address */;
    deployer.deploy(DinngoCrowdsale, DinngoToken.address, rate, tokenWallet, fundsWallet).then(function() {
        DinngoToken.at(DinngoToken.address).then(inst => {
            inst.addToWhitelist(DinngoCrowdsale.address);
        });
    });
};
