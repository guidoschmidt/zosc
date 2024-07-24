const OscMessage = @import("./OscMessage.zig");

id: []const u8,
topic: []const u8,
onNextFn: ?*const fn(*@This(), *const OscMessage) void = undefined,

pub fn onNext(self: *@This(), msg: *const OscMessage) void {
    self.onNextFn.?(self, msg);
}
