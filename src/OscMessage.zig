const std = @import("std");

const OscTypeTag = enum {
    i32,
    f32,
    string,
    blob,
};

pub const OscArgumentType = enum {
    i,
    f,
    s,
    b,
};

pub const OscArgument = union(OscArgumentType) {
    i: i32,
    f: f32,
    s: []const u8,
    b: bool,

    pub fn setFloat(self: *OscArgument, f: f32) void {
        self.f = f;
    }

    pub fn setInt(self: *OscArgument, i: i32) void {
        self.i = i;
    }

    pub fn setBool(self: *OscArgument, b: bool) void {
        self.b = b;
    }

    pub fn setBlob(self: *OscArgument) void {
        _ = self;
        @panic("Not yet implemented");
    }

    pub fn setString(self: *OscArgument, s: []const u8) void {
        self.s = s;
    }

    pub fn format(self: OscArgument, writer: *std.Io.Writer) !void {
        switch (self) {
            .f => |s| try writer.print("f {d:.3}", .{s}),
            .i => |s| try writer.print("i {d}", .{s}),
            .b => |s| try writer.print("b {s}", .{if (s) "true" else "false"}),
            .s => |s| try writer.print("s {s}", .{s}),
        }
    }
};

const OscMessage = @This();

address: []const u8,
arguments: []const OscArgument = undefined,

pub fn addArguments(self: *OscMessage, arguments: []const OscArgument) void {
    self.arguments = arguments;
}

pub fn format(self: OscMessage, writer: *std.Io.Writer) !void {
    try writer.print("\n{s} [{d}]", .{ self.address, self.arguments.len });
    for (0..self.arguments.len) |i| {
        try writer.print("\n + {f}", .{self.arguments[i]});
    }
}

pub fn encode(self: OscMessage, writer: *std.Io.Writer.Allocating) ![]u8 {
    // Address
    try writer.writer.writeAll(self.address);
    var len = writer.written().len;
    try writer.writer.splatByteAll(0, 4 - @mod(len, 4));
    try writer.writer.writeByte(',');

    for (self.arguments) |arg| {
        switch (arg) {
            .i => try writer.writer.writeByte('i'),
            .f => try writer.writer.writeByte('f'),
            .s => try writer.writer.writeByte('s'),
            .b => try writer.writer.writeByte('b'),
            // else => {},
        }
    }
    len = writer.written().len;
    if (4 - @mod(len, 4) < 4)
        try writer.writer.splatByteAll(0, 4 - @mod(len, 4));

    for (self.arguments) |arg| {
        switch (arg) {
            .i => {
                len = writer.written().len;
                try writer.writer.writeInt(i32, arg.i, .big);
                len = writer.written().len;
                if (4 - @mod(len, 4) < 4)
                    try writer.writer.splatByteAll(0, 4 - @mod(len, 4));
            },
            .f => {
                len = writer.written().len;
                try writer.writer.writeInt(i32, @bitCast(arg.f), .big);
                len = writer.written().len;
                if (4 - @mod(len, 4) < 4)
                    try writer.writer.splatByteAll(0, 4 - @mod(len, 4));
            },
            .s => {
                try writer.writer.writeAll(arg.s);
                len = writer.written().len;
                if (4 - @mod(len, 4) < 4)
                    try writer.writer.splatByteAll(0, 4 - @mod(len, 4));
            },
            .b => {
                // try writer.writer.writeAll(arg.b);
                // len = writer.written().len;
                // if (4 - @mod(len, 4) < 4)
                //     try writer.writer.splatByteAll(0, 4 - @mod(len, 4));
            },
            // else => {},
        }
    }

    len = writer.written().len;
    if (@mod(len, 4) != 0)
        try writer.writer.splatByteAll(0, 4 - @mod(len, 4));

    return writer.written();
}

pub fn decode(buffer: []u8, allocator: std.mem.Allocator) !OscMessage {
    var argument_list: std.array_list.Managed(OscArgument) = .init(allocator);
    defer argument_list.deinit();

    var fbs = std.io.fixedBufferStream(buffer);
    var counting_reader = std.io.countingReader(fbs.reader());

    const stream = counting_reader.reader();

    const address_from_stream = try stream.readUntilDelimiter(fbs.buffer, ',');
    const addr = try allocator.dupe(u8, address_from_stream);
    const eof = try fbs.getEndPos();
    var pos: usize = 0;

    while (pos < eof) : (pos = fbs.pos) {
        const type_tag = try stream.readByte();
        switch (type_tag) {
            'f' => {
                try argument_list.append(OscArgument{
                    .f = 0,
                });
            },
            'i' => {
                try argument_list.append(OscArgument{
                    .i = 0,
                });
            },
            's' => {
                try argument_list.append(OscArgument{ .s = "" });
            },
            'b' => {
                try argument_list.append(OscArgument{ .b = false });
            },
            else => break,
        }
    }

    pos = fbs.pos;
    const skip: usize = try std.math.mod(usize, pos, 4);
    if (skip > 0)
        try stream.skipBytes(4 - skip, .{});

    for (0..argument_list.items.len) |i| {
        const arg = argument_list.items[i];
        switch (arg) {
            .f => {
                const bytes = try stream.readBytesNoEof(4);
                const value = std.mem.bytesAsValue(i32, bytes[0..]);
                const value_native = std.mem.bigToNative(i32, value.*);
                const float_arg: f32 = @bitCast(value_native);
                argument_list.items[i].f = float_arg;
            },
            .i => {
                const int_arg = try stream.readInt(i32, .big);
                argument_list.items[i].i = int_arg;
            },
            .b => {
                const int_arg = try stream.readInt(i32, .big);
                argument_list.items[i].b = if (int_arg == 0) false else true;
            },
            .s => {
                if (try stream.readUntilDelimiterOrEof(fbs.buffer, 0)) |s| {
                    argument_list.items[i].s = s;
                    pos = fbs.pos;
                }
                const rest = @mod(pos, 4);
                if (rest > 0) {
                    try stream.skipBytes(rest, .{});
                }
            },
        }
    }
    const final_arguments = try allocator.dupe(OscArgument, argument_list.items);
    errdefer allocator.free(addr);
    errdefer allocator.free(final_arguments);
    return OscMessage{
        .address = addr,
        .arguments = final_arguments,
    };
}

pub fn deinit(message: OscMessage, allocator: std.mem.Allocator) void {
    allocator.free(message.address);
    allocator.free(message.arguments);
}
