const std = @import("std");
const utils = @import("utils.zig");

const input = @embedFile("day7.txt");

const Row = struct {
    goal: usize,
    values: []const usize,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const alloc = gpa.allocator();

    var rows = std.ArrayList(Row).init(alloc);
    defer {
        for (rows.items) |row| alloc.free(row.values);
        rows.deinit();
    }

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        var parts = std.mem.tokenizeSequence(u8, line, ": ");
        const goal = try std.fmt.parseInt(usize, parts.next().?, 10);

        var values = std.ArrayList(usize).init(alloc);
        errdefer values.deinit();

        var vals = std.mem.tokenizeScalar(u8, parts.next().?, ' ');
        while (vals.next()) |val| {
            try values.append(try std.fmt.parseInt(usize, val, 10));
        }

        try rows.append(.{ .goal = goal, .values = try values.toOwnedSlice() });
    }

    const start = std.time.microTimestamp();

    std.debug.print("part1: {}\n", .{part1(rows.items)});
    const t1 = std.time.microTimestamp();
    std.debug.print("  took {d:.3}ms\n\n", .{@as(f32, @floatFromInt(t1 - start)) / 1000.0});

    std.debug.print("part2: {}\n", .{part2(rows.items)});
    const t2 = std.time.microTimestamp();
    std.debug.print("  took {d:.3}ms\n\n", .{@as(f32, @floatFromInt(t2 - t1)) / 1000.0});
}

fn part1_test(goal: usize, values: []const usize) bool {
    if (values.len == 0) return goal == 0;
    if (values.len == 1) return values[0] == goal;

    const first = values[values.len - 1];
    const rest = values[0 .. values.len - 1];

    return (goal >= first and part1_test(goal - first, rest)) or
        (goal % first == 0 and part1_test(@divExact(goal, first), rest));
}

fn part1(rows: []const Row) u64 {
    var res: u64 = 0;

    for (rows) |row| {
        if (part1_test(row.goal, row.values)) {
            res += row.goal;
        }
    }

    return res;
}

test "part1" {
    try std.testing.expectEqual(3749, part1(&.{
        .{ .goal = 190, .values = &.{ 10, 19 } },
        .{ .goal = 3267, .values = &.{ 81, 40, 27 } },
        .{ .goal = 83, .values = &.{ 17, 5 } },
        .{ .goal = 156, .values = &.{ 15, 6 } },
        .{ .goal = 7290, .values = &.{ 6, 8, 6, 15 } },
        .{ .goal = 161011, .values = &.{ 16, 10, 13 } },
        .{ .goal = 192, .values = &.{ 17, 8, 14 } },
        .{ .goal = 21037, .values = &.{ 9, 7, 18, 13 } },
        .{ .goal = 292, .values = &.{ 11, 6, 16, 20 } },
    }));
}

fn part2_test(goal: usize, values: []const usize) bool {
    if (values.len == 0) return goal == 0;
    if (values.len == 1) return values[0] == goal;

    const last = values[values.len - 1];
    const rest = values[0 .. values.len - 1];
    const digits = std.math.log10(last);
    const n = std.math.pow(usize, 10, digits + 1);

    return (goal >= last and part2_test(goal - last, rest)) or
        (goal % last == 0 and part2_test(@divExact(goal, last), rest)) or
        (goal % n == last and part2_test(@divFloor(goal, n), rest));
}

fn part2(rows: []const Row) u64 {
    var res: u64 = 0;

    for (rows) |row| {
        if (part2_test(row.goal, row.values)) {
            res += row.goal;
        }
    }

    return res;
}

test "part2" {
    try std.testing.expectEqual(11387, part2(&.{
        .{ .goal = 190, .values = &.{ 10, 19 } },
        .{ .goal = 3267, .values = &.{ 81, 40, 27 } },
        .{ .goal = 83, .values = &.{ 17, 5 } },
        .{ .goal = 156, .values = &.{ 15, 6 } },
        .{ .goal = 7290, .values = &.{ 6, 8, 6, 15 } },
        .{ .goal = 161011, .values = &.{ 16, 10, 13 } },
        .{ .goal = 192, .values = &.{ 17, 8, 14 } },
        .{ .goal = 21037, .values = &.{ 9, 7, 18, 13 } },
        .{ .goal = 292, .values = &.{ 11, 6, 16, 20 } },
    }));
}
