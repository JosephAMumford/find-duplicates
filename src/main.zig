const std = @import("std");
const file = @import("file.zig");

pub fn main() !void {
    const stdin = std.io.getStdIn();
    const stdout = std.io.getStdOut();

    try stdout.writer().print("Enter directory to scan: ", .{});

    var buffer: [100]u8 = undefined;
    const input: []const u8 = (try nextLine(stdin.reader(), &buffer)).?;

    const number_of_files: usize = try file.readDirectory(input);
    std.log.info("Number of files: {}", .{number_of_files});
}

pub fn nextLine(reader: anytype, buffer: []u8) !?[]const u8 {
    var line = (try reader.readUntilDelimiterOrEof(buffer, '\n')) orelse return null;

    if (@import("builtin").os.tag == .windows) {
        return std.mem.trimRight(u8, line, "\r");
    } else {
        return line;
    }
}
