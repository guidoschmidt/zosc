const std = @import("std");
const network = @import("network");

const OscMessage = @import("./OscMessage.zig");

const Self = @This();

port: u16 = undefined,
address: network.Address = undefined,
socket: network.Socket = undefined,
send_to_endpoint: network.EndPoint = undefined,

pub fn connect(self: *Self) !void {
    self.address = network.Address{
        .ipv4 = network.Address.IPv4.any
    };

    self.socket = try network.Socket.create(.ipv4, .udp);
    try self.socket.setBroadcast(true);

    const bind_address = network.EndPoint{
        .address = network.Address { .ipv4 = network.Address.IPv4.any },
        .port = 0,
    };

    self.send_to_endpoint = network.EndPoint {
        .address = network.Address{ .ipv4 = network.Address.IPv4.multicast_all },
        .port = self.port,
    };
    try self.socket.bind(bind_address);
}

pub fn close(self: *Self) void {
    self.socket.close();
}

pub fn sendMessage(self: *Self,
                   osc_message: OscMessage,
                   allocator: std.mem.Allocator) !void {
    const buffer = try osc_message.encode(allocator);
    _ = try self.socket.sendTo(self.send_to_endpoint, buffer);
}
