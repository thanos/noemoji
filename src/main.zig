const std = @import("std");
const emoji = @import("emoji");

const version = "0.1.0";

const Config = struct {
    dry_run: bool = false,
    backup: bool = false,
    output_dir: ?[]const u8 = null,
    pattern: ?[]const u8 = null,
};

fn printHelp() void {
    std.debug.print(
        \\noemoji v{s} - Remove emoji from files
        \\
        \\USAGE:
        \\    noemoji [OPTIONS] <file|pattern>
        \\
        \\ARGS:
        \\    <file|pattern>    File path or glob pattern (e.g., "*.md", "**/*.txt")
        \\
        \\OPTIONS:
        \\    -h, --help              Print help information
        \\    -v, --version           Print version information
        \\    -n, --dry-run           Show what would be changed without modifying files
        \\    -b, --backup            Create backup files (adds .bak extension)
        \\    -o, --output-dir <DIR>  Write cleaned files to directory (preserves originals)
        \\
        \\EXAMPLES:
        \\    noemoji document.txt
        \\    noemoji "*.md"
        \\    noemoji --dry-run "*.md"
        \\    noemoji --backup README.md
        \\    noemoji --output-dir cleaned "*.txt"
        \\
    , .{version});
}

fn printVersion() void {
    std.debug.print("noemoji {s}\n", .{version});
}

fn matchGlob(pattern: []const u8, filename: []const u8) bool {
    // Simple glob matching: *.ext matches any file ending with .ext
    if (std.mem.startsWith(u8, pattern, "*.")) {
        const ext = pattern[1..]; // include the dot
        return std.mem.endsWith(u8, filename, ext);
    }

    // **/*.ext matches any file ending with .ext in any directory
    if (std.mem.startsWith(u8, pattern, "**/*.")) {
        const ext = pattern[4..]; // skip "**/*"
        return std.mem.endsWith(u8, filename, ext);
    }

    // Exact match
    return std.mem.eql(u8, pattern, filename);
}

fn processFile(allocator: std.mem.Allocator, path: []const u8, config: Config) !void {
    const cwd = std.fs.cwd();

    // Read file
    const data = cwd.readFileAlloc(allocator, path, 10_000_000) catch |err| {
        std.debug.print("Error reading file '{s}': {s}\n", .{ path, @errorName(err) });
        return err;
    };
    defer allocator.free(data);

    // Remove emoji
    const cleaned = try emoji.stripEmoji(allocator, data);
    defer allocator.free(cleaned);

    // Check if file changed
    if (std.mem.eql(u8, data, cleaned)) {
        if (!config.dry_run) {
            std.debug.print("  {s} (no emoji found)\n", .{path});
        }
        return;
    }

    // Dry run mode - just show what would change
    if (config.dry_run) {
        std.debug.print("Would clean: {s}\n", .{path});
        return;
    }

    // Backup mode - create .bak file
    if (config.backup) {
        const backup_path = try std.fmt.allocPrint(allocator, "{s}.bak", .{path});
        defer allocator.free(backup_path);

        try cwd.writeFile(.{ .sub_path = backup_path, .data = data });
        std.debug.print("  Backed up to {s}\n", .{backup_path});
    }

    // Output directory mode
    if (config.output_dir) |out_dir| {
        // Ensure output directory exists
        cwd.makeDir(out_dir) catch |err| {
            if (err != error.PathAlreadyExists) return err;
        };

        // Get just the filename (not the path)
        const filename = std.fs.path.basename(path);
        const output_path = try std.fs.path.join(allocator, &[_][]const u8{ out_dir, filename });
        defer allocator.free(output_path);

        try cwd.writeFile(.{ .sub_path = output_path, .data = cleaned });
        std.debug.print("✓ Cleaned {s} → {s}\n", .{ path, output_path });
    } else {
        // Normal mode - overwrite file
        try cwd.writeFile(.{ .sub_path = path, .data = cleaned });
        std.debug.print("✓ Cleaned {s}\n", .{path});
    }
}

fn findAndProcessFiles(allocator: std.mem.Allocator, pattern: []const u8, config: Config) !void {
    const cwd = std.fs.cwd();
    var dir = try cwd.openDir(".", .{ .iterate = true });
    defer dir.close();

    var walker = try dir.walk(allocator);
    defer walker.deinit();

    var found_any = false;

    while (try walker.next()) |entry| {
        if (entry.kind != .file) continue;

        if (matchGlob(pattern, entry.basename)) {
            found_any = true;
            try processFile(allocator, entry.path, config);
        }
    }

    if (!found_any) {
        std.debug.print("No files matched pattern: {s}\n", .{pattern});
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // No arguments provided
    if (args.len < 2) {
        printHelp();
        return;
    }

    var config = Config{};
    var targets: std.ArrayList([]const u8) = .empty;
    defer targets.deinit(allocator);

    var i: usize = 1;
    while (i < args.len) : (i += 1) {
        const arg = args[i];

        if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help")) {
            printHelp();
            return;
        } else if (std.mem.eql(u8, arg, "-v") or std.mem.eql(u8, arg, "--version")) {
            printVersion();
            return;
        } else if (std.mem.eql(u8, arg, "-n") or std.mem.eql(u8, arg, "--dry-run")) {
            config.dry_run = true;
        } else if (std.mem.eql(u8, arg, "-b") or std.mem.eql(u8, arg, "--backup")) {
            config.backup = true;
        } else if (std.mem.eql(u8, arg, "-o") or std.mem.eql(u8, arg, "--output-dir")) {
            i += 1;
            if (i >= args.len) {
                std.debug.print("Error: --output-dir requires a directory argument\n", .{});
                return error.MissingArgument;
            }
            config.output_dir = args[i];
        } else if (!std.mem.startsWith(u8, arg, "-")) {
            try targets.append(allocator, arg);
        } else {
            std.debug.print("Unknown option: {s}\n", .{arg});
            printHelp();
            return error.UnknownOption;
        }
    }

    if (targets.items.len == 0) {
        std.debug.print("Error: No file or pattern specified\n\n", .{});
        printHelp();
        return error.MissingTarget;
    }

    // Process each target (file or pattern)
    for (targets.items) |target_path| {
        // Check if it's a glob pattern or a regular file
        if (std.mem.indexOf(u8, target_path, "*") != null) {
            // It's a glob pattern
            try findAndProcessFiles(allocator, target_path, config);
        } else {
            // It's a single file
            try processFile(allocator, target_path, config);
        }
    }
}
