const std = @import("std");
const osc = @import("./lib.zig");

const testing = std.testing;
var allocator = testing.allocator;

test "matching buffers /oscillator/4/frequency f 440.0" {
    var msg = osc.Message{
        .address = "/oscillator/4/frequency",
        .arguments = &.{.{ .f = 440.0 }},
    };

    // https://opensoundcontrol.stanford.edu/spec-1_0-examples.html#typetagstrings
    const desired: []const u8 = &[_]u8{
        0x2f, 0x6f, 0x73, 0x63, 0x69, 0x6c,
        0x6c, 0x61, 0x74, 0x6f, 0x72, 0x2f,
        0x34, 0x2f, 0x66, 0x72, 0x65, 0x71,
        0x75, 0x65, 0x6e, 0x63, 0x79, 0x0,
        0x2c, 0x66, 0x0,  0x0,  0x43, 0xdc,
        0x0,  0x0,
    };

    var writer: std.Io.Writer.Allocating = .init(allocator);
    defer writer.deinit();
    const buffer = try msg.encode(&writer);

    var i: u32 = 0;
    while (i < desired.len) : (i += 1) {
        if (desired[i] != buffer[i]) std.debug.print("----", .{});
        std.debug.print("[{d: >3}] {x: >3} == {x: >3} [{c}]\n", .{
            i,
            desired[i],
            buffer[i],
            buffer[i],
        });
    }

    try std.testing.expect(desired.len == buffer.len);
    try std.testing.expect(std.mem.eql(u8, desired, buffer));
}

test "matching buffers /foo i 1000 i -1 s hello f 1.234 f 5.678" {
    // var msg = osc.Message{
    //     .address = "/foo",
    //     .arguments = &.{
    //         .{ .i = 1000 },
    //         .{ .i = -1 },
    //         .{ .s = "hello" },
    //         .{ .f = 1.234 },
    //         .{ .f = 5.678 },
    //     },
    // };
    // std.debug.print("OSC Message: {f}\n", .{msg});

    // // https://opensoundcontrol.stanford.edu/spec-1_0-examples.html#typetagstrings
    // const desired: []const u8 = &[_]u8{
    //     0x2f, 0x66, 0x6f, 0x6f, 0x0,  0x0,  0x0,
    //     0x0,  0x2c, 0x69, 0x69, 0x73, 0x66, 0x66,
    //     0x0,  0x0,  0x0,  0x0,  0x3,  0xe8, 0xff,
    //     0xff, 0xff, 0xff, 0x68, 0x65, 0x6c, 0x6c,
    //     0x6f, 0x0,  0x0,  0x0,  0x3f, 0x9d, 0xf3,
    //     0xb6, 0x40, 0xb5, 0xb2, 0x2d,
    // };

    // const desired_dupe = try allocator.dupe(u8, desired);
    // defer allocator.free(desired_dupe);

    // const buffer = try msg.encode(allocator);
    // std.debug.print("{d} vs. {d}\n", .{ buffer.len, desired.len });

    // var i: u32 = 0;
    // while (i < desired.len) : (i += 1) {
    //     if (desired[i] != buffer[i]) std.debug.print("----", .{});
    //     std.debug.print("[{d: >3}] {x: >3} == {x: >3} [{c}]\n", .{
    //         i,
    //         desired[i],
    //         buffer[i],
    //         buffer[i],
    //     });
    // }
    // try std.testing.expect(std.mem.eql(u8, desired, buffer));
}

test "Decoding a buffer into an OSC message" {
    // // https://opensoundcontrol.stanford.edu/spec-1_0-examples.html#typetagstrings
    // var desired = [_]u8{
    //     0x2f, 0x66, 0x6f, 0x6f, 0x0,  0x0,  0x0,
    //     0x0,  0x2c, 0x69, 0x69, 0x73, 0x66, 0x66,
    //     0x0,  0x0,  0x0,  0x0,  0x3,  0xe8, 0xff,
    //     0xff, 0xff, 0xff, 0x68, 0x65, 0x6c, 0x6c,
    //     0x6f, 0x0,  0x0,  0x0,  0x3f, 0x9d, 0xf3,
    //     0xb6, 0x40, 0xb5, 0xb2, 0x2d,
    // };
    // const slice: []u8 = &desired;
    // var decoded_msg = try osc.Message.decode(slice, allocator);
    // defer decoded_msg.deinit(allocator);
    // std.debug.print("Decoded msg: {f}\n", .{decoded_msg});
}

// test "simple messages" {
//     const allocator = std.testing.allocator;

//     const test_messages = [_]*const osc.Message{
//         &osc.Message{ .address = "/test", .arguments = &.{.{ .i = 1 }} },
//         &osc.Message{ .address = "/float", .arguments = &.{.{ .f = 3.1415 }} },
//         &osc.Message{ .address = "/test/2", .arguments = &.{.{ .s = "Hello World!" }} },
//     };

//     const expected_sizes = [_]usize{
//         16,
//         16,
//         28,
//     };

//     for (test_messages, expected_sizes) |msg, size| {
//         const buffer = try msg.encode(allocator);
//         try std.testing.expectEqual(size, buffer.len);
//         defer allocator.free(buffer);
//     }
// }

// test "complex messages (multiple arguments, different types)" {
//     const allocator = std.testing.allocator;

//     const test_messages = [_]*const osc.Message{
//         &osc.Message{ .address = "/test/1", .arguments = &.{ .{ .i = 1 }, .{ .f = 3.1415 } } },
//         &osc.Message{
//             .address = "/test/3/complex",
//             .arguments = &.{ .{ .i = 42 }, .{ .s = "Hello World!" } },
//         },
//         &osc.Message{
//             .address = "/two/strings",
//             .arguments = &.{ .{ .s = "A very long string to test." }, .{ .s = "Hello World!" } },
//         },
//     };

//     const expected_sizes = [_]usize{
//         20,
//         40,
//         64,
//     };

//     for (test_messages, expected_sizes) |msg, size| {
//         const buffer = try msg.encode(allocator);
//         try std.testing.expectEqual(size, buffer.len);
//         defer allocator.free(buffer);
//     }
// }

// test "Very long and complex message" {
//     const allocator = std.testing.allocator;

//     const long_msg = osc.Message{
//         .address = "/two/strings",
//         .arguments = &.{ .{ .i = 42 }, .{ .s = "A very long string to test." }, .{ .f = 3.14 }, .{ .s = "Hello World!" } },
//     };
//     const buffer = try long_msg.encode(allocator);
//     defer allocator.free(buffer);
//     try std.testing.expectEqual(buffer.len, 76);
// }
