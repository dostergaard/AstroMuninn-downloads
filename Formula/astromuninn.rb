class Astromuninn < Formula
  desc "AstroMuninn CLI for organizing astrophotography data"
  homepage "https://github.com/dostergaard/AstroMuninn-downloads"
  version "0.10.0"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/dostergaard/AstroMuninn-downloads/releases/download/v0.10.0/AstroMuninn-CLI-v0.10.0-macos-apple-silicon.tar.gz"
      sha256 "8abdcbe942ee4a8fe9241283f0f9d82305b98361185693920ae205b1d9a5a709"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/dostergaard/AstroMuninn-downloads/releases/download/v0.10.0/AstroMuninn-CLI-v0.10.0-linux-x86_64.tar.gz"
      sha256 "b8322df39710302e929cfec3608cc070fd2d681ad4830158cb124855574f5787"
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
