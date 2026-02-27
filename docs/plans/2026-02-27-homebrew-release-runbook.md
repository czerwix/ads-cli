# Homebrew First Release Runbook (v0.1.0)

Runbook for the first Homebrew-backed release of `skraus/ads-cli` using `skraus/tap`.

## 1) Verify Local Build And Binary

```bash
swift build -c release
.build/release/ads --help
```

## 2) Package Release Artifacts

From the release binary directory, create archives named to match the formula URLs:

```bash
tar -czf ads-macos-arm64.tar.gz ads
tar -czf ads-macos-x86_64.tar.gz ads
```

## 3) Tag And Publish `v0.1.0`

```bash
git tag v0.1.0
git push origin v0.1.0
```

Create a GitHub release for `v0.1.0` in `skraus/ads-cli` and upload:

- `ads-macos-arm64.tar.gz`
- `ads-macos-x86_64.tar.gz`

## 4) Wait For Release Assets

Wait until both uploaded assets are visible and downloadable on the published `v0.1.0` release page.

## 5) Copy SHA256 Values Into Tap Formula

Download or use the exact release artifacts and compute checksums:

```bash
shasum -a 256 ads-macos-arm64.tar.gz
shasum -a 256 ads-macos-x86_64.tar.gz
```

Update `Formula/ads-cli.rb` in `skraus/tap`:

- set `version "0.1.0"`
- replace both placeholder `sha256` values with the real checksums from release assets

Commit and push the formula change in `skraus/tap`.

## 6) Test Homebrew Install

```bash
brew update
brew tap skraus/tap
brew install ads-cli
ads --help
```

Optional upgrade-path verification if `ads-cli` is already installed:

```bash
brew upgrade ads-cli
ads --version
```

## 7) Post-Release Check

Confirm the formula install resolves to `skraus/tap` and the binary runs expected commands.
