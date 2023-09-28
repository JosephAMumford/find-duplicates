const std = @import("std");

pub fn main() !void {

    const stdin = std.io.getStdIn();
    const stdout = std.io.getStdOut();

    try stdout.writer().print("Enter directory to scan: ", .{});
    
    var buffer: [100]u8 = undefined;
    const input: []const u8 = (try nextLine(stdin.reader(), &buffer)).?;

    std.log.info("Input: {s} Type: {}", .{ input, @TypeOf(input) });

    const number_of_files: usize = try readDirectory(input);
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

pub fn createFile(filename: []const u8) anyerror![]const u8 {
    std.log.info("Writing file {s}\n", .{filename});
    const file = try std.fs.cwd().createFile(filename, .{ .read = true });

    defer file.close();

    try file.writeAll("Hello File!");

    return "Success";
}

pub fn readDirectory(directory: []const u8) anyerror!usize {
    std.log.info("Reading directory: {s}", .{directory});
    var iter_dir = try std.fs.cwd().openIterableDir(directory, .{});

    defer {
        iter_dir.close();
        //std.fs.cwd().deleteTree(directory) catch unreachable; //Delete directory
    }

    var file_count: usize = 0;
    var iter = iter_dir.iterate();

    while (try iter.next()) |entry| {
        if (entry.kind == .file) file_count += 1;
    }

    return file_count;
}

test "createFile" {
    const filename = "test_file.txt";

    const message = try createFile(filename);

    try std.testing.expect(std.mem.eql(u8, message, "Success"));
}
