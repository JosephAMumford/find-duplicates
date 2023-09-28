const std = @import("std");

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
