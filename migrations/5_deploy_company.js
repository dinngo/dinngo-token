const DinngoCompany = artifacts.require("./DinngoCompany.sol");
let DinngoToken = artifacts.require("./DinngoToken.sol");

module.exports = function(deployer) {
    const companyWallet = /* company wallet address */;
    deployer.deploy(DinngoCompany, DinngoToken.address, companyWallet);
}
