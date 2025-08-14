// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {AdminAirdrop} from "../src/AdminAirdrop.sol";
import {GoldToken} from "../src/GoldToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployAdminAirdrop is Script {
    GoldToken token;
    AdminAirdrop airdrop;

    function run() public returns (GoldToken, AdminAirdrop) {
        vm.startBroadcast();
        token = new GoldToken();
        airdrop = new AdminAirdrop(IERC20(address(token)), msg.sender);
        vm.stopBroadcast();

        return (token, airdrop);
    }
}
