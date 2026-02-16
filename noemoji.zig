const std = @import("std");

const Allocator = std.mem.Allocator;

/// Emoji Unicode ranges (based on Unicode emoji blocks)
/// This is a practical superset used by most emoji
fn isEmoji(cp: u21) bool {
    return
        // Emoticons
        (cp >= 0x1F600 and cp <= 0x1F64F) or

        // Misc symbols and pictographs
        (cp >= 0x1F300 and cp <= 0x1F5FF) or

        // Transport and map
        (cp >= 0x1F680 and cp <= 0x1F6FF) or

        // Supplemental symbols
        (cp >= 0x1F900 and cp <= 0x1F9FF) or

        // Symbols & pictographs extended
        (cp >= 0x1FA70 and cp <= 0x1FAFF) or

        // Dingbats
        (cp >= 0x2700 and cp <= 0x27BF) or

        // Misc symbols
        (cp >= 0x2600 and cp <= 0x26FF) or

        // Flags
        (cp >= 0x1F1E6 and cp <= 0x1F1FF) or

        // Variation selectors
        (cp >= 0xFE00 and cp <= 0xFE0F) or

        // Zero width joiner
        cp == 0x200D;
}

/// Remove emoji from UTF-8 string
fn stripEmoji(allocator: Allocator, input: []const u8) ![]u8 {
    var output = std.ArrayList(u8).init(allocator);
    defer output.deinit();

    var i: usize = 0;

    while (i < input.len) {
        const cp = try std.unicode.utf8Decode(input[i..]);

        if (!isEmoji(cp.codepoint)) {
            try std.unicode.utf8Encode(cp.codepoint, &output);
        }

        i += cp.len;
    }

    return output.toOwnedSlice();
}

fn processFile(allocator: Allocator, path: []const u8) !void {
    const cwd = std.fs.cwd();

    const data = try cwd.readFileAlloc(allocator, path, 10 * 1024 * 1024);
    defer allocator.free(data);

    const cleaned = try stripEmoji(allocator, data);
    defer allocator.free(cleaned);

    if (!std.mem.eql(u8, data, cleaned)) {
        try cwd.writeFile(.{
            .sub_path = path,
            .data = cleaned,
        });

        std.debug.print("cleaned {s}\n", .{path});
    }
}

fn matchesPattern(path: []const u8, pattern: []const u8) bool {
    return std.fs.path.match(pattern, path) catch false;
}

fn walkAndProcess(
    allocator: Allocator,
    dir: std.fs.Dir,
    base_path: []const u8,
    pattern: []const u8,
) !void {
    var it = dir.walk(allocator);
    defer it.deinit();

    while (try it.next()) |entry| {
        if (entry.kind != .file) continue;

        const full_path = try std.fs.path.join(
            allocator,
            &.{ base_path, entry.path },
        );
        defer allocator.free(full_path);

        if (matchesPattern(entry.path, pattern)) {
            try processFile(allocator, full_path);
        }
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print(
            "Usage:\n  noemoji *.md\n  noemoji **/*.html\n",
            .{},
        );
        return;
    }

    const pattern = args[1];

    const cwd = std.fs.cwd();

    try walkAndProcess(
        allocator,
        cwd,
        ".",
        pattern,
    );
}
