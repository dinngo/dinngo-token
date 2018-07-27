var DinngoCrowdsale = artifacts.require("./DinngoCrowdsale.sol");

module.exports = function(deployer) {
  const rate = 2125;
  const tokenWallet = "0xe46c697f989c0aeec08bbdb765059dce8b065e03";
  const fundsWallet = "0xad6368c6659e3ac2e15623566b767022708efd11";
  deployer.deploy(DinngoCrowdsale, rate, tokenWallet, fundsWallet, {gas: 4700000});
};
