const std = @import("std");
const c = @cImport({
    @cInclude("raylib.h");
    @cInclude("rlgl.h");
});

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();
    c.InitWindow(800, 600, "hello");

    defer c.CloseWindow();

    c.SetTargetFPS(60);

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    while (!c.WindowShouldClose()) {
        c.BeginDrawing();
        c.ClearBackground(c.BLACK);
        c.EndDrawing();
    }

    try bw.flush(); // don't forget to flush!
}
