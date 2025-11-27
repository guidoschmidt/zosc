const std = @import("std");
const osc = @import("osc");

const l = std.log.scoped(.@"osc-example-client");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    try osc.init();
    defer osc.deinit();

    var client = osc.Client{
        .port = 8001,
        .allocator = allocator,
    };
    try client.connect(true, "0.0.0.0");
    std.debug.print("Sending to {f}:{d}\n", .{
        client.address,
        client.port,
    });

    const msg_count: usize = 10;
    var i: usize = 0;
    var curr: i16 = -250;
    var zoom_curr: i16 = -740;
    while (i < msg_count) {
        if (i < msg_count / 2) {
            zoom_curr -= 3;
            curr += 1;
        } else {
            zoom_curr += 3;
            curr -= 1;
        }

        const msg1: osc.Message = .{
            .address = "/fader/1",
            .arguments = &.{
                .{ .s = "Hallo Welt!" },
                .{ .f = 3.14 },
                .{ .i = 42 },
                .{ .s = "Hallo" },
            },
        };
        std.debug.print(">>> {f}\n", .{msg1});
        try client.sendMessage(msg1);
        const msg2: osc.Message = .{
            .address = "/fader/2",
            .arguments = &.{
                .{ .i = @intCast(i) },
            },
        };
        try client.sendMessage(msg2);
        std.debug.print(">>> {f}\n", .{msg2});

        i += 1;
        std.Thread.sleep(std.time.ns_per_ms * 30);
    }
}
