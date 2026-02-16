class Noemoji < Formula
  desc "Remove emoji from files by glob pattern"
  homepage "https://github.com/thanos/noemoji"
  url "https://github.com/thanos/noemoji/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "72b30728f85025f97c8de3e0daefab326f0f7ee1605e61ff18d726292c4398cc"  # To be filled when creating a release
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
