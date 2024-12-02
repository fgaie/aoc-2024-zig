pub fn absDiff(x: anytype, y: @TypeOf(x)) @TypeOf(x, y) {
    return @abs(@max(x, y) - @min(x, y));
}
