const std = @import("std");
const utils = @import("utils.zig");

const input = @embedFile("day2.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const alloc = gpa.allocator();

    var reports = std.ArrayList([]const usize).init(alloc);
    defer {
        for (reports.items) |report| alloc.free(report);
        reports.deinit();
    }

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        var buffer = std.ArrayList(usize).init(alloc);
        errdefer buffer.deinit();

        var numbers = std.mem.tokenizeScalar(u8, line, ' ');
        while (numbers.next()) |number| {
            try buffer.append(try std.fmt.parseInt(usize, number, 10));
        }

        try reports.append(try buffer.toOwnedSlice());
    }

    const start = std.time.microTimestamp();

    std.debug.print("part1: {}\n", .{part1(reports.items)});
    const t1 = std.time.microTimestamp();
    std.debug.print("  took {d:.3}ms\n\n", .{@as(f32, @floatFromInt(t1 - start)) / 1000.0});

    std.debug.print("part2: {}\n", .{try part2(alloc, reports.items)});
    const t2 = std.time.microTimestamp();
    std.debug.print("  took {d:.3}ms\n\n", .{@as(f32, @floatFromInt(t2 - t1)) / 1000.0});
}

fn check(increasing: bool, a: usize, b: usize) bool {
    const diff = utils.absDiff(a, b);
    return diff >= 1 and diff <= 3 and ((increasing and b > a) or (!increasing and b < a));
}

fn part1_isokay(report: []const usize) bool {
    if (report.len < 2) {
        return true;
    }

    const increasing = report[1] > report[0];
    for (report[0 .. report.len - 1], report[1..]) |a, b| {
        if (!check(increasing, a, b)) {
            return false;
        }
    }

    return true;
}

fn part1(reports: []const []const usize) usize {
    var res: usize = 0;

    for (reports) |report| {
        if (part1_isokay(report)) {
            res += 1;
        }
    }

    return res;
}

test "part1" {
    try std.testing.expectEqual(2, part1(&.{
        &.{ 7, 6, 4, 2, 1 },
        &.{ 1, 2, 7, 8, 9 },
        &.{ 9, 7, 6, 2, 1 },
        &.{ 1, 3, 2, 4, 5 },
        &.{ 8, 6, 4, 4, 1 },
        &.{ 1, 3, 6, 7, 9 },
    }));
}

fn part2_isokay(alloc: std.mem.Allocator, report: []const usize) !bool {
    if (part1_isokay(report)) {
        return true;
    }

    if (report.len <= 2) {
        return true;
    }

    const buf = try alloc.alloc(usize, report.len - 1);
    defer alloc.free(buf);

    @memcpy(buf, report[1..]);

    for (buf, report[0 .. report.len - 1]) |*r, x| {
        if (part1_isokay(buf)) {
            return true;
        }

        r.* = x;
    }

    return part1_isokay(buf);
}

fn part2(alloc: std.mem.Allocator, reports: []const []const usize) !usize {
    var res: usize = 0;

    for (reports) |report| {
        const ok = try part2_isokay(alloc, report);
        if (ok) {
            res += 1;
        }
    }

    return res;
}

test "part2" {
    const alloc = std.testing.allocator;

    // you can see how much I struggled to get this to work :(
    const ok: []const []const usize = &.{
        &.{ 1, 3, 2, 4, 5 },
        &.{ 7, 6, 4, 2, 1 },
        &.{ 8, 6, 4, 4, 1 },
        &.{ 1, 3, 6, 7, 9 },
        &.{ 12, 10, 13, 16, 19, 21, 22 },
        &.{ 78, 76, 80, 81, 84, 87 },
        &.{ 1, 2, 3, 4 },
        &.{ 2, 1, 2, 3, 4 },
        &.{ 1, 3, 2, 3, 4 },
        &.{ 1, 2, 4, 3, 4 },
        &.{ 1, 2, 3, 5, 4 },
        &.{ 1, 2, 3, 4, 3 },
        &.{ 48, 46, 47, 49, 51, 54, 56 },
        &.{ 1, 1, 2, 3, 4, 5 },
        &.{ 1, 2, 3, 4, 5, 5 },
        &.{ 5, 1, 2, 3, 4, 5 },
        &.{ 1, 4, 3, 2, 1 },
        &.{ 1, 6, 7, 8, 9 },
        &.{ 1, 2, 3, 4, 3 },
        &.{ 9, 8, 7, 6, 7 },
        &.{ 7, 10, 8, 10, 11 },
        &.{ 29, 28, 27, 25, 26, 25, 22, 20 },
        &.{ 7, 10, 8, 10, 11 },
        &.{ 29, 28, 27, 25, 26, 25, 22, 20 },
        &.{ 8, 9, 10, 11 },
        &.{ 29, 28, 27, 25, 26, 25, 22, 20 },
        &.{ 1, 2, 3, 4, 5, 5 },
        &.{ 52, 51, 52, 49, 47, 45 },
        &.{ 2, 1, 3, 5, 8 },
    };

    const notok: []const []const usize = &.{
        &.{ 1, 2, 7, 8, 9 },
        &.{ 9, 7, 6, 2, 1 },
        &.{ 12, 11, 12, 15, 16, 15 },
        &.{ 999, 1, 2, 3, 4, 999 },
        &.{ 1, 1, 1, 1 },
    };

    for (ok) |xs| {
        try std.testing.expect(try part2_isokay(alloc, xs));
    }

    for (notok) |xs| {
        try std.testing.expect(!try part2_isokay(alloc, xs));
    }
}
