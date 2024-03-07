const std = @import("std");
const osc = @import("./lib.zig");

const testing = std.testing;


test "simple test" {
    const allocator = std.testing.allocator;

    var msg = osc.OscMessage{
        .address = "/encoder/1",
        .type_tag = .i32,
        .arguments = &[_]osc.OscArgument{
            .{ .i = 42 },
            .{ .f = 3.141567 }
        }
    };
    std.debug.print("\n{any}", .{ msg });

    const buffer = try msg.encode(allocator);
    defer allocator.free(buffer);

    std.debug.print("\nEncoded: {s}", .{ buffer });

    const decode_msg = try osc.OscMessage.decode(buffer, allocator);
    defer decode_msg.free(allocator);
    std.debug.print("\n{any}", .{ decode_msg });
}
