const std = @import("std");
const network = @import("network");

pub const OscMessage = @import("./OscMessage.zig");
pub const OscArgument = OscMessage.OscArgument;
pub const OscClient = @import("./OscClient.zig");
pub const OscServer = @import("./OscServer.zig");

const Allocator = std.mem.Allocator;

pub fn init() !void {
    try network.init();
}

pub fn deinit() void {
    defer network.deinit();
}
