const std = @import("std");
const osc = @import("osc");

const l = std.log.scoped(.@"osc-example-server");
pub const io_mode = .evented;

var server: osc.Server = undefined;

const ExampleSub = struct {
    osc_subscriber: osc.Subscriber = undefined,

    pub fn init(id: usize, topic: []const u8) ExampleSub {
        const impl = struct {
            pub fn onNext(ptr: *osc.Subscriber, msg: *const osc.Message) void {
                const self: *ExampleSub = @fieldParentPtr("osc_subscriber", ptr);
                return self.handleOscMessage(msg);
            }
        };

        return ExampleSub{ .osc_subscriber = osc.Subscriber{
            .id = id,
            .topic = topic,
            .onNextFn = impl.onNext,
        } };
    }

    pub fn subscribe(self: *ExampleSub, publisher: *osc.Server) !void {
        try publisher.subscribe(&self.osc_subscriber);
    }

    pub fn handleOscMessage(self: *ExampleSub, msg: *const osc.Message) void {
        l.info("\n{f}\n>>>> {f}\n", .{ self, msg });
    }

    pub fn format(self: ExampleSub, writer: *std.Io.Writer) std.Io.Writer.Error!void {
        try writer.print("{f}", .{self.osc_subscriber});
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    try osc.init();
    defer osc.deinit();

    server = osc.Server{
        .port = 8001,
    };
    try server.init(allocator);

    var osc_sub = ExampleSub.init(0, "/*");
    try osc_sub.subscribe(&server);

    l.info("{f}", .{osc_sub});

    try server.serve();
}
