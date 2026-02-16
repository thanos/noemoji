class Noemoji < Formula
  desc "Remove emoji from files by glob pattern"
  homepage "https://github.com/thanos/noemoji"
  url "https://github.com/thanos/noemoji/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "034a247711182c7f4b9c055c4df3a4b21625d27b26f50e9e12bbec3a59431fce"  # To be filled when creating a release
  license "MIT"
  head "https://github.com/thanos/noemoji.git", branch: "main"

  depends_on "zig" => :build

  def install
    system "zig", "build", "-Doptimize=ReleaseFast", "--prefix", prefix
  end

  test do
    # Create a test file with emoji
    (testpath/"test.txt").write "Hello 👋 World 🌍"
    
    # Run noemoji on the test file
    system bin/"noemoji", testpath/"test.txt"
    
    # Verify emoji were removed
    output = (testpath/"test.txt").read
    assert_equal "Hello  World ", output
  end
end
