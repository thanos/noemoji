const std = @import("std");
const emoji = @import("emoji");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print("Usage: noemoji <file>\n", .{});
        return;
    }

    const path = args[1];
    const cwd = std.fs.cwd();

    const data = try cwd.readFileAlloc(allocator, path, 10_000_000);
    defer allocator.free(data);

    const cleaned = try emoji.stripEmoji(allocator, data);
    defer allocator.free(cleaned);

    try cwd.writeFile(.{ .sub_path = path, .data = cleaned });
    std.debug.print("cleaned {s}\n", .{path});
}