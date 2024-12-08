const std = @import("std");
const utils = @import("utils.zig");

const input = @embedFile("day8.txt");

const V2 = @Vector(2, isize);

const Node = struct {
    name: u8,
    pos: V2,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const alloc = gpa.allocator();

    var nodes = std.ArrayList(Node).init(alloc);
    defer nodes.deinit();

    var width: isize = 0;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var i: isize = 0;
    while (lines.next()) |line| : (i += 1) {
        width = @intCast(line.len);
        for (line, 0..) |c, j| {
            if (c == '.') continue;

            try nodes.append(.{ .name = c, .pos = .{ i, @intCast(j) } });
        }
    }

    const bounds: V2 = .{ i, width };

    const start = std.time.microTimestamp();

    std.debug.print("part1: {}\n", .{try part1(alloc, bounds, nodes.items)});
    const t1 = std.time.microTimestamp();
    std.debug.print("  took {d:.3}ms\n\n", .{@as(f32, @floatFromInt(t1 - start)) / 1000.0});

    // not doing that;

    // std.debug.print("part2: {}\n", .{part2(rows.items)});
    // const t2 = std.time.microTimestamp();
    // std.debug.print("  took {d:.3}ms\n\n", .{@as(f32, @floatFromInt(t2 - t1)) / 1000.0});
}

fn part1_add(antinodes: *std.ArrayList(V2), bounds: V2, a: V2, b: V2) void {
    const zero: V2 = @splat(0);

    const next = b + (b - a);
    if (@reduce(.And, next >= zero) and @reduce(.And, next < bounds)) {
        var found = false;
        for (antinodes.items) |x| {
            if (@reduce(.And, next == x)) {
                found = true;
                break;
            }
        }
        if (!found) {
            antinodes.appendAssumeCapacity(next);
        }
    }
}

fn part1(alloc: std.mem.Allocator, bounds: V2, nodes: []const Node) !usize {
    var antinodes = std.ArrayList(V2).init(alloc);
    defer antinodes.deinit();

    for (nodes, 0..) |node, i| {
        for (nodes[i + 1 ..]) |anode| {
            if (node.name != anode.name) continue;

            try antinodes.ensureUnusedCapacity(2);

            part1_add(&antinodes, bounds, node.pos, anode.pos);
            part1_add(&antinodes, bounds, anode.pos, node.pos);
        }
    }

    return antinodes.items.len;
}

test "part1" {
    const tests: []const struct { usize, V2, []const Node } = &.{
        .{ 2, .{ 9, 9 }, &.{
            .{ .name = 'a', .pos = .{ 3, 4 } },
            .{ .name = 'a', .pos = .{ 5, 5 } },
        } },
        .{ 4, .{ 9, 9 }, &.{
            .{ .name = 'a', .pos = .{ 3, 4 } },
            .{ .name = 'a', .pos = .{ 5, 5 } },
            .{ .name = 'a', .pos = .{ 4, 8 } },
            .{ .name = 'A', .pos = .{ 7, 6 } },
        } },
        .{ 14, .{ 12, 12 }, &.{
            .{ .name = '0', .pos = .{ 1, 8 } },
            .{ .name = '0', .pos = .{ 2, 5 } },
            .{ .name = '0', .pos = .{ 3, 7 } },
            .{ .name = '0', .pos = .{ 4, 4 } },
            .{ .name = 'A', .pos = .{ 5, 6 } },
            .{ .name = 'A', .pos = .{ 8, 8 } },
            .{ .name = 'A', .pos = .{ 9, 9 } },
        } },
    };

    for (tests, 0..) |t, i| {
        std.testing.expectEqual(
            t[0],
            try part1(std.testing.allocator, t[1], t[2]),
        ) catch |e| {
            std.debug.print("failed for test {}\n", .{i});
            return e;
        };
    }
}
