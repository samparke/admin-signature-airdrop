// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {GoldToken} from "./GoldToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract AdminAirdrop is EIP712 {
    using SafeERC20 for IERC20;

    error AdminAirDrop__UserAlreadyClaimed();
    error AdminAirdrop__InvalidSignature();

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    IERC20 private immutable i_goldToken;
    address private immutable admin;
    mapping(address account => bool claimed) private hasClaimed;
    bytes32 private constant MESSAGE_TYPE_HASH = keccak256("AirdropClaim(address account, uint256 amount)");

    event Claimed(address indexed account, uint256 amount);

    constructor(IERC20 token, address adminAddress) EIP712("AdminAirdrop", "1") {
        i_goldToken = token;
        admin = adminAddress;
    }

    /**
     *
     * @param account the account we are attempting to claim GoldToken's to
     * @param amount  the amount to claim
     * @param v each x-coordinate (r) has two possible y coordinates. The v identifies which one was used during signing, allowing the public key to be found
     * @param r the x-axis point on the curve
     * @param s derived from the message hash, private key and r
     */
    function claim(address account, uint256 amount, uint8 v, bytes32 r, bytes32 s) external {
        if (hasClaimed[account]) {
            revert AdminAirDrop__UserAlreadyClaimed();
        }
        if (!_isValidSignature(getMessageHash(account, amount), v, r, s)) {
            revert AdminAirdrop__InvalidSignature();
        }
        hasClaimed[account] = true;
        emit Claimed(account, amount);
        i_goldToken.safeTransfer(account, amount);
    }

    /**
     * @notice this function generates the EIP712 digest
     * It will be called:
     * - by the admin authorising a user to claim tokens. They will then sign the digest off-chain.
     * - the _isValidSignature function, which will retrieve the signer from the digest and signature
     * @param account the account who we are authorising to claim tokens
     * @param amount the amount they can claim
     * @return the digest of the EIP-712 message
     */
    function getMessageHash(address account, uint256 amount) public view returns (bytes32) {
        return
        // this functon is inherited from EIP712, which combines the hash of the message type and actual struct with the EIP712 domain separator
        _hashTypedDataV4(keccak256(abi.encode(MESSAGE_TYPE_HASH, AirdropClaim({account: account, amount: amount}))));
    }

    /**
     * @notice finds the actual signer who signed the digest with the v, r and s.
     * @param digest the hash from the getMessageHash. This is the EIP-712 message the admin would have signed to grant an address access to claiming tokens
     *  the v, r, s is the signature the user is passing into the claim function. If the user passed the correct signature,
     *  which signed a message which corresponds with the address and claim amount, it is valid.
     */
    function _isValidSignature(bytes32 digest, uint8 v, bytes32 r, bytes32 s) internal view returns (bool) {
        (address actualSigner,,) = ECDSA.tryRecover(digest, v, r, s);
        return (actualSigner == admin);
    }

    function getGoldTokenAddress() external view returns (address) {
        return address(i_goldToken);
    }

    function getAdminAddress() external view returns (address) {
        return admin;
    }
}
