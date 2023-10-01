const std = @import("std");
const allocator = std.heap.page_allocator;
const ArrayList = std.ArrayList;

pub var directory_list = ArrayList([]const u8).init(allocator);
pub var file_hash_map = std.StringHashMap([]const u8).init(allocator);
pub var duplicate_files = ArrayList([]const u8).init(allocator);

pub fn createFile(filename: []const u8) anyerror!void {
    std.log.info("Writing file {s}\n", .{filename});
    const file = try std.fs.cwd().createFile(filename, .{ .read = true });

    defer file.close();

    for (duplicate_files.items) |entry| {
        const key = try allocator.alloc(u8, entry.len);
        std.mem.copy(u8, key[0..], entry);
        try file.writeAll(key);
        try file.writeAll("\n");
    }
}

pub fn scanFiles(directory: []const u8) !void {
    std.log.info("Scanning directory: {s}", .{directory});
    var iter_dir = try std.fs.openIterableDirAbsolute(directory, .{});
    defer {
        iter_dir.close();
    }

    var iter = iter_dir.iterate();

    while (try iter.next()) |entry| {
        if (entry.kind == .file) {
            const key = try allocator.alloc(u8, entry.name.len);
            std.mem.copy(u8, key[0..], entry.name);
            const path = try createAbsolutePath(directory, key);

            const hash_result = try file_hash_map.getOrPut(key);

            if (hash_result.found_existing == true) {
                try duplicate_files.append(path);
                try duplicate_files.append(hash_result.value_ptr.*);
            } else {
                try file_hash_map.put(key, path);
            }
        }
    }
}

pub fn getFilesAndDirectories(directory: []const u8) !void {
    var iter_dir = try std.fs.openIterableDirAbsolute(directory, .{});
    defer iter_dir.close();

    var iter = iter_dir.iterate();

    while (try iter.next()) |entry| {
        if (entry.kind == .directory) {
            const sub_directory_path = try createDirectoryPath(directory, entry.name);
            try directory_list.append(sub_directory_path);
            try getFilesAndDirectories(sub_directory_path);
        }
    }
}

pub fn createDirectoryPath(base_dir: []const u8, sub_dir: []const u8) ![]const u8 {
    const path = try allocator.alloc(u8, base_dir.len + sub_dir.len + 1);
    std.mem.copy(u8, path[0..], base_dir);
    std.mem.copy(u8, path[base_dir.len..], sub_dir);
    path[path.len - 1] = '/';

    return path;
}

pub fn createAbsolutePath(directory: []const u8, filename: []const u8) ![]const u8 {
    const path = try allocator.alloc(u8, directory.len + filename.len);
    std.mem.copy(u8, path[0..], directory);
    std.mem.copy(u8, path[directory.len..], filename);

    return path;
}

pub fn makeDirectory(directory: []const u8) anyerror!void {
    std.log.info("Creating directory: {s}", .{directory});

    try std.fs.cwd().makePath(directory);
}
