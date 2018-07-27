module.exports = {
    networks: {
        ropsten: {
            network_id: 3,
            host: "localhost",
            port: 8545,
            gas: 4700000,
            gasPrice: 22000000000
        }
    },
    rpc: {
        host: "localhost",
        port: 8080
    },
    solc: {
        optimizer: {
            enabled: true,
            runs: 200
        }
    }
};
