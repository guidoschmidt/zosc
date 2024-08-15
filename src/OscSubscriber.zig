const OscMessage = @import("./OscMessage.zig");

const OscSubscriber = @This();

id: []const u8,
topic: ?[]const u8 = undefined,
onNextFn: ?*const fn(*OscSubscriber, *const OscMessage) void = undefined,

pub fn onNext(self: *OscSubscriber, msg: *const OscMessage) void {
    if (self.onNextFn) |onNextFn| {
        onNextFn(*@This(), msg);
    }
}
