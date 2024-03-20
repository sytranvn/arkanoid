const std = @import("std");
const c = @cImport({
    @cInclude("raylib.h");
    @cInclude("rlgl.h");
});

//----------------------------------------------------------------------------------
// Constants definition
//----------------------------------------------------------------------------------
const WIN_WIDTH = 800;
const WIN_HEIGHT = 600;
const PLAYER_MAX_LIFE = 5;
const LINES_OF_BRICKS = 5;
const BRICKS_PER_LINE = 20;

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------

pub fn main() !void {
    c.InitWindow(WIN_WIDTH, WIN_HEIGHT, "ZingZong");

    defer c.CloseWindow();

    c.SetTargetFPS(60);

    while (!c.WindowShouldClose()) {
        c.BeginDrawing();
        c.ClearBackground(c.BLACK);
        c.EndDrawing();
    }
}
