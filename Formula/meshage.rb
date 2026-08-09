# frozen_string_literal: true

require "etc"

# Meshage packages the stable FDA capture helper and upgradeable node together.
class Meshage < Formula
  desc "Personal iMessage history node for Meshage"
  homepage "https://github.com/johngully/homebrew-meshage"
  url "https://github.com/johngully/homebrew-meshage/releases/download/v0.1.0/meshage-0.1.0.tar.gz"
  version "0.1.0"
  sha256 "b2ac8e2fa46357a65e017b4d94c38564cd72c5e45fb2970fd9eb95327d523122"
  license "MIT"

  bottle do
    root_url "https://github.com/johngully/homebrew-meshage/releases/download/v0.1.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe: "9458fb8250147158ab918e26fc29216c9fc2258317d1b7c000762431a8ce4f66"
  end

  depends_on "go" => :build
  depends_on arch: :arm64
  depends_on macos: :tahoe
  depends_on "syncthing"

  def install
    common = %w[-buildvcs=false -trimpath]
    source_revision = (buildpath/"SOURCE_REVISION").read.strip
    system "go", "build", *common,
           "-ldflags", "-s -w -X main.version=#{version} -X main.sourceRevision=#{source_revision}",
           "-o", bin/"meshage", "./cmd/meshage"
    system "go", "build", *common,
           "-ldflags", "-s -w -X main.version=1 -X main.sourceRevision=#{source_revision}",
           "-o", libexec/"meshage-capture", "./cmd/meshage-capture"
  end

  def post_install
    system bin/"meshage", "package-handoff", "--home", Etc.getpwuid.dir
  end

  def caveats
    <<~EOS
      Run `meshage setup` as the macOS user whose Messages history will be
      contributed. Setup creates two per-user LaunchAgents and stops at the
      manual Full Disk Access boundary for:

        ~/Library/Application Support/Meshage/bin/meshage-capture

      Plain `brew uninstall meshage` retires the running per-user jobs and
      preserves bounded private state. Delete that state only with the
      separately confirmed `meshage purge --local` before removing the formula.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/meshage version")
    assert_match "meshage-capture 1", shell_output("#{libexec}/meshage-capture version")
  end
end
