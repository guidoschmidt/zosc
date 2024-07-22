const std = @import("std");
const network = @import("network");
const OscSubscriber = @import("OscSubscriber.zig");
const Allocator = std.mem.Allocator;

const OscMessage = @import("./OscMessage.zig");

const OscServer = @This();

subscribers: std.StringHashMap(OscSubscriber) = undefined,

port: u16 = 7777,
socket: network.Socket = undefined,
comptime buffer_size: u32 = 4096,
active: bool = true,

pub fn init(self: *OscServer, allocator: Allocator) !void {
    self.subscribers = std.StringHashMap(OscSubscriber).init(allocator);

    self.socket = try network.Socket.create(.ipv4, .udp);
    try self.socket.enablePortReuse(true);
    const incoming_endpoint = network.EndPoint{
        .address = network.Address{ .ipv4 = network.Address.IPv4.any },
        .port = self.port,
    };
    self.socket.bind(incoming_endpoint) catch |err| {
        std.log.err("[OscServer] Failed to bind to {s}\n{any}", .{ incoming_endpoint, err });
    };
}

pub fn subscribe(self: *OscServer, subscriber: OscSubscriber) !void {
    try self.subscribers.put(subscriber.id, subscriber);
}

pub fn unsubscribe(self: *OscServer, id: []const u8) void {
    self.subscribers.remove(id);
}

fn next(self: *OscServer, msg: *const OscMessage) void {
    var val_it = self.subscribers.valueIterator();
    while(val_it.next()) |sub| {
        // @TODO impl. partial match or even regex, e.g. /topic1/*/velocity
        if (std.mem.containsAtLeast(u8, msg.address, 1, sub.topic)) {
            if (sub.*.onNextFn) |onNextFn| onNextFn(sub, msg);
        }
    }
}

pub fn serve(self: *OscServer, allocator: Allocator) !void {
    std.log.info("\n[OscServer] Serving on port {}", .{ self.port });

    defer self.subscribers.deinit();

    var reader = self.socket.reader();
    var buffer: [self.buffer_size]u8 = undefined;
    self.active = true;
    while(true) {
        if (!self.active) break;
        const bytes = try reader.read(buffer[0..buffer.len]);
        if (bytes > 0) {
            const osc_msg = try OscMessage.decode(buffer[0..bytes], allocator);
            self.next(&osc_msg);
        }
    }
    if (!self.active) {
        std.debug.print("\n[OscServer] shutting down ...", .{});
    }
}

pub fn kill(self: *OscServer) void {
    self.active = false;
}
