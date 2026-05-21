# byhuman-arb-contracts

On-chain anchoring contracts for [ByHuman](https://byhuman.ink) — the Arbitrum
backend for ByHuman's writing-provenance receipts.

## `ReceiptRegistry`

ByHuman issues an Ed25519-signed receipt for every writing session (see
[`@byhuman/provenance-core`](https://github.com/byhuman-ink/provenance-core)).
`ReceiptRegistry` anchors a `keccak256` digest of each receipt on-chain, so a
receipt becomes:

- **tamper-evident** — the on-chain digest is immutable;
- **independently timestamped** — the block timestamp proves the receipt
  existed by then;
- **verifiable without trusting byhuman.ink** — anyone holding the receipt
  JSON computes the digest and reads the contract directly.

It deliberately does **not** attest that the writing was done by a human —
that is the off-chain receipt's concern. The registry provides only
tamper-evidence and an independent, public timestamp.

## Deployment — Arbitrum Sepolia

|          |                                                                                                                               |
| -------- | ----------------------------------------------------------------------------------------------------------------------------- |
| Contract | `ReceiptRegistry`                                                                                                             |
| Address  | [`0xaaef72f5e32a238a2c91d04ab72bb7f1a2c22cd6`](https://sepolia.arbiscan.io/address/0xaaef72f5e32a238a2c91d04ab72bb7f1a2c22cd6) |
| Network  | Arbitrum Sepolia (chain id 421614)                                                                                            |
| Live     | A live anchored receipt is shown on any [byhuman.ink/p/&lt;id&gt;](https://byhuman.ink) proof page.                           |

## Verify a receipt against this contract

This is the whole point: anyone holding a ByHuman receipt JSON can confirm the
receipt is unaltered and was on-chain by a specific block — **without trusting
byhuman.ink**.

1. **Compute the receipt's digest.** It is `keccak256` of the RFC 8785
   canonical JSON of the receipt object — exactly what the
   [`@byhuman/provenance-core`](https://github.com/byhuman-ink/provenance-core)
   `canonicalize` function emits. In code:

   ```ts
   import { canonicalize } from "@byhuman/provenance-core";
   import { keccak256, stringToBytes } from "viem";
   const digest = keccak256(stringToBytes(canonicalize(receipt)));
   ```

   Each proof page also displays the digest directly, so you can skip step 1
   and trust-but-verify the digest later.

2. **Read the on-chain timestamp.** A non-zero return value is the Unix
   timestamp of the block in which the digest was first anchored:

   ```bash
   cast call 0xaaef72f5e32a238a2c91d04ab72bb7f1a2c22cd6 \
     "anchoredAt(bytes32)(uint256)" "$DIGEST" \
     --rpc-url https://sepolia-rollup.arbitrum.io/rpc
   ```

3. **That's the proof.** A non-zero timestamp + matching digest = the receipt
   existed in this exact form by that block. Zero = never anchored.

There's nothing else to trust. The contract has no upgrade path, no admin
overrides on `anchoredAt`, and first-write-wins on `anchor` — see *Surface*
below.

## Surface

| Symbol                                       | Kind     | Notes                                                                            |
| -------------------------------------------- | -------- | -------------------------------------------------------------------------------- |
| `anchoredAt(bytes32 digest) → uint256`       | view     | Unix timestamp of the anchor block, or `0` if never anchored.                    |
| `isAnchored(bytes32 digest) → bool`          | view     | Convenience: `anchoredAt(digest) != 0`.                                          |
| `anchor(bytes32 digest)`                     | onlyOwner | First-write-wins. Reverts `AlreadyAnchored(digest)` on re-anchor.                |
| `event ReceiptAnchored(bytes32 indexed digest, uint256 timestamp)` | event | Emitted on first anchor.                                                         |

The owner is the ByHuman anchoring wallet (set at deployment via OpenZeppelin
`Ownable`). It is the only address permitted to `anchor`. There is no other
privileged surface — `anchoredAt` is a plain public mapping, the owner cannot
overwrite it, and there is no `pause`, `upgrade`, or `withdraw`.

## Develop

```bash
forge build
forge test     # 6 tests covering anchor, lookup, ownership, replay rejection
```

## Deploy

```bash
forge script script/Deploy.s.sol:Deploy \
  --rpc-url https://sepolia-rollup.arbitrum.io/rpc \
  --private-key "$ANCHOR_WALLET_PRIVATE_KEY" \
  --broadcast
```

The deploying wallet becomes the contract owner — the only address permitted
to `anchor`.

## Context

- [`byhuman`](https://github.com/byhuman-ink/byhuman) — the ByHuman web app.
- [`provenance-core`](https://github.com/byhuman-ink/provenance-core) — the
  pure-TypeScript provenance domain logic.
- This repo is the Arbitrum anchoring backend. The web app talks to it through
  a chain-agnostic `Anchorer` interface, so the chain is swappable.

Built for the Arbitrum Open House London Online Buildathon.

## License

MIT
