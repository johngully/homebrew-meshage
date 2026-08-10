# frozen_string_literal: true

require "etc"

# Meshage packages the stable FDA capture helper and upgradeable node together.
class Meshage < Formula
  desc "Personal iMessage history node for Meshage"
  homepage "https://github.com/johngully/homebrew-meshage"
  url "https://github.com/johngully/homebrew-meshage/releases/download/v0.1.0/meshage-0.1.0.tar.gz?revision=fe6284a6d696d09c6a28c8f92c3b6baa0f72dc6c&asset=canonical-fe6284a"
  version "0.1.0"
  sha256 "1c95a3ad7a930ee359b678a08e99f5fe99233d94ebfe507a6d4cb9bad091b0eb"
  license "MIT"

  bottle do
    root_url "https://github.com/johngully/homebrew-meshage/releases/download/v0.1.0"
    rebuild 2
    sha256 cellar: :any_skip_relocation, arm64_tahoe: "c10fd9807d75d9e062f910cead3969663422c81173dd2b6f99fb4f99951cce65"
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
