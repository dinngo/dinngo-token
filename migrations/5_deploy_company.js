const DinngoCompany = artifacts.require("./DinngoCompany.sol");
let DinngoToken = artifacts.require("./DinngoToken.sol");

module.exports = function(deployer) {
    const companyWallet = "0xe46c697f989c0aeec08bbdb765059dce8b065e03";
    deployer.deploy(DinngoCompany, DinngoToken.address, companyWallet);
}
