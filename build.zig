const std = @import("std");

//  pub fn addExample(b: *std.Build,
//                   target: std.Build.ResolvedTarget,
//                   optimize: std.builtin.OptimizeMode,
//                    comptime name: []const u8,
//                    comptime src_file: []const u8,
//                    osc_module: *std.Build.Module) void {
// }

pub fn build(b: *std.Build) void {
    const network_module = b.dependency("network", .{}).module("network");

    const osc_module = b.addModule("osc", .{
        .root_source_file = .{ .path = "src/lib.zig" },
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
            .root_source_file = .{ .path = "./src/example_server.zig" },
            .target = target,
            .optimize = optimize,
        });

        exe.root_module.addImport("osc", osc_module);

        b.installArtifact(exe);
        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step("server", "Run example server");
        run_step.dependOn(&run_cmd.step);
     }

    {
        const exe = b.addExecutable(.{
            .name = "client",
            .root_source_file = .{ .path = "./src/example_client.zig" },
            .target = target,
            .optimize = optimize,
        });

        exe.root_module.addImport("osc", osc_module);

        b.installArtifact(exe);
        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step("client", "Run example server");
        run_step.dependOn(&run_cmd.step);
    }

    // Tests
    const tests = b.addTest(.{
        .root_source_file = .{ .path = "./src/testing.zig" },
        .target = target,
        .optimize = optimize
    });
    //tests.addModule("", module_name);
    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_tests.step);

}