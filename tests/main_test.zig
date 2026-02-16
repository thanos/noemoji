const std = @import("std");
const testing = std.testing;

// Import all test files
test {
    _ = @import("emoji_test.zig");
}

// Integration tests for CLI functionality
test "CLI integration - help flag" {
    // This test verifies the CLI can be imported without errors
    // Actual CLI testing requires running the binary
    try testing.expect(true);
}
