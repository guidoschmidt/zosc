const std = @import("std");
const zosc = @import("zosc");

pub const io_mode = .evented;

var server: zosc.Server = undefined;

const ExampleSub = struct {
    osc_subscriber: zosc.Subscriber = undefined,

    pub fn init(topic: []const u8) ExampleSub {
        const impl = struct {
            pub fn onNext(ptr: *zosc.Subscriber, msg: *const zosc.Message) void {
                const self: *ExampleSub = @fieldParentPtr("osc_subscriber", ptr);
                return self.handleOscMessage(msg);
            }
        };

        return ExampleSub {
            .osc_subscriber = zosc.Subscriber {
                .id = "unique-id",
                .topic = topic,
                .onNextFn = impl.onNext,
            }
        };
    }

    pub fn subscribe(self: *ExampleSub, publisher: *zosc.Server) !void {
        try publisher.subscribe(&self.osc_subscriber);
    }

    pub fn handleOscMessage(self: *ExampleSub, msg: *const zosc.Message) void {
        std.log.info("\n{any}\n    -> {any}", .{ self, msg });
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    try zosc.init();
    defer zosc.deinit();

    server = zosc.Server{
        .port = 7001,
    };
    try server.init(allocator);

    var osc_sub = ExampleSub.init("/ch/1");
    try osc_sub.subscribe(&server);

    try server.serve();
}
