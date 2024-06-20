const std = @import("std");

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const cwd = std.fs.cwd();
    var file = try cwd.openFile("input.txt", .{ .mode = .read_only });
    defer file.close();
    const file_size = (try file.stat()).size;
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var sum: i32 = 0;
    while (true) {
        const buffer = file.reader().readUntilDelimiterAlloc(allocator, '\n', file_size) catch |err| {
            if (err == error.EndOfStream) {
                std.debug.print(" EOF \n ", .{});
                break;
            } else {
                return err;
            }
        };
        defer allocator.free(buffer);
        std.debug.print("Line: {s}\n", .{buffer});

        var first_digit: ?u8 = null;
        var last_digit: ?u8 = null;

        for (buffer) |char| {
            if (std.ascii.isDigit(char)) {
                if (first_digit == null) {
                    first_digit = char;
                }
                last_digit = char;
            }
        }

        if (first_digit != null and last_digit != null) {
            const number = try std.fmt.parseInt(i32, &[_]u8{ first_digit.?, last_digit.? }, 10);
            sum += number;
            std.debug.print("First digit: {c}, Last digit: {c}, Number: {d}\n", .{ first_digit.?, last_digit.?, number });
        } else {
            std.debug.print("No digits found in the line.\n", .{});
        }
    }
    std.debug.print("Sum {d}", .{sum});
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
