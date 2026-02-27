# Homebrew Release Maintenance

This guide covers local checks and the end-to-end maintenance flow for publishing `ads` to Homebrew via `skraus/tap`.

## Important Note About Formula Checksums

`Formula/ads-cli.rb` currently contains placeholder SHA256 values for `v0.1.0`.

You must replace those placeholder SHA values after the first published GitHub release assets are available.

## Local Verification Checklist

Run these checks before cutting a release:

1. Swift release build check:

```bash
swift build -c release
```

2. `ads` binary smoke check:

```bash
.build/release/ads --help
.build/release/ads search "compose" --limit 1
```

3. Checksum generation verification (for release archives):

```bash
shasum -a 256 ads-macos-arm64.tar.gz
shasum -a 256 ads-macos-x86_64.tar.gz
```

## End-To-End Homebrew Release Flow

1. Build and package the two macOS archives for the GitHub release:

```bash
tar -czf ads-macos-arm64.tar.gz ads
tar -czf ads-macos-x86_64.tar.gz ads
```

2. Publish a GitHub release in `skraus/ads-cli` with tag `vX.Y.Z` and upload both archives.

3. Wait for release assets to finish uploading and become downloadable.

4. Generate SHA256 values from the final uploaded artifacts:

```bash
shasum -a 256 ads-macos-arm64.tar.gz
shasum -a 256 ads-macos-x86_64.tar.gz
```

5. Update `ads-cli.rb` in `skraus/tap`:

```bash
git clone git@github.com:skraus/homebrew-tap.git
cd homebrew-tap
$EDITOR Formula/ads-cli.rb
git add Formula/ads-cli.rb
git commit -m "ads-cli vX.Y.Z"
git push
```

6. Verify install and upgrade from the tap:

```bash
brew update
brew tap skraus/tap
brew install ads-cli
ads --help
brew upgrade ads-cli
ads --version
```

7. If verification fails, fix formula metadata/checksums in `skraus/tap`, push again, and re-run the brew checks.
