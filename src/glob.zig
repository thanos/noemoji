const std = @import("std");

pub fn matchPath(_: std.mem.Allocator, pattern: []const u8, rel_path: []const u8) !bool {
    return std.mem.endsWith(u8, rel_path, pattern[pattern.len-3..]) or std.mem.eql(u8, pattern, rel_path);
}