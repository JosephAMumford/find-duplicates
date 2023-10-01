const std = @import("std");
const file = @import("file.zig");

pub fn main() !void {
    const stdin = std.io.getStdIn();
    const stdout = std.io.getStdOut();

    //Get user input
    try stdout.writer().print("Enter directory to scan: ", .{});

    var buffer: [100]u8 = undefined;
    const input: []const u8 = (try nextLine(stdin.reader(), &buffer)).?;

    //Create directory to store results
    try file.makeDirectory("../results");

    //get list of all sub-directories
    try file.directory_list.append(input);
    try file.getFilesAndDirectories(input);

    //Scan files to find duplcaites
    for (file.directory_list.items) |entry| {
        try file.scanFiles(entry);
    }

    try file.createFile("results/duplicates.txt");
}

pub fn nextLine(reader: anytype, buffer: []u8) !?[]const u8 {
    var line = (try reader.readUntilDelimiterOrEof(buffer, '\n')) orelse return null;

    if (@import("builtin").os.tag == .windows) {
        return std.mem.trimRight(u8, line, "\r");
    } else {
        return line;
    }
}
