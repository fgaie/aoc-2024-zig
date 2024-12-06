const std = @import("std");
const utils = @import("utils.zig");

const input = @embedFile("day6.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const alloc = gpa.allocator();

    var position: Position = .{ .x = 0, .y = 0 };
    var walls = std.ArrayList([]const bool).init(alloc);
    defer {
        for (walls.items) |row| alloc.free(row);
        walls.deinit();
    }

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var i: usize = 0;
    while (lines.next()) |line| : (i += 1) {
        var row = std.ArrayList(bool).init(alloc);
        errdefer row.deinit();

        for (line, 0..) |c, j| {
            switch (c) {
                '#' => try row.append(true),
                '.' => try row.append(false),
                '^' => {
                    try row.append(false);
                    position = .{ .x = @intCast(i), .y = @intCast(j) };
                },
                else => unreachable,
            }
        }

        try walls.append(try row.toOwnedSlice());
    }

    const start = std.time.microTimestamp();

    std.debug.print("part1: {}\n", .{try part1(alloc, position, walls.items)});
    const t1 = std.time.microTimestamp();
    std.debug.print("  took {d:.3}ms\n\n", .{@as(f32, @floatFromInt(t1 - start)) / 1000.0});

    std.debug.print("part2: {}\n", .{part2(position, walls.items)});
    const t2 = std.time.microTimestamp();
    std.debug.print("  took {d:.3}ms\n\n", .{@as(f32, @floatFromInt(t2 - t1)) / 1000.0});
}

const Position = struct { x: isize, y: isize };

fn walls_get(pos: Position, walls: []const []const bool) ?bool {
    if (pos.x < 0 or pos.x >= walls.len or
        pos.y < 0 or pos.y >= walls[@abs(pos.x)].len)
    {
        return null;
    }

    return walls[@abs(pos.x)][@abs(pos.y)];
}

fn part1(
    alloc: std.mem.Allocator,
    _position: Position,
    walls: []const []const bool,
) !u64 {
    var position = _position;
    var looking: Position = .{ .x = -1, .y = 0 };
    var seen = std.ArrayList(Position).init(alloc);
    defer seen.deinit();

    try seen.append(position);

    while (true) {
        var repeat = false;
        for (seen.items) |pos| {
            if (pos.x == position.x and pos.y == position.y) {
                repeat = true;
                break;
            }
        }

        if (!repeat) {
            try seen.append(position);
        }

        const next: Position = .{
            .x = position.x + looking.x,
            .y = position.y + looking.y,
        };

        // -1 0 // 0 1 // 1 0 // 0 -1

        if (walls_get(next, walls) orelse break) {
            const l = looking;
            looking = .{ .x = l.y, .y = -l.x };
        } else {
            position = next;
        }
    }

    return seen.items.len;
}

test "part1" {
    try std.testing.expectEqual(41, try part1(
        std.testing.allocator,
        .{ .x = 6, .y = 4 },
        &.{
            &.{ false, false, false, false, true, false, false, false, false, false },
            &.{ false, false, false, false, false, false, false, false, false, true },
            &.{ false, false, false, false, false, false, false, false, false, false },
            &.{ false, false, true, false, false, false, false, false, false, false },
            &.{ false, false, false, false, false, false, false, true, false, false },
            &.{ false, false, false, false, false, false, false, false, false, false },
            &.{ false, true, false, false, false, false, false, false, false, false },
            &.{ false, false, false, false, false, false, false, false, true, false },
            &.{ true, false, false, false, false, false, false, false, false, false },
            &.{ false, false, false, false, false, false, true, false, false, false },
        },
    ));
}

fn part2(
    _position: Position,
    walls: []const []const bool,
) u64 {
    _ = _position;
    _ = walls;
    @panic("I'm not doing that'");
}

test "part2" {
    try std.testing.expectEqual(6, part2(
        .{ .x = 6, .y = 4 },
        &.{
            &.{ false, false, false, false, true, false, false, false, false, false },
            &.{ false, false, false, false, false, false, false, false, false, true },
            &.{ false, false, false, false, false, false, false, false, false, false },
            &.{ false, false, true, false, false, false, false, false, false, false },
            &.{ false, false, false, false, false, false, false, true, false, false },
            &.{ false, false, false, false, false, false, false, false, false, false },
            &.{ false, true, false, false, false, false, false, false, false, false },
            &.{ false, false, false, false, false, false, false, false, true, false },
            &.{ true, false, false, false, false, false, false, false, false, false },
            &.{ false, false, false, false, false, false, true, false, false, false },
        },
    ));
}
