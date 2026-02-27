class AdsCli < Formula
  desc "CLI for searching and working with Google Docs"
  homepage "https://github.com/czerwix/ads-cli"
  version "0.1.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/czerwix/ads-cli/releases/download/v#{version}/ads-macos-arm64.tar.gz"
      sha256 "c136d0829aad4c7451ba79ae4d692f500047b8dbba02a1b7040dce8ab5909fee"
    else
      url "https://github.com/czerwix/ads-cli/releases/download/v#{version}/ads-macos-x86_64.tar.gz"
      sha256 "f87fc80d69ebe941e4f75a498d6890115aa3d02baf4d61ee5728841dc0436012"
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
