const std = @import("std");
const utils = @import("utils.zig");

const input = @embedFile("day3.txt");

pub fn main() !void {
    const start = std.time.microTimestamp();

    std.debug.print("part1: {}\n", .{part1(input)});
    const t1 = std.time.microTimestamp();
    std.debug.print("  took {d:.3}ms\n\n", .{@as(f32, @floatFromInt(t1 - start)) / 1000.0});

    std.debug.print("part2: {}\n", .{part2(input)});
    const t2 = std.time.microTimestamp();
    std.debug.print("  took {d:.3}ms\n\n", .{@as(f32, @floatFromInt(t2 - t1)) / 1000.0});
}

fn parse_text(buf: *[]const u8, text: []const u8) ?void {
    if (std.mem.startsWith(u8, buf.*, text)) {
        buf.* = buf.*[text.len..];
        return;
    }

    return null;
}

fn parse_number(buf: *[]const u8) ?u64 {
    if (buf.*.len < 1) return null;
    if (!std.ascii.isDigit(buf.*[0])) {
        return null;
    }

    var l: u64 = @intCast(buf.*[0] - '0');
    buf.* = buf.*[1..];

    if (buf.*.len > 0 and std.ascii.isDigit(buf.*[0])) {
        l = l * 10 + (buf.*[0] - '0');
        buf.* = buf.*[1..];
    }

    if (buf.*.len > 0 and std.ascii.isDigit(buf.*[0])) {
        l = l * 10 + (buf.*[0] - '0');
        buf.* = buf.*[1..];
    }

    return l;
}

fn part1(in: []const u8) u64 {
    var res: u64 = 0;
    var _in = in;

    while (std.mem.indexOf(u8, _in, "mul(")) |i| {
        _in = _in[i..];
        parse_text(&_in, "mul(") orelse continue;
        const l = parse_number(&_in) orelse continue;
        parse_text(&_in, ",") orelse continue;
        const r = parse_number(&_in) orelse continue;
        parse_text(&_in, ")") orelse continue;

        res += l * r;
    }

    return res;
}

test "part1" {
    try std.testing.expectEqual(161, part1(
        "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))",
    ));
}

fn part2(in: []const u8) u64 {
    var res: u64 = 0;
    var _in = in;
    var do = true;

    while (_in.len > 0) {
        if (do) {
            if (parse_text(&_in, "don't()") != null) {
                do = false;
                continue;
            }

            parse_text(&_in, "mul(") orelse {
                _in = _in[1..];
                continue;
            };

            const l = parse_number(&_in) orelse continue;
            parse_text(&_in, ",") orelse continue;
            const r = parse_number(&_in) orelse continue;
            parse_text(&_in, ")") orelse continue;

            res += l * r;
        } else {
            if (parse_text(&_in, "do()") != null) {
                do = true;
                continue;
            }

            _in = _in[1..];
        }
    }

    return res;
}

test "part2" {
    try std.testing.expectEqual(48, part2(
        "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))",
    ));
}
