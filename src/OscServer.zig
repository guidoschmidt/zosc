const std = @import("std");
const network = @import("network");

const OscMessage = @import("./OscMessage.zig");

const Allocator = std.mem.Allocator;

const Self = @This();

port: u16 = 7777,
socket: network.Socket = undefined,
comptime buffer_size: u32 = 4096,
on_receive: *const fn(*const OscMessage) void = undefined,
active: bool = true,

pub fn init(self: *Self) !void {
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

pub fn serve(self: *Self, allocator: Allocator) !void {
    std.log.info("\n[OscServer] Serving on port {}", .{ self.port });
    var reader = self.socket.reader();
    var buffer: [self.buffer_size]u8 = undefined;
    self.active = true;
    while(true) {
        if (!self.active) break;
        const bytes = try reader.read(buffer[0..buffer.len]);
        if (bytes > 0) {
            const osc_msg = try OscMessage.decode(buffer[0..bytes], allocator);
            if (self.on_receive != undefined)
                self.on_receive(&osc_msg);
        }
    }
    if (!self.active) {
        std.debug.print("\n[OscServer] shutting down ...", .{});
    }
}

pub fn kill(self: *Self) void {
    self.active = false;
}
