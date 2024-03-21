const std = @import("std");
const rl = @cImport({
    @cInclude("raylib.h");
});
const gl = @cImport({
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
const BRICK_SIZE = rl.Vector2{ .x = WIN_WIDTH / BRICKS_PER_LINE - 2, .y = 20 };
const PLAYER_SIZE = rl.Vector2{ .x = 100, .y = 20 };
//----------------------------------------------------------------------------------
// main entry point
// -----------------------------------------------------------------------------------
pub fn main() !void {
    rl.InitWindow(WIN_WIDTH, WIN_HEIGHT, "Game on");

    defer rl.CloseWindow();

    rl.SetTargetFPS(60);
    InitGame();
    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        rl.ClearBackground(rl.RAYWHITE);
        DrawGame();
        rl.EndDrawing();
    }
}

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------
const Brick = struct {
    position: rl.Vector2,
    active: bool,
};
const Player = struct {
    position: rl.Vector2,
    active: bool,
};

//----------------------------------------------------------------------------------
// Global Variables Definition
// -----------------------------------------------------------------------------------

var Bricks = [_][BRICKS_PER_LINE]Brick{[_]Brick{.{
    .position = rl.Vector2{ .x = 0, .y = 0 },
    .active = true,
}} ** BRICKS_PER_LINE} ** LINES_OF_BRICKS;
var Player1 = Player{ .position = rl.Vector2{ .x = WIN_WIDTH / 2 - PLAYER_SIZE.x / 2, .y = WIN_HEIGHT - PLAYER_SIZE.y - 10 }, .active = true };
//------------------------------------------------------------------------------------
// Module Functions Declaration (local)
//------------------------------------------------------------------------------------
// Initialize game
fn InitGame() void {
    for (0..LINES_OF_BRICKS) |i| {
        for (0..BRICKS_PER_LINE) |j| {
            Bricks[i][j].position.x = @as(f32, @floatFromInt(j)) * (WIN_WIDTH / BRICKS_PER_LINE);
            Bricks[i][j].position.y = @as(f32, @floatFromInt(i)) * BRICK_SIZE.y + @as(f32, @floatFromInt(i)) * 2;
        }
    }
    //Plaer1.position = rl.Vector2{ .x = WIN_WIDTH / 2 - PLAYER_SIZE.x / 2, .y = WIN_HEIGHT - PLAYER_SIZE.y - 10 };
}
fn UpdateGame() void {} // Update game (one frame)
// Draw game (one frame)
fn DrawGame() void {
    for (Bricks) |line_of_bricks| {
        for (line_of_bricks) |b| {
            if (b.active)
                drawBrick(b);
        }
    }
    drawPlayer(Player1);
}
fn UnloadGame() void {} // Unload game
fn UpdateDrawFrame() void {} // Update and Draw (one frame)

//------------------------------------------------------------------------------------
// helper functions
// -----------------------------------------------------------------------------------
fn drawBrick(brick: Brick) void {
    rl.DrawRectangleV(brick.position, BRICK_SIZE, rl.BLACK);
}
fn drawPlayer(player: Player) void {
    rl.DrawRectangleV(player.position, PLAYER_SIZE, rl.RED);
}
