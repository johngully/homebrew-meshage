# frozen_string_literal: true

require "etc"

# Meshage packages the stable FDA capture helper and upgradeable node together.
class Meshage < Formula
  desc "Personal iMessage history node for Meshage"
  homepage "https://github.com/johngully/homebrew-meshage"
  url "https://github.com/johngully/homebrew-meshage/releases/download/v0.1.0/meshage-0.1.0.tar.gz?revision=e4c467ae602ae50f050c9a2700d5d3d4cdc84036&asset=canonical-e4c467a"
  version "0.1.0"
  sha256 "53c70685799224dd3c14e1d8726e92f89ce5b74fc50d374ba7732f2da6e82617"
  license "MIT"

  bottle do
    root_url "https://github.com/johngully/homebrew-meshage/releases/download/v0.1.0"
    rebuild 5
    sha256 cellar: :any_skip_relocation, arm64_tahoe: "eafca50dfe022006feb1d43eb0336066f8f8c6d3cf6dc5e97b1a4b81bfedec1e"
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

      Before removing the package, run `meshage uninstall` to retire both
      per-user jobs while preserving bounded private state and Messages. Then
      run `brew uninstall meshage`. Delete private state only with the
      separately confirmed `meshage purge --local`.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/meshage version")
    assert_match "meshage-capture 1", shell_output("#{libexec}/meshage-capture version")
  end
end
