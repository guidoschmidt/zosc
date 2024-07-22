const std = @import("std");
const osc = @import("osc");

pub const io_mode = .evented;

var server: osc.Server = undefined;

const ExampleSub = struct {
    osc_subscriber: osc.Subscriber = undefined,

    pub fn init(topic: []const u8) ExampleSub {
        const impl = struct {
            pub fn onNext(ptr: *osc.Subscriber, msg: *const osc.Message) void {
                const self: *ExampleSub = @fieldParentPtr("osc_subscriber", ptr);
                return self.handleOscMessage(msg);
            }
        };
        return ExampleSub {
            .osc_subscriber = osc.Subscriber {
                .id = "unique-id",
                .topic = topic,
                .onNextFn = impl.onNext,
            }
        };
    }

    pub fn subscribe(self: *const ExampleSub, publisher: *osc.Server) !void {
        try publisher.subscribe(self.osc_subscriber);
    }

    pub fn handleOscMessage(_: *ExampleSub, msg: *const osc.Message) void {
        std.log.info("\n{any}", .{ msg });
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    try osc.init();
    defer osc.deinit();

    server = osc.Server{
        .port = 7001,
    };
    try server.init(allocator);

    const osc_sub = ExampleSub.init("/ch/1");
    try osc_sub.subscribe(&server);

    try server.serve(allocator);
}
