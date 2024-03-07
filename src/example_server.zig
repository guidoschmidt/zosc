const std = @import("std");
const osc = @import("osc");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub fn main() !void {
    try osc.init();
    defer osc.deinit();

    var server = osc.OscServer{
        .port = 7001,
    };
    try server.init();
    try server.serve(allocator);
}
