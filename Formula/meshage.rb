# frozen_string_literal: true

require "etc"
require "json"

class Meshage < Formula
  desc "Personal iMessage history node for Meshage"
  homepage "https://github.com/johngully/homebrew-meshage"
  url "https://github.com/johngully/homebrew-meshage/releases/download/v0.1.1/meshage-0.1.1.tar.gz"
  version "0.1.1"
  sha256 "9940bc538c803db1fe321bf092c78488c538070db435f2d21e37b6b58f95e0b4"
  license "MIT"

  bottle do
    root_url "https://github.com/johngully/homebrew-meshage/releases/download/v0.1.1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe: "baf0b7f074b98b0e562a051ca7b35bc9349a2fc681b5b073d8e64de504a401a9"
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

  test do
    identity = JSON.parse(shell_output("#{bin}/meshage version --json"))
    assert_equal({"version" => version.to_s, "source_revision" => "5f989761bd69b4069591127607b84bdce7878ab5"}, identity)
    assert_match "meshage-capture 1", shell_output("#{libexec}/meshage-capture version")
  end
end
