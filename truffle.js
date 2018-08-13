module.exports = {
    networks: {
        development: {
            host: "127.0.0.1",
            port: 8545,
            network_id: "*",
            gas: 4700000
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
