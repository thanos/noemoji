const std = @import("std");

pub fn isEmoji(cp: u21) bool {
    return
        (cp >= 0x1F600 and cp <= 0x1F64F) or
        (cp >= 0x1F300 and cp <= 0x1F5FF) or
        (cp >= 0x1F680 and cp <= 0x1F6FF) or
        (cp >= 0x1F900 and cp <= 0x1F9FF) or
        (cp >= 0x1FA70 and cp <= 0x1FAFF) or
        (cp >= 0x2700 and cp <= 0x27BF) or
        (cp >= 0x2600 and cp <= 0x26FF) or
        (cp >= 0x1F1E6 and cp <= 0x1F1FF) or
        (cp >= 0xFE00 and cp <= 0xFE0F) or
        (cp == 0x200D) or
        (cp == 0x20E3);
}

pub fn stripEmoji(allocator: std.mem.Allocator, input: []const u8) ![]u8 {
    var out: std.ArrayList(u8) = .empty;
    defer out.deinit(allocator);

    var i: usize = 0;
    while (i < input.len) {
        const len = std.unicode.utf8ByteSequenceLength(input[i]) catch {
            try out.append(allocator, input[i]);
            i += 1;
            continue;
        };

        const codepoint = std.unicode.utf8Decode(input[i .. i + len]) catch {
            try out.append(allocator, input[i]);
            i += 1;
            continue;
        };

        if (!isEmoji(codepoint)) {
            var buf: [4]u8 = undefined;
            const n = std.unicode.utf8Encode(codepoint, &buf) catch unreachable;
            try out.appendSlice(allocator, buf[0..n]);
        }
        i += len;
    }

    return out.toOwnedSlice(allocator);
}