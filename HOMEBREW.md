# Homebrew Installation

## Installing from Local Formula

To install noemoji locally using Homebrew:

```bash
# Install directly from the formula file
brew install --build-from-source ./noemoji.rb

# Or create a local tap (recommended for development)
brew tap-new local/tap
brew extract --version=0.1.0 noemoji local/tap
cp noemoji.rb $(brew --repository local/tap)/Formula/noemoji.rb
brew install local/tap/noemoji
```

## Installing from GitHub (after release)

Once you've published a release on GitHub:

```bash
# Install from a custom tap
brew tap thanos/tap
brew install noemoji

# Or install directly from URL
brew install https://raw.githubusercontent.com/thanos/homebrew-tap/main/Formula/noemoji.rb
```

## Creating a Homebrew Tap

1. Create a new GitHub repository named `homebrew-tap` (or `homebrew-<tapname>`)
2. Add the `noemoji.rb` formula to the `Formula/` directory
3. Users can then install with: `brew tap thanos/tap && brew install noemoji`

## Updating the Formula for Releases

When creating a new release:

1. Create and push a git tag:
   ```bash
   git tag -a v0.1.0 -m "Release v0.1.0"
   git push origin v0.1.0
   ```

2. GitHub will automatically create a tarball at:
   `https://github.com/thanos/noemoji/archive/refs/tags/v0.1.0.tar.gz`

3. Calculate the SHA256 hash:
   ```bash
   curl -sL https://github.com/thanos/noemoji/archive/refs/tags/v0.1.0.tar.gz | shasum -a 256
   ```

4. Update the `sha256` field in `noemoji.rb` with the hash

5. Test the formula:
   ```bash
   brew install --build-from-source ./noemoji.rb
   brew test noemoji
   brew audit --strict noemoji.rb
   ```

## Formula Structure

The formula includes:
- **desc**: Short description of the tool
- **homepage**: Project homepage/repository URL
- **url**: Download URL for the source tarball
- **sha256**: Checksum for integrity verification
- **license**: Software license
- **depends_on**: Build and runtime dependencies
- **install**: Build and installation instructions
- **test**: Automated tests to verify the installation

## Testing the Formula

```bash
# Test the formula works
brew test noemoji

# Audit the formula for best practices
brew audit --strict noemoji.rb

# Try installing in verbose mode
brew install --build-from-source --verbose ./noemoji.rb
```
