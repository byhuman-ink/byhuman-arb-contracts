Smoke test for the boris-reviewer GitHub App.

If you can read this comment from `boris-reviewer [bot]` on the PR, the pipeline works end-to-end:

- GitHub App webhook -> SupportOS
- App installation token minted server-side
- OpenClaw agent posts the review as the App

Safe to close this PR after the bot comments.
