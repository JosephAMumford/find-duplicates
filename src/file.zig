const std = @import("std");
const allocator = std.heap.page_allocator;
const ArrayList = std.ArrayList;

pub const DirectoryStats = struct { file_count: usize = 0, directory_count: usize = 0 };

pub fn createFile(filename: []const u8) anyerror!void {
    std.log.info("Writing file {s}\n", .{filename});
    const file = try std.fs.cwd().createFile(filename, .{ .read = true });

    defer file.close();

    try file.writeAll("Results data");
}

pub fn readDirectory(directory: []const u8) anyerror!DirectoryStats {
    var file_hash_map = std.StringHashMap([]const u8).init(allocator);
    var iter_dir = try std.fs.cwd().openIterableDir(directory, .{});
    var duplicate_files = ArrayList([]const u8).init(allocator);

    std.log.info("Reading directory: {s}", .{directory});

    defer {
        iter_dir.close();
        file_hash_map.deinit();
        duplicate_files.deinit();
    }

    var iter = iter_dir.iterate();

    var directory_stats: DirectoryStats = DirectoryStats{};

    while (try iter.next()) |entry| {
        if (entry.kind == .file) {
            const key = try allocator.alloc(u8, entry.name.len);
            std.mem.copy(u8, key[0..], entry.name);
            const path = try createAbsolutePath(directory, key);

            //TODO: if entry exists, add to duplicate list

            const hash_result = try file_hash_map.getOrPut(key);

            if (hash_result.found_existing == true) {
                try duplicate_files.append(path);
                try duplicate_files.append(hash_result.value_ptr.*);
            } else {
                try file_hash_map.put(key, path);
            }

            directory_stats.file_count += 1;
        }

        if (entry.kind == .directory) {
            directory_stats.directory_count += 1;
        }
    }

    //TODO: Replace with loop through duplicates and write to duplicates found file
    var file_hash_map_iter = file_hash_map.iterator();
    while (file_hash_map_iter.next()) |file_entry| {
        std.log.info("hash map - {s} : {s}", .{ file_entry.key_ptr.*, file_entry.value_ptr.* });
    }

    return directory_stats;
}

pub fn createAbsolutePath(directory: []const u8, filename: []const u8) ![]const u8 {
    const path = try allocator.alloc(u8, directory.len + filename.len);
    std.mem.copy(u8, path[0..], directory);
    std.mem.copy(u8, path[directory.len..], filename);
    std.log.info("{s}", .{path});

    return path;
}

pub fn makeDirectory(directory: []const u8) anyerror!void {
    std.log.info("Creating directory: {s}", .{directory});

    try std.fs.cwd().makePath(directory);
}
