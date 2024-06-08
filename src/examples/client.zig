const std = @import("std");
const osc = @import("osc");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    try osc.init();
    defer osc.deinit();

    var client = osc.Client{
        .port = 7001,
    };
    try client.connect();

    var i: usize = 0;
    while(i < 300) {

        const msg = osc.Message{
            .address = "/ch/1",
            .arguments = &[_]osc.Argument{
                .{ .f = std.math.sin(@as(f32, @floatFromInt(i)) * 0.1) * 3.0 }
            }
        };
        std.debug.print("\n{any}", .{ msg });
        try client.sendMessage(msg, allocator);

        i += 1;
        std.time.sleep(std.time.ns_per_ms * 16);
    } 
}
