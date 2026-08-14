# frozen_string_literal: true

require "json"

# Release-input template. Qualification renders every __MESHAGE_*__ token to
# exact candidate inputs before this formula becomes public.
class MeshageHub < Formula
  desc "Managed operator for a personal Meshage hub"
  homepage "https://github.com/johngully/homebrew-meshage"
  url "https://github.com/johngully/homebrew-meshage/releases/download/v0.1.1/meshage-hub-0.1.1.tar.gz"
  version "0.1.1"
  sha256 "9940bc538c803db1fe321bf092c78488c538070db435f2d21e37b6b58f95e0b4"
  license "MIT"

  bottle do
    root_url "https://github.com/johngully/homebrew-meshage/releases/download/v0.1.1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe: "6b5cd209f53412227da3124281b492299162a76443da422d09520f1d5b380d42"
  end

  depends_on "node" => :build
  depends_on arch: :arm64
  depends_on macos: :tahoe

  def install
    source_revision = (buildpath/"SOURCE_REVISION").read.strip
    system "node", "scripts/render-hub-package.mjs",
           "--output", buildpath/"managed-hub-package",
           "--version", version.to_s,
           "--source-revision", source_revision,
           "--source-url", "https://github.com/johngully/homebrew-meshage/releases/download/v0.1.1/meshage-hub-0.1.1.tar.gz",
           "--source-sha256", "9940bc538c803db1fe321bf092c78488c538070db435f2d21e37b6b58f95e0b4",
           "--bottle-root-url", "https://github.com/johngully/homebrew-meshage/releases/download/v0.1.1",
           "--bottle-sha256", "6b5cd209f53412227da3124281b492299162a76443da422d09520f1d5b380d42",
           "--hub-manifest-digest", "sha256:f43bce3b2222acd602365d5c446ad232750c1f94a1e597991f6faddcc9030df5",
           "--syncthing-manifest-digest", "sha256:4464f4161dd0251e20d46bb3aec83363db75d80cef1abdd5d5fd4054b04a004d"
    libexec.install Dir[buildpath/"managed-hub-package/{meshage-hub,compose.yaml,VERSION,SOURCE_REVISION,HUB_IMAGE}"]
    bin.install_symlink libexec/"meshage-hub"
  end

  def caveats
    <<~EOS
      Docker with Compose is required. Initialize the package-owned Meshage
      Compose project with `meshage-hub init`, then run `meshage-hub up` and
      `meshage-hub doctor`.

      Configure an AI host's MCP stdio command with the stable absolute path:
        #{opt_bin}/meshage-hub mcp

      Owner state is outside the package and is preserved by uninstall.
    EOS
  end

  test do
    identity = JSON.parse(shell_output("#{bin}/meshage-hub version --json"))
    assert_equal ["source_revision", "version"], identity.keys.sort
    assert_equal version.to_s, identity.fetch("version")
    assert_equal "5f989761bd69b4069591127607b84bdce7878ab5", identity.fetch("source_revision")
  end
end
