const std = @import("std");
const network = @import("network");

const OscMessage = @import("./OscMessage.zig");

const Allocator = std.mem.Allocator;

const Self = @This();

port: u16 = 7777,
socket: network.Socket = undefined,
comptime buffer_size: u32 = 4096,

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
    while(true) {
        const bytes = try reader.read(buffer[0..buffer.len]);
        if (bytes > 0) {
            const osc_msg = OscMessage.decode(buffer[0..bytes], allocator);
            std.debug.print("{any}", .{ osc_msg });
        }
    }
}
