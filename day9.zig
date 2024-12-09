const std = @import("std");
const utils = @import("utils.zig");

const input = @embedFile("day9.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const alloc = gpa.allocator();

    var buffer = std.ArrayList(?usize).init(alloc);
    defer buffer.deinit();

    var file = true;
    var id: usize = 0;
    for (input) |c| {
        if (c < '0') continue;

        if (file) {
            try buffer.appendNTimes(id, c - '0');
            id += 1;
        } else {
            try buffer.appendNTimes(null, c - '0');
        }

        file = !file;
    }

    const start = std.time.microTimestamp();

    std.debug.print("part1: {}\n", .{try part1(alloc, buffer.items)});
    const t1 = std.time.microTimestamp();
    std.debug.print("  took {d:.3}ms\n\n", .{@as(f32, @floatFromInt(t1 - start)) / 1000.0});

    // std.debug.print("part2: {}\n", .{part2(rows.items)});
    // const t2 = std.time.microTimestamp();
    // std.debug.print("  took {d:.3}ms\n\n", .{@as(f32, @floatFromInt(t2 - t1)) / 1000.0});
}

fn part1(alloc: std.mem.Allocator, in: []const ?usize) !usize {
    const copy = try alloc.dupe(?usize, in);
    defer alloc.free(copy);

    var start: usize = 0;
    var end: usize = copy.len;

    while (copy[start] != null) start += 1;
    while (copy[end - 1] == null) end -= 1;

    while (start < end) {
        std.mem.swap(?usize, &copy[start], &copy[end - 1]);

        while (copy[start] != null) start += 1;
        while (copy[end - 1] == null) end -= 1;
    }

    var res: usize = 0;
    for (copy, 0..) |x, i| {
        if (x) |n| {
            res += i * n;
        }
    }

    return res;
}

test "part1" {
    try std.testing.expectEqual(1928, try part1(
        std.testing.allocator,
        &.{ 0, 0, null, null, null, 1, 1, 1, null, null, null, 2, null, null, null, 3, 3, 3, null, 4, 4, null, 5, 5, 5, 5, null, 6, 6, 6, 6, null, 7, 7, 7, null, 8, 8, 8, 8, 9, 9 },
    ));
}
