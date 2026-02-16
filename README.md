# noemoji


<img width="400" height="400" alt="NoEmoji-lo" src="https://github.com/user-attachments/assets/4ba590c6-9474-4cc8-bead-9c4d6aa11daa" />

For those without emotion… 🧊
Eliminate every emoji 😐🚫 from your files 📁📄
with surgical precision 🧬🔪
and cold, merciless efficiency ❄️⚙️
— leaving nothing behind but pure, silent text ⌨️⬛



__Q__: Right, why would I use your tool when I can use `sed`? 

__A__: Emoji are often sequences: For eample, 👨‍👩‍👧‍👦, `codepoint + ZWJ + codepoint + ZWJ + ` ... `noemoji` handles these cases correctly. `sed` does not fully understand grapheme clusters. Of course, you could always use `Perl`
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
