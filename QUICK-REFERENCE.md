# Quick Reference Guide

## Build Commands

```bash
# Local development build
zig build

# Optimized build
zig build -Doptimize=ReleaseFast

# Run tests
zig build test

# Build for specific platform
zig build -Doptimize=ReleaseFast -Dtarget=x86_64-linux-musl
```

## Release Workflow

```bash
# 1. Build all platforms (creates releases/ directory)
./scripts/build-releases.sh 0.1.0

# 2. Upload to GitHub (requires gh CLI)
./scripts/upload-release.sh 0.1.0

# 3. Update Homebrew formula
./scripts/update-formula.sh 0.1.0
```

## GitHub Actions (Automated)

```bash
# Create and push tag - builds & releases automatically
git tag -a v0.1.0 -m "Release version 0.1.0"
git push origin v0.1.0
```

## Platform Targets

| Platform | Zig Target | Binary Size | Archive |
|----------|------------|-------------|---------|
| macOS Intel | `x86_64-macos` | 228 KB | .tar.gz |
| macOS ARM | `aarch64-macos` | 232 KB | .tar.gz |
| Linux x86_64 | `x86_64-linux-musl` | 2.1 MB | .tar.gz |
| Linux ARM64 | `aarch64-linux-musl` | 2.1 MB | .tar.gz |
| Windows | `x86_64-windows` | 508 KB | .zip |

## File Locations

```
scripts/
├── build-releases.sh    # Build all platforms
├── upload-release.sh    # Upload to GitHub
└── update-formula.sh    # Update Homebrew formula

.github/workflows/
└── release.yml          # GitHub Actions workflow

releases/                # Build output (gitignored)
├── *.tar.gz            # Unix archives
├── *.zip               # Windows archives
└── SHA256SUMS.txt      # Checksums

Documentation:
├── BUILDING.md          # Build guide
├── RELEASE.md           # Release process
├── HOMEBREW.md          # Homebrew setup
├── RELEASES-SUMMARY.md  # Implementation overview
└── QUICK-REFERENCE.md   # This file
```

## Common Tasks

### Test a Release Binary
```bash
./releases/noemoji-0.1.0-macos-arm64/noemoji test.txt
```

### Verify Checksums
```bash
cd releases
shasum -a 256 -c SHA256SUMS.txt
```

### Extract Archive
```bash
# Unix
tar -xzf noemoji-0.1.0-macos-arm64.tar.gz

# Windows
unzip noemoji-0.1.0-windows-x86_64.zip
```

### Install Locally
```bash
# macOS/Linux
sudo cp releases/noemoji-0.1.0-macos-arm64/noemoji /usr/local/bin/

# Or use Homebrew
brew install --build-from-source ./noemoji.rb
```

## Troubleshooting

### Build fails
```bash
# Clean and rebuild
rm -rf zig-cache zig-out releases
zig build
```

### GitHub Actions failing
```bash
# Check workflow logs
gh run list
gh run view <run-id>
```

### Upload script fails
```bash
# Ensure gh CLI is authenticated
gh auth status
gh auth login
```

## URLs to Update

Before first release, update these files with your GitHub username:

- `noemoji.rb` - Update repository URLs
- `.github/workflows/release.yml` - Check repository references
- `scripts/upload-release.sh` - Update tap name if needed
- Documentation - Update example URLs

Replace `thanos` with your username in:
- `https://github.com/thanos/noemoji`
- `brew tap thanos/tap`

## Documentation

| File | Purpose |
|------|---------|
| [BUILDING.md](BUILDING.md) | Comprehensive build instructions |
| [RELEASE.md](RELEASE.md) | Step-by-step release process |
| [HOMEBREW.md](HOMEBREW.md) | Homebrew installation & tap setup |
| [RELEASES-SUMMARY.md](RELEASES-SUMMARY.md) | Implementation overview |
| [README.md](README.md) | Project introduction & installation |

## Support Matrix

 macOS (Intel & Apple Silicon)  
 Linux (x86_64 & ARM64, static)  
 Windows (x86_64)  

All binaries use ReleaseFast optimization.
