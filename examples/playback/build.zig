const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "osc-plaback",
        .root_module = b.createModule(.{
            .root_source_file = b.path("playback.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const osc_module = b.dependency("osc", .{}).module("osc");
    exe.root_module.addImport("osc", osc_module);

    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run zig-osc playback example");
    run_step.dependOn(&run_cmd.step);
}
