const std = @import("std");
const osc = @import("osc");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

fn onOscReceive(msg: *const osc.OscMessage) void {
    std.debug.print("\n{any}", .{ msg });
}

pub fn main() !void {
    try osc.init();
    defer osc.deinit();

    var server = osc.OscServer{
        .port = 7001,
        .on_receive = onOscReceive,
    };
    try server.init();
    try server.serve(allocator);
}
