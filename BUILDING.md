# Building noemoji

This document describes how to build noemoji from source and create release binaries.

## Prerequisites

- [Zig](https://ziglang.org/download/) 0.15.2 or later
- Git (for version tagging)
- Optional: [GitHub CLI](https://cli.github.com/) for automated releases

## Quick Build

### Development Build

```bash
zig build
./zig-out/bin/noemoji --help
```

### Optimized Build

```bash
zig build -Doptimize=ReleaseFast
```

### Run Tests

```bash
zig build test
```

## Building for Specific Platforms

Zig has excellent cross-compilation support. You can build for any target:

```bash
# macOS Intel
zig build -Doptimize=ReleaseFast -Dtarget=x86_64-macos

# macOS Apple Silicon
zig build -Doptimize=ReleaseFast -Dtarget=aarch64-macos

# Linux x86_64 (statically linked with musl)
zig build -Doptimize=ReleaseFast -Dtarget=x86_64-linux-musl

# Linux ARM64
zig build -Doptimize=ReleaseFast -Dtarget=aarch64-linux-musl

# Windows x86_64
zig build -Doptimize=ReleaseFast -Dtarget=x86_64-windows
```

## Creating Release Builds

### Automated Multi-Platform Builds

Use the provided script to build for all platforms at once:

```bash
./scripts/build-releases.sh 0.1.0
```

This will:
1. Build binaries for 5 platforms (macOS x86_64/ARM64, Linux x86_64/ARM64, Windows x86_64)
2. Create distribution archives (.tar.gz for Unix, .zip for Windows)
3. Generate SHA256 checksums
4. Place everything in the `releases/` directory

**Platforms included:**
- macOS x86_64 (Intel)
- macOS ARM64 (Apple Silicon)
- Linux x86_64 (musl, statically linked)
- Linux ARM64 (musl, statically linked)
- Windows x86_64

**Output structure:**
```
releases/
├── noemoji-0.1.0-macos-x86_64.tar.gz
├── noemoji-0.1.0-macos-arm64.tar.gz
├── noemoji-0.1.0-linux-x86_64.tar.gz
├── noemoji-0.1.0-linux-arm64.tar.gz
├── noemoji-0.1.0-windows-x86_64.zip
├── SHA256SUMS.txt
└── noemoji-0.1.0-*/
    ├── noemoji (or noemoji.exe)
    ├── README.md
    └── LICENSE
```

### Manual Upload to GitHub

```bash
# 1. Build releases
./scripts/build-releases.sh 0.1.0

# 2. Upload to GitHub (requires gh CLI)
./scripts/upload-release.sh 0.1.0
```

### Automated CI/CD with GitHub Actions

The repository includes a GitHub Actions workflow (`.github/workflows/release.yml`) that automatically:

1. Builds binaries for all platforms when you push a version tag
2. Creates a GitHub release
3. Uploads all artifacts
4. Generates installation instructions

**Usage:**
```bash
# Create and push a tag
git tag -a v0.1.0 -m "Release version 0.1.0"
git push origin v0.1.0

# GitHub Actions will automatically build and create the release
```

## Binary Sizes

With ReleaseFast optimization:

| Platform | Binary Size | Archive Size |
|----------|-------------|--------------|
| macOS x86_64 | 228 KB | 104 KB |
| macOS ARM64 | 232 KB | 92 KB |
| Linux x86_64 | 2.1 MB | 596 KB |
| Linux ARM64 | 2.1 MB | 580 KB |
| Windows x86_64 | 508 KB | 148 KB |

*Note: Linux binaries are statically linked with musl libc for maximum compatibility.*

## Optimization Modes

Zig provides several optimization modes:

```bash
# Debug (default) - Fastest compile, slowest runtime, includes debug info
zig build

# ReleaseSafe - Optimized but keeps safety checks
zig build -Doptimize=ReleaseSafe

# ReleaseFast - Maximum performance, minimal safety checks (recommended)
zig build -Doptimize=ReleaseFast

# ReleaseSmall - Optimizes for binary size
zig build -Doptimize=ReleaseSmall
```

## Cross-Compilation Notes

### Static Linking on Linux

The build script uses `musl` libc for Linux builds, which produces statically-linked binaries that work on any Linux distribution without dependencies.

### Windows Cross-Compilation

You can build Windows executables from macOS or Linux without needing Windows or MinGW installed. Zig includes everything needed.

### macOS Universal Binaries

To create a universal binary that works on both Intel and Apple Silicon:

```bash
# Build both architectures
zig build -Doptimize=ReleaseFast -Dtarget=x86_64-macos
cp zig-out/bin/noemoji noemoji-x86_64

zig build -Doptimize=ReleaseFast -Dtarget=aarch64-macos
cp zig-out/bin/noemoji noemoji-aarch64

# Combine with lipo (macOS only)
lipo -create noemoji-x86_64 noemoji-aarch64 -output noemoji-universal
```

## Verifying Builds

### Check Binary Information

```bash
# macOS/Linux
file zig-out/bin/noemoji
ldd zig-out/bin/noemoji  # Check dependencies (Linux)
otool -L zig-out/bin/noemoji  # Check dependencies (macOS)

# Windows (from Linux/macOS)
file zig-out/bin/noemoji.exe
```

### Verify Checksums

```bash
cd releases
sha256sum -c SHA256SUMS.txt  # Linux
shasum -a 256 -c SHA256SUMS.txt  # macOS
```

### Test the Binary

```bash
./zig-out/bin/noemoji --version
echo "Test  emoji " > test.txt
./zig-out/bin/noemoji test.txt
cat test.txt  # Should show: "Test  emoji "
```

## Troubleshooting

### "zig: command not found"

Install Zig from [ziglang.org](https://ziglang.org/download/) or use a package manager:

```bash
# macOS
brew install zig

# Linux (using asdf)
asdf plugin add zig
asdf install zig 0.15.2
asdf global zig 0.15.2
```

### Build Errors

```bash
# Clean build cache
rm -rf zig-cache zig-out

# Try building again
zig build
```

### GitHub Actions Failing

- Ensure the workflow file is in `.github/workflows/`
- Check that you've pushed the tag: `git push origin v0.1.0`
- Verify Actions are enabled in repository settings

## Development Workflow

```bash
# 1. Make changes
vim src/main.zig

# 2. Test locally
zig build test

# 3. Build optimized binary
zig build -Doptimize=ReleaseFast

# 4. Test the binary
./zig-out/bin/noemoji test-file.txt

# 5. Build all platforms
./scripts/build-releases.sh 0.1.0

# 6. Create release
git tag -a v0.1.0 -m "Release 0.1.0"
git push origin v0.1.0
./scripts/upload-release.sh 0.1.0
```

## Additional Resources

- [Zig Build System](https://ziglang.org/learn/build-system/)
- [Zig Cross-Compilation](https://ziglang.org/learn/overview/#cross-compiling-is-a-first-class-use-case)
- [GitHub Actions for Zig](https://github.com/goto-bus-stop/setup-zig)
