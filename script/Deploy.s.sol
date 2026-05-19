// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {ReceiptRegistry} from "../src/ReceiptRegistry.sol";

/// @notice Deploys ReceiptRegistry with the broadcasting wallet (the ByHuman
///         anchoring wallet) as the initial owner.
contract Deploy is Script {
    function run() external returns (ReceiptRegistry registry) {
        vm.startBroadcast();
        registry = new ReceiptRegistry(msg.sender);
        vm.stopBroadcast();

        console.log("ReceiptRegistry deployed at:", address(registry));
        console.log("Owner (anchoring wallet):  ", registry.owner());
    }
}
