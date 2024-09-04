// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/CoinFlip.sol";
import "./NetworkConfig.s.sol";

contract DeployCoinFlip is Script {
    address vrfAddress;
    struct Config {
        address vrfAddress;
    }

    function deployCoinFlip() public returns (CoinFlip) {
        NetworkConfig networkConfig = new NetworkConfig();
        Config config = networkConfig.getConfig();
        vrfAddress = config.vrfAddress;

        vm.startBroadcast();
        CoinFlip coinFlip = new CoinFlip(vrfAddress);
        vm.stopBroadcast();
        return coinFlip;
    }

    function run() public returns (CoinFlip) {
        return deployCoinFlip();
    }
}
