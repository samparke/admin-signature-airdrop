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
    address claimer;
    uint256 claimerPrivKey;
    GoldToken token;
    AdminAirdrop airdrop;
    uint256 private constant AMOUNT_MINT = (50 * 1e18) * 4;
    uint256 private constant AMOUNT_CLAIM = 50 * 1e18;

    function setUp() public {
        // DeployAdminAirdrop deployer = new DeployAdminAirdrop();
        // (token, airdrop) = deployer.run();
        (admin, adminPrivKey) = makeAddrAndKey("admin");
        (claimer, claimerPrivKey) = makeAddrAndKey("claimer");

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

    function testAdminGrantsClaimerTokens() public {
        uint256 startingClaimerBalance = token.balanceOf(claimer);
        assertEq(startingClaimerBalance, 0);
        bytes32 digest = airdrop.getMessageHash(claimer, AMOUNT_CLAIM);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(adminPrivKey, digest);

        vm.prank(claimer);
        airdrop.claim(claimer, AMOUNT_CLAIM, v, r, s);

        uint256 endingClaimerBalance = token.balanceOf(claimer);
        assertEq(endingClaimerBalance, AMOUNT_CLAIM);
    }

    function testClaimerAttemptsToClaimTwice() public {
        bytes32 digest = airdrop.getMessageHash(claimer, AMOUNT_CLAIM);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(adminPrivKey, digest);
        vm.prank(claimer);
        airdrop.claim(claimer, AMOUNT_CLAIM, v, r, s);

        vm.prank(claimer);
        vm.expectRevert(AdminAirdrop.AdminAirDrop__UserAlreadyClaimed.selector);
        airdrop.claim(claimer, AMOUNT_CLAIM, v, r, s);
    }

    function testInvalidSignatureRevert() public {
        bytes32 digest = airdrop.getMessageHash(claimer, AMOUNT_CLAIM);
        // this will product an invalid signature, as the signature needs to be admin
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(claimerPrivKey, digest);

        vm.prank(claimer);
        vm.expectRevert(AdminAirdrop.AdminAirdrop__InvalidSignature.selector);
        airdrop.claim(claimer, AMOUNT_CLAIM, v, r, s);
    }

    function testGetToken() public view {
        assertEq(address(token), airdrop.getGoldTokenAddress());
    }
}
