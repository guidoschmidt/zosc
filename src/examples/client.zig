const std = @import("std");
const zosc = @import("zosc");

const l = std.log.scoped(.@"zosc-example-client");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    try zosc.init();
    defer zosc.deinit();

    var client = zosc.Client{ .port = 8001, .allocator = allocator };
    try client.connect(true, "0.0.0.0");
    std.debug.print("Sending to {f}:{d}\n", .{ client.address, client.port });

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

        const str_msg = zosc.Message{
            .address = "/two/strings",
            .arguments = &.{
                .{ .s = "Hallo Welt!" },
                .{ .f = 3.14 },
                .{ .i = 42 },
                .{ .s = "Hallo" },
            },
        };
        l.info("\n{f}", .{str_msg});
        try client.sendMessage(str_msg);

        i += 1;
        std.Thread.sleep(std.time.ns_per_ms * 30);
    }
}
