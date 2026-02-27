class AdsCli < Formula
  desc "CLI for searching and working with Google Docs"
  homepage "https://github.com/czerwix/ads-cli"
  version "0.1.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/czerwix/ads-cli/releases/download/v#{version}/ads-macos-arm64.tar.gz"
      sha256 "af00d0961a451a59ad54992463f6bea4a37b34b42f613d25e4804d6f01913b37"
    else
      url "https://github.com/czerwix/ads-cli/releases/download/v#{version}/ads-macos-x86_64.tar.gz"
      sha256 "dfc8b33fc4094fdd86e9caaf2a80c3506030feeaac51586ded2020f4c2c6154f"
    end
  end

  head "https://github.com/czerwix/ads-cli.git", branch: "main" do
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
