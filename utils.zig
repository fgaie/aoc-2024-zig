const std = @import("std");

pub fn absDiff(x: anytype, y: @TypeOf(x)) @TypeOf(x, y) {
    return @abs(@max(x, y) - @min(x, y));
}

pub fn print_slice(T: type, xs: []const T) void {
    if (@typeInfo(T) != .Int) @compileError("int slice only");

    std.debug.print("[", .{});
    for (xs, 0..) |x, i| {
        if (i > 0) {
            std.debug.print(", ", .{});
        }
        std.debug.print("{d}", .{x});
    }
    std.debug.print("]", .{});
}
