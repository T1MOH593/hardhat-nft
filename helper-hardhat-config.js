const networkConfig = {
    31337: {
        name: "localhost",
        gasLane: "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc",
        ethUsdPriceFeed: "0x9326BFA02ADD2366b30bacB125260Af641031331",
        callbackGasLimit: "500000",
        mintFee: "1000000000000000", //0.01 ETH
    },
    4: {
        name: "rinkeby",
        vrfCoordinatorV2: "0x6168499c0cFfCaCD319c818142124B7A15E857ab",
        gasLane: "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc",
        subscriptionId: "10212",
        callbackGasLimit: "500000",
        ethUsdPriceFeed: "0x8A753747A1Fa494EC906cE90E9f37563A8AF630e",
        mintFee: "1000000000000000", //0.01 ETH
    },
}

const developmentChains = ["hardhat", "localhost"]

module.exports = {
    networkConfig,
    developmentChains,
}
