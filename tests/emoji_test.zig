const std = @import("std");
const emoji = @import("../src/emoji.zig");
const testing = std.testing;

// Test isEmoji function with various emoji ranges
test "isEmoji - emoticons range" {
    try testing.expect(emoji.isEmoji(0x1F600)); // 😀 grinning face
    try testing.expect(emoji.isEmoji(0x1F64F)); // 🙏 folded hands
    try testing.expect(!emoji.isEmoji(0x1F650)); // just outside range
}

test "isEmoji - misc symbols range" {
    try testing.expect(emoji.isEmoji(0x1F300)); // 🌀 cyclone
    try testing.expect(emoji.isEmoji(0x1F5FF)); // 🗿 moai
    try testing.expect(!emoji.isEmoji(0x1F2FF)); // just outside range
}

test "isEmoji - transport symbols" {
    try testing.expect(emoji.isEmoji(0x1F680)); // 🚀 rocket
    try testing.expect(emoji.isEmoji(0x1F6FF)); // end of range
}

test "isEmoji - supplemental symbols" {
    try testing.expect(emoji.isEmoji(0x1F900)); // 🤀 face with hand over mouth
    try testing.expect(emoji.isEmoji(0x1F9FF)); // 🧿 nazar amulet
}

test "isEmoji - flags" {
    try testing.expect(emoji.isEmoji(0x1F1E6)); // 🇦 regional indicator A
    try testing.expect(emoji.isEmoji(0x1F1FF)); // 🇿 regional indicator Z
}

test "isEmoji - variation selectors" {
    try testing.expect(emoji.isEmoji(0xFE00)); // variation selector
    try testing.expect(emoji.isEmoji(0xFE0F)); // variation selector-16
}

test "isEmoji - special characters" {
    try testing.expect(emoji.isEmoji(0x200D)); // zero width joiner
    try testing.expect(emoji.isEmoji(0x20E3)); // combining enclosing keycap
}

test "isEmoji - non-emoji characters" {
    try testing.expect(!emoji.isEmoji('a'));
    try testing.expect(!emoji.isEmoji('Z'));
    try testing.expect(!emoji.isEmoji('0'));
    try testing.expect(!emoji.isEmoji(' '));
    try testing.expect(!emoji.isEmoji('\n'));
}

// Test stripEmoji function
test "stripEmoji - single emoji" {
    const allocator = testing.allocator;
    const result = try emoji.stripEmoji(allocator, "hello 😀");
    defer allocator.free(result);
    try testing.expectEqualStrings("hello ", result);
}

test "stripEmoji - multiple emoji" {
    const allocator = testing.allocator;
    const result = try emoji.stripEmoji(allocator, "Test 👋 with 🎉 multiple 🌍 emoji");
    defer allocator.free(result);
    try testing.expectEqualStrings("Test  with  multiple  emoji", result);
}

test "stripEmoji - no emoji" {
    const allocator = testing.allocator;
    const result = try emoji.stripEmoji(allocator, "No emoji here");
    defer allocator.free(result);
    try testing.expectEqualStrings("No emoji here", result);
}

test "stripEmoji - only emoji" {
    const allocator = testing.allocator;
    const result = try emoji.stripEmoji(allocator, "😀🎉🌍");
    defer allocator.free(result);
    try testing.expectEqualStrings("", result);
}

test "stripEmoji - empty string" {
    const allocator = testing.allocator;
    const result = try emoji.stripEmoji(allocator, "");
    defer allocator.free(result);
    try testing.expectEqualStrings("", result);
}

test "stripEmoji - emoji at start" {
    const allocator = testing.allocator;
    const result = try emoji.stripEmoji(allocator, "🚀 Rocket launch");
    defer allocator.free(result);
    try testing.expectEqualStrings(" Rocket launch", result);
}

test "stripEmoji - emoji at end" {
    const allocator = testing.allocator;
    const result = try emoji.stripEmoji(allocator, "Great work 💯");
    defer allocator.free(result);
    try testing.expectEqualStrings("Great work ", result);
}

test "stripEmoji - consecutive emoji" {
    const allocator = testing.allocator;
    const result = try emoji.stripEmoji(allocator, "Hello 👋🌍🎉 World");
    defer allocator.free(result);
    try testing.expectEqualStrings("Hello  World", result);
}

test "stripEmoji - mixed unicode" {
    const allocator = testing.allocator;
    const result = try emoji.stripEmoji(allocator, "Zig 🦎 语言 🚀 test");
    defer allocator.free(result);
    try testing.expectEqualStrings("Zig  语言  test", result);
}

test "stripEmoji - various emoji types" {
    const allocator = testing.allocator;
    const input = "Faces 😀😃😄 Hearts ❤️💚💙 Symbols ✨🔥💡 Flags 🇺🇸🇬🇧";
    const result = try emoji.stripEmoji(allocator, input);
    defer allocator.free(result);
    // Should remove all emoji, keeping spaces and text
    try testing.expect(std.mem.indexOf(u8, result, "Faces") != null);
    try testing.expect(std.mem.indexOf(u8, result, "Hearts") != null);
    try testing.expect(std.mem.indexOf(u8, result, "Symbols") != null);
    try testing.expect(std.mem.indexOf(u8, result, "Flags") != null);
}

test "stripEmoji - newlines and tabs preserved" {
    const allocator = testing.allocator;
    const result = try emoji.stripEmoji(allocator, "Line1 🎉\nLine2\tTab 💯");
    defer allocator.free(result);
    try testing.expectEqualStrings("Line1 \nLine2\tTab ", result);
}

test "stripEmoji - very long string" {
    const allocator = testing.allocator;
    var input = std.ArrayList(u8).init(allocator);
    defer input.deinit();
    
    // Create a long string with emoji
    var i: usize = 0;
    while (i < 1000) : (i += 1) {
        try input.appendSlice("Text 🎉 ");
    }
    
    const result = try emoji.stripEmoji(allocator, input.items);
    defer allocator.free(result);
    
    // Should have "Text  " repeated 1000 times
    try testing.expect(result.len == 6 * 1000); // "Text  " is 6 chars
}