const std = @import("std");

pub const DirectoryStats = struct { file_count: usize = 0, directory_count: usize = 0 };

pub fn createFile(filename: []const u8) anyerror!void {
    std.log.info("Writing file {s}\n", .{filename});
    const file = try std.fs.cwd().createFile(filename, .{ .read = true });

    defer file.close();

    try file.writeAll("Results data");
}

pub fn readDirectory(directory: []const u8) anyerror!DirectoryStats {
    std.log.info("Reading directory: {s}", .{directory});
    var iter_dir = try std.fs.cwd().openIterableDir(directory, .{});

    defer iter_dir.close();

    var iter = iter_dir.iterate();

    var directory_stats: DirectoryStats = DirectoryStats{};

    while (try iter.next()) |entry| {
        if (entry.kind == .file) directory_stats.file_count += 1;
        if (entry.kind == .directory) {
            directory_stats.directory_count += 1;
            std.log.info("{s}", .{entry.name});
        }
    }

    return directory_stats;
}

pub fn makeDirectory(directory: []const u8) anyerror!void {
    std.log.info("Creating directory: {s}", .{directory});

    try std.fs.cwd().makePath(directory);
}
