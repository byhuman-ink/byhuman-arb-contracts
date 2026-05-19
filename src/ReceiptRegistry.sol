// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title  ReceiptRegistry
/// @notice Immutable, timestamped anchors for ByHuman writing-provenance receipts.
/// @dev    ByHuman issues an Ed25519-signed receipt for every writing session.
///         Anchoring a receipt's digest here proves the receipt existed and is
///         unaltered as of the recorded block — verifiable by anyone, without
///         trusting byhuman.ink.
///
///         This contract deliberately does NOT attest that the writing was done
///         by a human. That is the off-chain receipt's concern. The registry
///         provides only tamper-evidence and an independent, public timestamp.
contract ReceiptRegistry is Ownable {
    /// @notice Unix timestamp at which a receipt digest was first anchored.
    ///         Zero means the digest has never been anchored.
    mapping(bytes32 digest => uint256 timestamp) public anchoredAt;

    /// @notice Emitted once, when a receipt digest is first anchored.
    event ReceiptAnchored(bytes32 indexed digest, uint256 timestamp);

    /// @notice Thrown when anchoring a digest that has already been anchored.
    error AlreadyAnchored(bytes32 digest);

    /// @param initialOwner The ByHuman anchoring wallet — the only address
    ///        permitted to anchor receipts.
    constructor(address initialOwner) Ownable(initialOwner) {}

    /// @notice Anchor a receipt digest on-chain. First write wins; a digest
    ///         cannot be re-anchored or overwritten.
    /// @param  digest keccak256 of the canonical ByHuman receipt payload.
    function anchor(bytes32 digest) external onlyOwner {
        if (anchoredAt[digest] != 0) revert AlreadyAnchored(digest);
        anchoredAt[digest] = block.timestamp;
        emit ReceiptAnchored(digest, block.timestamp);
    }

    /// @notice Whether a receipt digest has been anchored.
    /// @param  digest keccak256 of the canonical ByHuman receipt payload.
    function isAnchored(bytes32 digest) external view returns (bool) {
        return anchoredAt[digest] != 0;
    }
}
