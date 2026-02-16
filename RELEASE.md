# Release Process

## Creating a New Release

### 1. Prepare the Release

```bash
# Ensure all tests pass
zig build test

# Build optimized binary
zig build -Doptimize=ReleaseFast

# Test the binary
./zig-out/bin/noemoji test_file.txt
```

### 2. Create and Push Git Tag

```bash
# Update version in build.zig.zon if needed
# Commit any pending changes
git add .
git commit -m "Prepare release v0.1.0"

# Create annotated tag
git tag -a v0.1.0 -m "Release version 0.1.0"

# Push tag to remote
git push origin v0.1.0
```

### 3. Build Release Binaries

Build prebuilt binaries for all platforms:

```bash
./scripts/build-releases.sh 0.1.0
```

This creates optimized binaries for:
- macOS (Intel + Apple Silicon)
- Linux (x86_64 + ARM64)
- Windows (x86_64)

All with SHA256 checksums in `releases/`.

### 4. Upload to GitHub

**Option A: Automated (using gh CLI)**
```bash
./scripts/upload-release.sh 0.1.0
```

**Option B: GitHub Actions (automatic on tag push)**
```bash
# Just push the tag, GitHub Actions handles the rest
git push origin v0.1.0
```

**Option C: Manual via GitHub Web UI**
1. Go to GitHub repository → Releases → Draft a new release
2. Choose tag `v0.1.0`
3. Upload all files from `releases/` directory
4. Publish release

### 5. Update Homebrew Formula

Once the tag is pushed, GitHub automatically creates a release tarball.

**Option A: Automated (using the script)**
```bash
./scripts/update-formula.sh 0.1.0
```

**Option B: Manual**
```bash
# Download and hash the tarball
curl -sL https://github.com/thanos/noemoji/archive/refs/tags/v0.1.0.tar.gz | shasum -a 256

# Update noemoji.rb with:
# - The correct URL
# - The calculated SHA256 hash
```

### 4. Test the Formula

```bash
# Install from formula
brew install --build-from-source ./noemoji.rb

# Run formula tests
brew test noemoji

# Test the installed binary
noemoji --help
echo "Test  emoji" > test.txt
noemoji test.txt
cat test.txt  # Should show: "Test  emoji"

# Uninstall
brew uninstall noemoji
```

### 5. Publish to Homebrew Tap

If you have a homebrew-tap repository:

```bash
# Copy formula to tap repository
cp noemoji.rb /path/to/homebrew-tap/Formula/

# Commit and push
cd /path/to/homebrew-tap
git add Formula/noemoji.rb
git commit -m "noemoji: add version 0.1.0"
git push origin main
```

### 6. Announce the Release

Users can now install with:
```bash
brew tap thanos/tap
brew install noemoji
```

## Release Checklist

- [ ] All tests pass (`zig build test`)
- [ ] ReleaseFast build succeeds
- [ ] Version bumped in `build.zig.zon`
- [ ] CHANGELOG.md updated (if you have one)
- [ ] Git tag created and pushed
- [ ] Homebrew formula SHA256 updated
- [ ] Formula tested locally
- [ ] Formula pushed to tap repository
- [ ] Release notes created on GitHub
- [ ] Documentation updated

## Binary Size Reference

- Debug build: ~1.3 MB
- ReleaseFast build: ~228 KB

## Supported Platforms

The Homebrew formula will build noemoji for:
- macOS (Intel and Apple Silicon)
- Linux (x86_64, ARM64)

Zig will cross-compile for the target platform automatically.
