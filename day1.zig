const std = @import("std");
const input = @embedFile("day1.txt");

fn absDiff(x: anytype, y: @TypeOf(x)) @TypeOf(x, y) {
    return @abs(@max(x, y) - @min(x, y));
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const alloc = gpa.allocator();

    var left = std.ArrayList(u64).init(alloc);
    defer left.deinit();
    var right = std.ArrayList(u64).init(alloc);
    defer right.deinit();

    var lines = std.mem.tokenize(u8, input, "\n");
    while (lines.next()) |line| {
        var numbers = std.mem.tokenizeScalar(u8, line, ' ');
        const ls = numbers.next() orelse @panic("invalid input");
        try left.append(try std.fmt.parseInt(u64, ls, 10));

        const rs = numbers.next() orelse @panic("invalid input");
        try right.append(try std.fmt.parseInt(u64, rs, 10));
    }

    std.debug.print("part1: {}\n", .{try part1(alloc, left.items, right.items)});
    std.debug.print("part2: {}\n", .{part2(left.items, right.items)});
}

fn part1(alloc: std.mem.Allocator, left: []const u64, right: []const u64) !u64 {
    std.debug.assert(left.len == right.len);

    const dleft = try alloc.dupe(u64, left);
    defer alloc.free(dleft);
    const dright = try alloc.dupe(u64, right);
    defer alloc.free(dright);

    std.mem.sort(u64, dleft, {}, std.sort.asc(u64));
    std.mem.sort(u64, dright, {}, std.sort.asc(u64));

    var res: u64 = 0;

    for (dleft, dright) |l, r| {
        res += absDiff(l, r);
    }

    return res;
}

test "part1" {
    const alloc = std.testing.allocator;
    const left = try alloc.dupe(u64, &.{ 3, 4, 2, 1, 3, 3 });
    defer alloc.free(left);
    const right = try alloc.dupe(u64, &.{ 4, 3, 5, 3, 9, 3 });
    defer alloc.free(right);

    try std.testing.expectEqual(11, try part1(alloc, left, right));
}

fn part2(left: []const u64, right: []const u64) u64 {
    std.debug.assert(left.len == right.len);

    var res: u64 = 0;

    for (left) |l| {
        var count: u64 = 0;
        for (right) |r| {
            if (l == r) {
                count += 1;
            }
        }
        res += count * l;
    }

    return res;
}

test "part2" {
    const alloc = std.testing.allocator;
    const left = try alloc.dupe(u64, &.{ 3, 4, 2, 1, 3, 3 });
    defer alloc.free(left);
    const right = try alloc.dupe(u64, &.{ 4, 3, 5, 3, 9, 3 });
    defer alloc.free(right);

    try std.testing.expectEqual(31, part2(left, right));
}
