// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/Donation.sol";

contract DeployDonation is Script {
    function run() external {
        address platformAddress = vm.envAddress("PLATFORM_ADDRESS");
        vm.startBroadcast();
        new Donation(platformAddress);
        vm.stopBroadcast();
    }
}
