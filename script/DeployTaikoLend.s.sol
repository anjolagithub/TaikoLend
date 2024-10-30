// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/TaikoLend.sol";

contract DeployTaikoLend is Script {
    event TaikoLendDeployed(address indexed contractAddress);

    function run() external {
        vm.startBroadcast();
        
        // Deploying the TaikoLend contract
        address taikoLendAddress = address(new TaikoLend(0xDCe5d4DF2A6708e1b8673eeB5e30DB2bC0aC82Df));
        
        // Emitting event with the deployed contract address
        emit TaikoLendDeployed(taikoLendAddress);
        
        vm.stopBroadcast();
    }
}
