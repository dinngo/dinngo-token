const DinngoFounding = artifacts.require("./DinngoFounding.sol");
let DinngoToken = artifacts.require("./DinngoToken.sol");

module.exports = function(deployer) {
    deployer.deploy(DinngoFounding, DinngoToken.address);
}
