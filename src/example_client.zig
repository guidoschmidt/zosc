const std = @import("std");
const osc = @import("osc");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub fn main() !void {
    try osc.init();
    defer osc.deinit();

    var client = osc.OscClient{
        .port = 7001,
    };
    try client.connect();

    var i: usize = 0;
    while(i < 300) {

        const msg = osc.OscMessage{
            .address = "/ch/1",
            .arguments = &[_]osc.OscArgument{
                .{ .f = std.math.sin(@as(f32, @floatFromInt(i)) * 0.1) * 3.0 }
            }
        };
        std.debug.print("\n{any}", .{ msg });
        try client.sendMessage(msg, allocator);

        i += 1;
        std.time.sleep(std.time.ns_per_ms * 16);
    } 
}
