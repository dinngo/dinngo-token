module.exports = {
    networks: {
        development: {
            host: "127.0.0.1",
            port: 8545,
            network_id: "*"
        },
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
