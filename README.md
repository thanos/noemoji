# noemoji

### For those without emotion... Remove emoji from from your files in cold blood.




<img width="640" height="640" alt="NoEmoji-lo" src="https://github.com/user-attachments/assets/4ba590c6-9474-4cc8-bead-9c4d6aa11daa" />





Right, why would I use your tool when I can use `sed`? Emoji are often sequences: , `codepoint + ZWJ + codepoint + ZWJ + ` ... `noemoji` handles this correctly. sed does not fully understand grapheme clusters. You could always use `Perl`
```
perl -CSDA -pi -e 's/\p{Extended_Pictographic}//g' **/*.md
```
I just find typing `noemoji` more fun!



## Installation

### Prebuilt Binaries

Download the latest release for your platform from the [releases page](https://github.com/thanos/noemoji/releases).

**Supported platforms:**
- macOS (Intel & Apple Silicon)
- Linux (x86_64 & ARM64)
- Windows (x86_64)

### Homebrew (macOS/Linux)

```bash
# Once published to a tap
brew tap thanos/tap
brew install noemoji
```

See [HOMEBREW.md](HOMEBREW.md) for detailed Homebrew installation instructions.

#### Local Development Testing

For local testing without Homebrew, just build and copy the binary:

```bash
zig build -Doptimize=ReleaseFast
sudo cp zig-out/bin/noemoji /usr/local/bin/
```

Or add to your PATH:

```bash
export PATH="$(pwd)/zig-out/bin:$PATH"
```

### Build from Source

```bash
zig build -Doptimize=ReleaseFast
# Binary will be at: zig-out/bin/noemoji
```

See [BUILDING.md](BUILDING.md) for comprehensive build instructions.

## Usage

```bash
noemoji "*.md"
noemoji "**/*.html"
noemoji --dry-run "**/*.md"
noemoji --backup "*.md"
noemoji --output-dir cleaned "**/*.html"
```
