// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {DeployAdminAirdrop} from "../script/DeployAdminAirdrop.s.sol";
import {AdminAirdrop} from "../src/AdminAirdrop.sol";
import {GoldToken} from "../src/GoldToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AdminAirdropTest is Test {
    address admin;
    uint256 adminPrivKey;
    address user;
    GoldToken token;
    AdminAirdrop airdrop;
    uint256 private constant AMOUNT_MINT = (50 * 1e18) * 4;
    uint256 private constant AMOUNT_CLAIM = 50 * 1e18;

    function setUp() public {
        // DeployAdminAirdrop deployer = new DeployAdminAirdrop();
        // (token, airdrop) = deployer.run();
        (admin, adminPrivKey) = makeAddrAndKey("admin");
        user = makeAddr("user");
        token = new GoldToken();
        airdrop = new AdminAirdrop(IERC20(address(token)), admin);
        token.mint(token.owner(), AMOUNT_MINT);
        token.transfer(address(airdrop), AMOUNT_MINT);
    }

    function testCheckAirdropBalance() public view {
        assertEq(token.balanceOf(address(airdrop)), AMOUNT_MINT);
    }

    function testCheckAdminAddress() public view {
        address adminAddress = airdrop.getAdminAddress();
        assertEq(adminAddress, address(admin));
    }
}
