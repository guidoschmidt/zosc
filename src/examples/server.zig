const std = @import("std");
const osc = @import("osc");

pub const io_mode = .evented;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

var server: osc.Server = undefined;

fn onOscReceive(msg: *const osc.Message) void {
    std.debug.print("\n{any}", .{ msg });
    //server.kill();
}

pub fn main() !void {
    try osc.init();
    defer osc.deinit();

    server = osc.Server{
        .port = 7001,
        .on_receive = onOscReceive,
    };
    try server.init();
    try server.serve(allocator);
}
