const std = @import("std");
const file = @import("file.zig");
const DirectoryStats = file.DirectoryStats;

pub fn main() !void {
    const stdin = std.io.getStdIn();
    const stdout = std.io.getStdOut();

    try stdout.writer().print("Enter directory to scan: ", .{});

    var buffer: [100]u8 = undefined;
    const input: []const u8 = (try nextLine(stdin.reader(), &buffer)).?;

    //Get initial directory
    const scanned_directory: DirectoryStats = try file.readDirectory(input);

    std.log.info("File count: {}", .{scanned_directory.file_count});
    std.log.info("Sub-directory count: {}", .{scanned_directory.directory_count});

    //Create directory to store results
    try file.makeDirectory("../results");
}

pub fn nextLine(reader: anytype, buffer: []u8) !?[]const u8 {
    var line = (try reader.readUntilDelimiterOrEof(buffer, '\n')) orelse return null;

    if (@import("builtin").os.tag == .windows) {
        return std.mem.trimRight(u8, line, "\r");
    } else {
        return line;
    }
}
