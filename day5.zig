const std = @import("std");
const utils = @import("utils.zig");

const input = @embedFile("day5.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const alloc = gpa.allocator();

    var rules = std.ArrayList([2]u64).init(alloc);
    defer rules.deinit();

    var updates = std.ArrayList([]const u64).init(alloc);
    defer {
        for (updates.items) |update| {
            alloc.free(update);
        }
        updates.deinit();
    }

    var parts = std.mem.tokenizeSequence(u8, input, "\n\n");
    const rulesPart = parts.next() orelse @panic("input");
    const updatesPart = parts.next() orelse @panic("input");

    var rulesLines = std.mem.tokenizeScalar(u8, rulesPart, '\n');
    while (rulesLines.next()) |line| {
        var numbers = std.mem.tokenizeScalar(u8, line, '|');
        const leftS = numbers.next() orelse continue;
        const rightS = numbers.next() orelse continue;

        try rules.append(.{
            try std.fmt.parseInt(u64, leftS, 10),
            try std.fmt.parseInt(u64, rightS, 10),
        });
    }

    var updatesLines = std.mem.tokenizeScalar(u8, updatesPart, '\n');
    while (updatesLines.next()) |line| {
        var numbers = std.mem.tokenizeScalar(u8, line, ',');
        var update = std.ArrayList(u64).init(alloc);
        errdefer update.deinit();

        while (numbers.next()) |nS| {
            try update.append(try std.fmt.parseInt(u64, nS, 10));
        }

        try updates.append(try update.toOwnedSlice());
    }

    const start = std.time.microTimestamp();

    std.debug.print("part1: {}\n", .{part1(rules.items, updates.items)});
    const t1 = std.time.microTimestamp();
    std.debug.print("  took {d:.3}ms\n\n", .{@as(f32, @floatFromInt(t1 - start)) / 1000.0});

    std.debug.print("part2: {}\n", .{try part2(alloc, rules.items, updates.items)});
    const t2 = std.time.microTimestamp();
    std.debug.print("  took {d:.3}ms\n\n", .{@as(f32, @floatFromInt(t2 - t1)) / 1000.0});
}

fn correct(rule: [2]u64, update: []const u64) bool {
    for (update, 0..) |page, i| {
        if (page == rule[1] and
            std.mem.indexOfScalarPos(
            u64,
            update,
            i + 1,
            rule[0],
        ) != null) {
            return false;
        }
    }

    return true;
}

fn part1(rules: []const [2]u64, updates: []const []const u64) u64 {
    var res: u64 = 0;

    updates: for (updates) |update| {
        for (rules) |rule| {
            if (!correct(rule, update)) {
                continue :updates;
            }
        }

        res += update[@divFloor(update.len, 2)];
    }

    return res;
}

test "part1" {
    try std.testing.expectEqual(143, part1(
        &.{
            .{ 47, 53 },
            .{ 97, 13 },
            .{ 97, 61 },
            .{ 97, 47 },
            .{ 75, 29 },
            .{ 61, 13 },
            .{ 75, 53 },
            .{ 29, 13 },
            .{ 97, 29 },
            .{ 53, 29 },
            .{ 61, 53 },
            .{ 97, 53 },
            .{ 61, 29 },
            .{ 47, 13 },
            .{ 75, 47 },
            .{ 97, 75 },
            .{ 47, 61 },
            .{ 75, 61 },
            .{ 47, 29 },
            .{ 75, 13 },
            .{ 53, 13 },
        },
        &.{
            &.{ 75, 47, 61, 53, 29 },
            &.{ 97, 61, 53, 29, 13 },
            &.{ 75, 29, 13 },
            &.{ 75, 97, 47, 61, 53 },
            &.{ 61, 13, 29 },
            &.{ 97, 13, 75, 29, 47 },
        },
    ));
}

fn part2(alloc: std.mem.Allocator, rules: []const [2]u64, updates: []const []const u64) !u64 {
    var res: u64 = 0;

    for (updates) |update| {
        var iscorrect = true;
        for (rules) |rule| {
            if (!correct(rule, update)) {
                iscorrect = false;
            }
        }

        if (iscorrect) continue;

        const updateDupe = try alloc.dupe(u64, update);
        defer alloc.free(updateDupe);

        while (!iscorrect) {
            iscorrect = true;
            for (rules) |rule| {
                while (!correct(rule, updateDupe)) {
                    iscorrect = false;
                    const i = std.mem.indexOfScalar(u64, updateDupe, rule[1]).?;
                    // assuming pages are unique
                    std.mem.swap(u64, &updateDupe[i], &updateDupe[i + 1]);
                }
            }
        }

        res += updateDupe[@divFloor(updateDupe.len, 2)];
    }

    return res;
}

test "part2" {
    try std.testing.expectEqual(123, try part2(
        std.testing.allocator,
        &.{
            .{ 47, 53 },
            .{ 97, 13 },
            .{ 97, 61 },
            .{ 97, 47 },
            .{ 75, 29 },
            .{ 61, 13 },
            .{ 75, 53 },
            .{ 29, 13 },
            .{ 97, 29 },
            .{ 53, 29 },
            .{ 61, 53 },
            .{ 97, 53 },
            .{ 61, 29 },
            .{ 47, 13 },
            .{ 75, 47 },
            .{ 97, 75 },
            .{ 47, 61 },
            .{ 75, 61 },
            .{ 47, 29 },
            .{ 75, 13 },
            .{ 53, 13 },
        },
        &.{
            &.{ 75, 47, 61, 53, 29 },
            &.{ 97, 61, 53, 29, 13 },
            &.{ 75, 29, 13 },
            &.{ 75, 97, 47, 61, 53 },
            &.{ 61, 13, 29 },
            &.{ 97, 13, 75, 29, 47 },
        },
    ));
}
