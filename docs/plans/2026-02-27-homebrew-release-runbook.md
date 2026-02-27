# Homebrew Release Runbook (Checklist)

Concise execution checklist. The full process and rationale live in `docs/release-homebrew.md` (primary source).

## Release checklist

1. Run local pre-tag checks from `docs/release-homebrew.md`.
2. Create and push release tag `vX.Y.Z`.
3. Wait for `.github/workflows/release.yml` (`Release`) to finish.
4. Confirm release assets include both architecture archives and `checksums.txt`.
5. Update `Formula/ads-cli.rb` in `skraus/tap` using checksums from published release artifacts (`checksums.txt`).
6. Commit and push tap formula update.
7. Verify `brew install ads-cli` and `brew upgrade ads-cli`.

## First release note (`v0.1.0`)

`v0.1.0` used placeholder formula SHA values during preparation. Replace them with checksums from the published release artifacts before publishing the tap formula.
