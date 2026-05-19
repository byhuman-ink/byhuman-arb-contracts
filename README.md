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

|          |                                                                                                                            |
| -------- | -------------------------------------------------------------------------------------------------------------------------- |
| Contract | `ReceiptRegistry`                                                                                                          |
| Address  | [`0xaaef72f5e32a238a2c91d04ab72bb7f1a2c22cd6`](https://sepolia.arbiscan.io/address/0xaaef72f5e32a238a2c91d04ab72bb7f1a2c22cd6) |
| Network  | Arbitrum Sepolia (chain id 421614)                                                                                         |

## Develop

```bash
forge build
forge test
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
