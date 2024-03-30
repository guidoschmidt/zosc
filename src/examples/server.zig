const std = @import("std");
const osc = @import("osc");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

var server: osc.OscServer = undefined;

fn onOscReceive(msg: *const osc.OscMessage) void {
    std.debug.print("\n{any}", .{ msg });
    server.kill();
}

pub fn main() !void {
    try osc.init();
    defer osc.deinit();

    server = osc.OscServer{
        .port = 7001,
        .on_receive = onOscReceive,
    };
    try server.init();
    try server.serve(allocator);
}
