const std = @import("std");

pub fn main() !void {
    const filename = "test_file.txt";

    const file = try createFile(filename);
    _ = file;
}

pub fn createFile(filename: []const u8) anyerror![]const u8 {
    std.log.info("Writing file {s}", .{filename});
    const file = try std.fs.cwd().createFile(filename, .{ .read = true });

    defer file.close();

    try file.writeAll("Hello File!");

    return "Success";
}

test "createFile" {
    const filename = "test_file.txt";

    const message = try createFile(filename);

    try std.testing.expect(std.mem.eql(u8, message, "Success"));
}
