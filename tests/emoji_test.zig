const std = @import("std");
const emoji = @import("../src/emoji.zig");

test "strip emoji" {
    const allocator = std.testing.allocator;
    const result = try emoji.stripEmoji(allocator, "hello 😀");
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello ", result);
}