// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/TaikoLend.sol";

contract DeployTaikoLend is Script {
    function run() external {
        vm.startBroadcast();
        new TaikoLend(0xDCe5d4DF2A6708e1b8673eeB5e30DB2bC0aC82Df);
        vm.stopBroadcast();
    }
}
