const std = @import("std");
const osc = @import("osc");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const recording_filename = "recording.osc";
    const file = std.fs.cwd().openFile(recording_filename, .{ .mode = .read_only }) catch {
        std.log.err("{s} not found.", .{recording_filename});
        return;
    };
    const stats = try file.stat();
    const content = try file.readToEndAlloc(allocator, stats.size);
    std.debug.print("\n{s}", .{content});

    try osc.init();
    defer osc.deinit();

    var client = osc.Client{
        .port = 7001,
        .allocator = allocator,
    };
    try client.connect(false, "127.0.0.1");
}
