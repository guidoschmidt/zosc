const std = @import("std");
const zosc = @import("zosc");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var client = zosc.Client{ .port = 1121, .allocator = allocator };
    try client.connect(false, "127.0.0.1");

    const rng_gen = std.Random.DefaultPrng;
    var rng: std.Random.Xoshiro256 = rng_gen.init(@intCast(std.time.timestamp()));

    const note_count = 120;
    var note_idx: usize = 0;
    while (note_idx < note_count) : (note_idx += 1) {
        // random skip
        if (rng.random().boolean()) continue;
        const harmonics_count = rng.random().intRangeAtMost(usize, 2, 12);
        const base_freq = rng.random().intRangeAtMost(usize, 3, 200);
        for (0..harmonics_count) |mult| {
            try client.sendMessage(.{
                .address = "/zigsynth",
                .arguments = &.{
                    .{ .i = @intCast(base_freq * mult) },
                    .{ .f = rng.random().float(f32) * 3 },
                },
            });
        }
        std.Thread.sleep(std.time.ns_per_ms * 200);
    }

    try zosc.init();
    defer zosc.deinit();
}
