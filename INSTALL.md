# Installation Guide

Multiple ways to install noemoji on your system.

## Method 1: Direct Binary Installation (Recommended for Development)

The simplest method for local development and testing:

```bash
# Build optimized binary
zig build -Doptimize=ReleaseFast

# Option A: Install system-wide (requires sudo)
sudo cp zig-out/bin/noemoji /usr/local/bin/

# Option B: Install to user directory (no sudo)
mkdir -p ~/.local/bin
cp zig-out/bin/noemoji ~/.local/bin/

# Add to PATH (add to ~/.zshrc or ~/.bashrc to make permanent)
export PATH="$HOME/.local/bin:$PATH"

# Verify installation
noemoji --version
```

## Method 2: Homebrew Tap (For Distribution)

### Installing from a Published Tap

Once you've published your tap repository:

```bash
# Add the tap
brew tap thanos/tap

# Install noemoji
brew install noemoji

# Verify
noemoji --version
```

### Creating Your Own Tap Repository

1. **Create the tap repository on GitHub:**
   ```bash
   # Repository name must be: homebrew-tap (or homebrew-<tapname>)
   gh repo create thanos/homebrew-tap --public
   git clone https://github.com/thanos/homebrew-tap.git
   ```

2. **Add the formula:**
   ```bash
   cd homebrew-tap
   mkdir -p Formula
   cp /path/to/noemoji/noemoji.rb Formula/
   git add Formula/noemoji.rb
   git commit -m "Add noemoji formula"
   git push origin main
   ```

3. **Install from your tap:**
   ```bash
   brew tap thanos/tap
   brew install noemoji
   ```

### Testing Locally with a Local Tap

For testing the Homebrew formula locally:

```bash
# Create a local tap (Homebrew 5.0+ requirement)
brew tap-new local/tap

# Copy your formula to the tap
cp noemoji.rb $(brew --repository local/tap)/Formula/noemoji.rb

# Install from local tap
brew install local/tap/noemoji

# Test it works
noemoji --version

# Clean up when done
brew uninstall noemoji
brew untap local/tap
```

## Method 3: Download Prebuilt Binaries

Once you've created a release:

### macOS

```bash
# For Apple Silicon (M1/M2/M3)
curl -L https://github.com/thanos/noemoji/releases/download/v0.1.0/noemoji-0.1.0-macos-arm64.tar.gz | tar xz
cd noemoji-0.1.0-macos-arm64
sudo mv noemoji /usr/local/bin/

# For Intel Macs
curl -L https://github.com/thanos/noemoji/releases/download/v0.1.0/noemoji-0.1.0-macos-x86_64.tar.gz | tar xz
cd noemoji-0.1.0-macos-x86_64
sudo mv noemoji /usr/local/bin/
```

### Linux

```bash
# For x86_64
curl -L https://github.com/thanos/noemoji/releases/download/v0.1.0/noemoji-0.1.0-linux-x86_64.tar.gz | tar xz
cd noemoji-0.1.0-linux-x86_64
sudo mv noemoji /usr/local/bin/

# For ARM64
curl -L https://github.com/thanos/noemoji/releases/download/v0.1.0/noemoji-0.1.0-linux-arm64.tar.gz | tar xz
cd noemoji-0.1.0-linux-arm64
sudo mv noemoji /usr/local/bin/
```

### Windows

1. Download `noemoji-0.1.0-windows-x86_64.zip` from the releases page
2. Extract the archive
3. Add the directory to your PATH environment variable

Or use PowerShell:
```powershell
Invoke-WebRequest -Uri "https://github.com/thanos/noemoji/releases/download/v0.1.0/noemoji-0.1.0-windows-x86_64.zip" -OutFile "noemoji.zip"
Expand-Archive -Path "noemoji.zip" -DestinationPath "$env:USERPROFILE\bin"
# Add $env:USERPROFILE\bin to your PATH
```

## Method 4: Build from Source

If you have Zig installed:

```bash
# Clone the repository
git clone https://github.com/thanos/noemoji.git
cd noemoji

# Build optimized binary
zig build -Doptimize=ReleaseFast

# Install (choose one)
sudo cp zig-out/bin/noemoji /usr/local/bin/        # System-wide
cp zig-out/bin/noemoji ~/.local/bin/               # User-only
```

## Verifying Installation

After installation, verify it works:

```bash
# Check version
noemoji --version

# Test with a sample file
echo "Test 🎉 emoji" > test.txt
noemoji test.txt
cat test.txt  # Should show: "Test  emoji"
```

## Updating

### Homebrew

```bash
brew upgrade noemoji
```

### Manual Installation

```bash
# Download new binary or rebuild from source
# Then copy to the same location as before
```

## Uninstalling

### Homebrew

```bash
brew uninstall noemoji
brew untap thanos/tap  # Optional: remove the tap
```

### Manual Installation

```bash
# Remove the binary
sudo rm /usr/local/bin/noemoji
# or
rm ~/.local/bin/noemoji
```

## Troubleshooting

### "command not found: noemoji"

The binary is not in your PATH. Either:
- Move it to a directory in your PATH: `/usr/local/bin`, `/usr/bin`, `~/.local/bin`
- Add the directory to your PATH: `export PATH="/path/to/dir:$PATH"`

### "Permission denied"

The binary is not executable:
```bash
chmod +x /path/to/noemoji
```

### Homebrew 5.0+ Formula Error

Homebrew 5.0+ requires formulae to be in a tap. Use one of these methods:
- Create a local tap (see Method 2 above)
- Install the binary directly (see Method 1 above)
- Wait for the formula to be published to a tap

### "Cannot open because developer cannot be verified" (macOS)

macOS may block unsigned binaries:
```bash
xattr -d com.apple.quarantine /usr/local/bin/noemoji
```

Or go to System Settings → Privacy & Security and allow it.

## Platform-Specific Notes

### macOS

- Use Homebrew for easiest installation and updates
- Prebuilt binaries available for Intel and Apple Silicon
- May need to approve the binary in System Settings on first run

### Linux

- Binaries are statically linked (musl) for maximum compatibility
- Works on any Linux distribution
- Both x86_64 and ARM64 supported

### Windows

- Download the .zip file from releases
- Extract and add to PATH
- Or place noemoji.exe in a directory already in PATH

## Recommended Installation Methods by Use Case

| Use Case | Recommended Method |
|----------|-------------------|
| **Development/Testing** | Direct binary installation (Method 1) |
| **macOS Users** | Homebrew tap (Method 2) |
| **Linux Users** | Prebuilt binary (Method 3) or Homebrew |
| **Windows Users** | Prebuilt binary (Method 3) |
| **Building from Source** | Method 4 |
| **CI/CD** | Prebuilt binaries (Method 3) |
