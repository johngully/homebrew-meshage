# frozen_string_literal: true

require "etc"
require "json"

class Meshage < Formula
  desc "Personal iMessage history node for Meshage"
  homepage "https://github.com/johngully/homebrew-meshage"
  url "https://github.com/johngully/homebrew-meshage/releases/download/v0.1.2/meshage-0.1.2.tar.gz"
  version "0.1.2"
  sha256 "cd4df35c090c60d02d5b7d2853a9060e0040adac4f2c4e5667e4a104984e14d3"
  license "MIT"

  bottle do
    root_url "https://github.com/johngully/homebrew-meshage/releases/download/v0.1.2"
    sha256 cellar: :any_skip_relocation, arm64_tahoe: "00149fcbbc9e969fcf23628d25d12b002109aa3f4344efc96cf439efd817b0f0"
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
