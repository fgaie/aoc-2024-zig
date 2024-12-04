const std = @import("std");
const utils = @import("utils.zig");

const input = @embedFile("day4.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const alloc = gpa.allocator();

    var lines = std.ArrayList([]const u8).init(alloc);
    defer lines.deinit();

    var linesiter = std.mem.tokenizeScalar(u8, input, '\n');
    while (linesiter.next()) |line| {
        try lines.append(line);
    }

    const start = std.time.microTimestamp();

    std.debug.print("part1: {}\n", .{part1(lines.items)});
    const t1 = std.time.microTimestamp();
    std.debug.print("  took {d:.3}ms\n\n", .{@as(f32, @floatFromInt(t1 - start)) / 1000.0});

    std.debug.print("part2: {}\n", .{part2(lines.items)});
    const t2 = std.time.microTimestamp();
    std.debug.print("  took {d:.3}ms\n\n", .{@as(f32, @floatFromInt(t2 - t1)) / 1000.0});
}

fn part1(in: []const []const u8) u64 {
    var res: u64 = 0;

    for (in, 0..) |line, i| {
        for (line, 0..) |c, j| {
            if (c != 'X') continue;

            // right
            if (j + 3 < line.len and
                line[j + 1] == 'M' and
                line[j + 2] == 'A' and
                line[j + 3] == 'S')
            {
                res += 1;
            }

            // left
            if (j >= 3 and
                line[j - 1] == 'M' and
                line[j - 2] == 'A' and
                line[j - 3] == 'S')
            {
                res += 1;
            }

            // bottom
            if (i + 3 < in.len and
                in[i + 1][j] == 'M' and
                in[i + 2][j] == 'A' and
                in[i + 3][j] == 'S')
            {
                res += 1;
            }

            // top
            if (i >= 3 and
                in[i - 1][j] == 'M' and
                in[i - 2][j] == 'A' and
                in[i - 3][j] == 'S')
            {
                res += 1;
            }

            // bottom right
            if (i + 3 < in.len and j + 3 < line.len and
                in[i + 1][j + 1] == 'M' and
                in[i + 2][j + 2] == 'A' and
                in[i + 3][j + 3] == 'S')
            {
                res += 1;
            }

            // bottom left
            if (i + 3 < in.len and j >= 3 and
                in[i + 1][j - 1] == 'M' and
                in[i + 2][j - 2] == 'A' and
                in[i + 3][j - 3] == 'S')
            {
                res += 1;
            }

            // top right
            if (i >= 3 and j + 3 < line.len and
                in[i - 1][j + 1] == 'M' and
                in[i - 2][j + 2] == 'A' and
                in[i - 3][j + 3] == 'S')
            {
                res += 1;
            }

            // top left
            if (i >= 3 and j >= 3 and
                in[i - 1][j - 1] == 'M' and
                in[i - 2][j - 2] == 'A' and
                in[i - 3][j - 3] == 'S')
            {
                res += 1;
            }
        }
    }

    return res;
}

test "part1" {
    try std.testing.expectEqual(18, part1(&.{
        "MMMSXXMASM",
        "MSAMXMSMSA",
        "AMXSXMAAMM",
        "MSAMASMSMX",
        "XMASAMXAMM",
        "XXAMMXXAMA",
        "SMSMSASXSS",
        "SAXAMASAAA",
        "MAMMMXMMMM",
        "MXMXAXMASX",
    }));
}

fn part2(in: []const []const u8) u64 {
    var res: u64 = 0;

    for (in, 0..) |line, i| {
        if (i == 0 or i == in.len - 1) {
            continue;
        }

        for (line, 0..) |c, j| {
            if (j == 0 or j == line.len - 1) {
                continue;
            }

            if (c != 'A') continue;

            const diag1 =
                (in[i - 1][j - 1] == 'M' and in[i + 1][j + 1] == 'S') or
                (in[i - 1][j - 1] == 'S' and in[i + 1][j + 1] == 'M');

            const diag2 =
                (in[i - 1][j + 1] == 'M' and in[i + 1][j - 1] == 'S') or
                (in[i - 1][j + 1] == 'S' and in[i + 1][j - 1] == 'M');

            if (diag1 and diag2) {
                res += 1;
            }
        }
    }

    return res;
}

test "part2" {
    try std.testing.expectEqual(9, part2(&.{
        "MMMSXXMASM",
        "MSAMXMSMSA",
        "AMXSXMAAMM",
        "MSAMASMSMX",
        "XMASAMXAMM",
        "XXAMMXXAMA",
        "SMSMSASXSS",
        "SAXAMASAAA",
        "MAMMMXMMMM",
        "MXMXAXMASX",
    }));
}
