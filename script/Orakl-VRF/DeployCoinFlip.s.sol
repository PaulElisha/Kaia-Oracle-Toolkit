// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../../src/Orakl-VRF/CoinFlip.sol";
import "../../src/Orakl-VRF/CodeConstants.sol";

contract DeployCoinFlip is Script, CodeConstants {
    function deployCoinFlip() public returns (CoinFlip) {
        vm.startBroadcast();
        CoinFlip coinFlip = new CoinFlip(vrfAddress);
        vm.stopBroadcast();
        return coinFlip;
    }

    function run() public returns (CoinFlip) {
        return deployCoinFlip();
    }
}
