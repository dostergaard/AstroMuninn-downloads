class Astromuninn < Formula
  desc "AstroMuninn CLI for organizing astrophotography data"
  homepage "https://github.com/dostergaard/AstroMuninn-downloads"
  version "0.9.2"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/dostergaard/AstroMuninn-downloads/releases/download/v0.9.2/AstroMuninn-v0.9.2-macos-apple-silicon.tar.gz"
      sha256 "950893c98164554c0e96cff4472dc598c7692bdf09505f4fa850bdc15817a045"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/dostergaard/AstroMuninn-downloads/releases/download/v0.9.2/AstroMuninn-v0.9.2-linux-x86_64.tar.gz"
      sha256 "d8c3653d661c9756b8b707b7a4c0b51c4ddfdea5c891b95efccd5758848a1134"
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
