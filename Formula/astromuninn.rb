class Astromuninn < Formula
  desc "AstroMuninn CLI for organizing astrophotography data"
  homepage "https://github.com/dostergaard/AstroMuninn-downloads"
  version "0.11.0"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/dostergaard/AstroMuninn-downloads/releases/download/v0.11.0/AstroMuninn-CLI-v0.11.0-macos-apple-silicon.tar.gz"
      sha256 "a9521bbd0813f174b07129f7fde26257a4e5d2f349678d56b9270527170e2bfc"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/dostergaard/AstroMuninn-downloads/releases/download/v0.11.0/AstroMuninn-CLI-v0.11.0-linux-x86_64.tar.gz"
      sha256 "12c4b41e7657c661eec68c8f740e0bd22ce807640d108e2547b2551855681a10"
    end
  end

  def install
    binary = Dir["**/astromuninn"].first
    raise "Unable to locate astromuninn in extracted archive" unless binary

    bin.install binary
  end

  test do
    assert_match "AstroMuninn", shell_output("#{bin}/astromuninn --help")
  end
end
