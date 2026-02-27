# Homebrew Install Fix Plan (`czerwix/ads-cli` + `czerwix/tap`)

## Goal

Make `brew tap/install/upgrade` for `ads-cli` work end-to-end right now with consistent ownership, versioning, release artifacts, and tap publication steps.

## Scope

- Documentation and release process alignment only.
- No product code changes.

## Step-by-step plan

1. Confirm the current release tag to treat as source of truth.
   - Determine latest release tag in `czerwix/ads-cli` (example: `v0.1.0`).
   - Use that exact tag for all references in formula/docs/checklists.
   - Command:

```bash
gh release view --repo czerwix/ads-cli --json tagName,name,publishedAt
```

2. Align formula version to the active release tag.
   - In tap formula (`czerwix/homebrew-tap`, `Formula/ads-cli.rb`), set `version` to tag without `v`.
   - Ensure URLs point to `https://github.com/czerwix/ads-cli/releases/download/v#{version}/...`.
   - Pull `checksums.txt` from the same release and update both arch `sha256` values.
   - Commands:

```bash
gh release download <tag> --repo czerwix/ads-cli --pattern checksums.txt --dir /tmp/ads-release-<tag>
cat /tmp/ads-release-<tag>/checksums.txt
```

3. Update owner consistency in docs and commands.
   - Replace stale owner/tap references (`skraus/...`) with `czerwix/...`.
   - Normalize user-facing install commands to:

```bash
brew tap czerwix/tap
brew install ads-cli
```

   - Files to align:
     - `README.md`
     - `docs/release-homebrew.md`
     - `docs/plans/2026-02-27-homebrew-release-runbook.md`

4. Ensure release workflow/docs runner consistency.
   - Check `.github/workflows/release.yml` matrix and artifact names.
   - Ensure docs mention the same runner split and archive names used by workflow.
   - Keep architecture mapping explicit:
     - Apple Silicon archive: `ads-macos-arm64.tar.gz`
     - Intel archive: `ads-macos-x86_64.tar.gz`
   - If runner labels change in workflow, update docs in the same PR.

5. Publish formula update to `czerwix/tap`.
   - Clone/update `czerwix/homebrew-tap` locally.
   - Edit `Formula/ads-cli.rb` with aligned version + checksums.
   - Commit and push formula change.
   - Commands:

```bash
git clone git@github.com:czerwix/homebrew-tap.git
cd homebrew-tap
$EDITOR Formula/ads-cli.rb
git add Formula/ads-cli.rb
git commit -m "ads-cli <version>"
git push
```

6. Validate Homebrew install and upgrade behavior.
   - Run from a clean local Homebrew state (or after `brew update`).
   - Validation commands:

```bash
brew update
brew untap czerwix/tap || true
brew tap czerwix/tap
brew install ads-cli
ads --help
brew upgrade ads-cli
ads --version
```

   - Success criteria:
     - Tap resolves without 404/auth errors.
     - Install downloads release artifact for host architecture.
     - `ads --help` exits successfully.
     - `brew upgrade ads-cli` has no formula/checksum errors.

## Rollback and troubleshooting

- If `brew install` fails with checksum mismatch:
  - Re-download `checksums.txt` from the exact release tag.
  - Re-check arch-specific SHA placement in formula.
- If `brew tap` fails:
  - Verify tap repo name/visibility and `Formula/ads-cli.rb` path.
  - Confirm default branch contains pushed formula commit.
- If artifact 404 occurs:
  - Confirm release assets exist for both architectures and names exactly match formula URLs.
- If docs drift from workflow:
  - Treat `.github/workflows/release.yml` as source of truth and patch docs immediately.
- Fast rollback option:
  - Revert last bad formula commit in `czerwix/homebrew-tap` and push.
  - Re-run `brew update && brew upgrade ads-cli` to confirm recovery.

## Done definition

- Docs and commands consistently use `czerwix/ads-cli` + `czerwix/tap`.
- Tap formula version and SHA values match the current release tag artifacts.
- `brew tap`, `brew install ads-cli`, `brew upgrade ads-cli`, and `ads --help` all pass locally.
