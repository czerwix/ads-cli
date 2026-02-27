# Homebrew Release Maintenance

Primary maintainer guide for publishing `ads` to Homebrew (`czerwix/tap`).

## Release automation source of truth

GitHub Actions handles packaging and upload for release assets in `.github/workflows/release.yml`:

- Trigger: push a tag matching `v*.*.*`.
- Build matrix: `macos-14` creates `ads-macos-arm64.tar.gz`, `macos-15-intel` creates `ads-macos-x86_64.tar.gz`.
- Release job: downloads both archives, generates `checksums.txt`, and uploads all artifacts to the GitHub release.

Do not create both architecture archives from one local build. The published release artifacts are produced by CI per-architecture.

## Local pre-tag verification

Run local checks only to verify code health before tagging:

1. Build and test:

```bash
swift build -c release
swift test
```

2. Smoke check the local binary:

```bash
.build/release/ads --help
.build/release/ads search "compose" --limit 1
```

## End-to-end release flow

1. Create and push a release tag:

```bash
git tag vX.Y.Z
git push origin vX.Y.Z
```

2. Wait for the `Release` workflow to complete for that tag.

3. Confirm the GitHub release contains:

- `ads-macos-arm64.tar.gz`
- `ads-macos-x86_64.tar.gz`
- `checksums.txt`

4. Get checksums from published release artifacts (never from arbitrary local rebuild files):

```bash
gh release download vX.Y.Z --repo czerwix/ads-cli --pattern checksums.txt --dir /tmp/ads-release-vX.Y.Z
cat /tmp/ads-release-vX.Y.Z/checksums.txt
```

If needed, you can also download both `ads-macos-*.tar.gz` artifacts from the same release and recompute checksums locally to cross-check, but `checksums.txt` from the published release is the canonical source.

5. Update `Formula/ads-cli.rb` in `czerwix/tap`:

- set `version "X.Y.Z"`
- set `sha256` values to the matching values from published `checksums.txt`

```bash
git clone git@github.com:czerwix/homebrew-tap.git
cd homebrew-tap
$EDITOR Formula/ads-cli.rb
git add Formula/ads-cli.rb
git commit -m "ads-cli vX.Y.Z"
git push
```

6. Verify install and upgrade from the tap:

```bash
brew update
brew tap czerwix/tap
brew install ads-cli
ads --help
brew upgrade ads-cli
ads --version
```

7. If verification fails, fix formula metadata/checksums in `czerwix/tap`, push again, and re-run the brew checks.
