// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/contracts/Trademark.sol";

contract Deploy is Script {
    function run() external {
        // Verwenden Sie `vm.env` für den privaten Schlüssel als Hex-String
        bytes32 deployerPrivateKey = vm.envBytes32("PRIVATE_KEY");
        vm.startBroadcast(uint256(deployerPrivateKey));

        new Trademark(0.00001 ether);

        vm.stopBroadcast();
    }
}

