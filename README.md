# Find-Duplicates

This is a simple CLI tool to find duplicates files within the specified directory. Tool will prompt to enter base directory to scan, enter absolute base directory path like `c:/test/`. Currently, you need to add the trailing slash. All sub-drectories will also be scanned and any duplicate files will be saved to a file in the `results` folder which will be created automatically in the same directory where you run this tool. The duplicate results file will include the full path of duplicates.

Currently only tested on Windows.

## Dependencies

None

## Build and run

```
zig build run
```
