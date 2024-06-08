const std = @import("std");

pub fn build(b: *std.Build) void {
    const network_module = b.dependency("network", .{}).module("network");

    const zosc_module = b.addModule("zosc", .{
        .root_source_file = b.path("src/lib.zig"),
        .imports = &.{
            .{ .name = "network", .module = network_module },
        },
    });

    // Examples
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    {
        const exe = b.addExecutable(.{
            .name = "server",
            .root_source_file = b.path("./src/examples/server.zig"),
            .target = target,
            .optimize = optimize,
        });

        exe.root_module.addImport("osc", zosc_module);

        b.installArtifact(exe);
        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step("examples-server", "Run example server");
        run_step.dependOn(&run_cmd.step);
    }

    {
        const exe = b.addExecutable(.{
            .name = "client",
            .root_source_file = b.path("./src/examples/client.zig"),
            .target = target,
            .optimize = optimize,
        });

        exe.root_module.addImport("osc", zosc_module);

        b.installArtifact(exe);
        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step("examples-client", "Run example server");
        run_step.dependOn(&run_cmd.step);
    }

    // Tests
    const tests = b.addTest(.{ .root_source_file = b.path("./src/testing.zig"), .target = target, .optimize = optimize });
    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_tests.step);
}
