const std = @import("std");
const osc = @import("osc");

pub const io_mode = .evented;

var server: osc.Server = undefined;

fn onOscReceive(msg: *const osc.Message) void {
    std.debug.print("\n{any}", .{ msg });
    //server.kill();
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    try osc.init();
    defer osc.deinit();

    server = osc.Server{
        .port = 7001,
        .on_receive = onOscReceive,
    };
    try server.init();
    try server.serve(allocator);
}
