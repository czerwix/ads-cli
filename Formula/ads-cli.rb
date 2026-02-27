class AdsCli < Formula
  desc "CLI for searching and working with Google Docs"
  homepage "https://github.com/skraus/ads-cli"
  version "0.1.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/skraus/ads-cli/releases/download/v#{version}/ads-macos-arm64.tar.gz"
      sha256 "1111111111111111111111111111111111111111111111111111111111111111" # TODO: Replace with real arm64 release checksum after publishing v#{version} assets.
    else
      url "https://github.com/skraus/ads-cli/releases/download/v#{version}/ads-macos-x86_64.tar.gz"
      sha256 "2222222222222222222222222222222222222222222222222222222222222222" # TODO: Replace with real x86_64 release checksum after publishing v#{version} assets.
    end
  end

  head "https://github.com/skraus/ads-cli.git", branch: "main" do
    depends_on "swift" => :build
  end

  def install
    if build.head?
      system "swift", "build", "-c", "release"
      bin.install ".build/release/ads"
    else
      bin.install "ads"
    end
  end

  test do
    system "#{bin}/ads", "--help"
  end
end
