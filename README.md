# noemoji

Remove emoji from files by glob pattern.

## Installation

### Prebuilt Binaries

Download the latest release for your platform from the [releases page](https://github.com/thanos/noemoji/releases).

**Supported platforms:**
- macOS (Intel & Apple Silicon)
- Linux (x86_64 & ARM64)
- Windows (x86_64)

### Homebrew (macOS/Linux)

```bash
# Install from local formula (for development)
brew install --build-from-source ./noemoji.rb

# Or once published to a tap
brew tap thanos/tap
brew install noemoji
```

See [HOMEBREW.md](HOMEBREW.md) for detailed Homebrew installation instructions.

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
