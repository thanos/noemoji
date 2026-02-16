const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const emoji_mod = b.createModule(.{ .root_source_file = b.path("src/emoji.zig") });
    const glob_mod = b.createModule(.{ .root_source_file = b.path("src/glob.zig") });
    const worker_mod = b.createModule(.{ .root_source_file = b.path("src/worker.zig") });

    const main_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    main_mod.addImport("emoji", emoji_mod);
    main_mod.addImport("glob", glob_mod);
    main_mod.addImport("worker", worker_mod);

    const exe = b.addExecutable(.{
        .name = "noemoji",
        .root_module = main_mod,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    if (b.args) |args| run_cmd.addArgs(args);
    const run_step = b.step("run", "Run noemoji");
    run_step.dependOn(&run_cmd.step);

    const test_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    test_mod.addImport("emoji", emoji_mod);
    test_mod.addImport("glob", glob_mod);
    test_mod.addImport("worker", worker_mod);

    const unit_tests = b.addTest(.{
        .root_module = test_mod,
    });

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&b.addRunArtifact(unit_tests).step);
}
