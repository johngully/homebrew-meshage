# frozen_string_literal: true

# Meshage packages the stable FDA capture helper and upgradeable node together.
class Meshage < Formula
  desc "Personal iMessage history node for Meshage"
  homepage "https://github.com/johngully/homebrew-meshage"
  url "https://github.com/johngully/homebrew-meshage/releases/download/v0.1.0/meshage-0.1.0.tar.gz"
  version "0.1.0"
  sha256 "4e7529e3a980a42874b659fe00a8b1d130c0bb830060c51f184bcce166ccbd9f"
  license "MIT"

  bottle do
    root_url "https://github.com/johngully/homebrew-meshage/releases/download/v0.1.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe: "765e6cbc80b96bfa360d44939c1670ea685c3445c394c84852f13c0dd315c9c2"
  end

  depends_on "go" => :build
  depends_on arch: :arm64
  depends_on macos: :tahoe
  depends_on "syncthing"

  def install
    common = %w[-buildvcs=false -trimpath]
    system "go", "build", *common,
           "-ldflags", "-s -w -X main.version=#{version}",
           "-o", bin/"meshage", "./cmd/meshage"
    system "go", "build", *common,
           "-ldflags", "-s -w -X main.version=1",
           "-o", libexec/"meshage-capture", "./cmd/meshage-capture"
  end

  def post_install
    system bin/"meshage", "package-handoff"
  end

  def caveats
    <<~EOS
      Run `meshage setup` as the macOS user whose Messages history will be
      contributed. Setup creates two per-user LaunchAgents and stops at the
      manual Full Disk Access boundary for:

        ~/Library/Application Support/Meshage/bin/meshage-capture

      Before `brew uninstall meshage`, run `meshage uninstall` as that user so
      both LaunchAgents are removed. Bounded private state is preserved.
      Delete it only with the separately confirmed `meshage purge --local`.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/meshage version")
    assert_match "meshage-capture 1", shell_output("#{libexec}/meshage-capture version")
  end
end
