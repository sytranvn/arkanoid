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
const PADDING = 2;

const BRICK_SIZE = rl.Vector2{ .x = (WIN_WIDTH - PADDING) / BRICKS_PER_LINE - 2, .y = 20 };
const PLAYER_SIZE = rl.Vector2{ .x = 100, .y = 20 };
const PLAYER_SPEED = 6;
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
        UpdateDrawFrame();
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
    life: i32,
};
const Ball = struct {
    position: rl.Vector2 = rl.Vector2{ .x = 0, .y = 0 },
    speed: rl.Vector2 = rl.Vector2{ .x = 0, .y = 0 },
    radius: f32 = 10,
    active: bool = false,
};
//----------------------------------------------------------------------------------
// Global Variables Definition
// -----------------------------------------------------------------------------------

var bricks = [_][BRICKS_PER_LINE]Brick{[_]Brick{.{
    .position = rl.Vector2{ .x = 0, .y = 0 },
    .active = true,
}} ** BRICKS_PER_LINE} ** LINES_OF_BRICKS;
var player = Player{ .position = rl.Vector2{ .x = WIN_WIDTH / 2 - PLAYER_SIZE.x / 2, .y = WIN_HEIGHT - PLAYER_SIZE.y - 10 }, .active = true, .life = 3 };
var ball = Ball{};
var gameOver = false;
var paused = false;
//------------------------------------------------------------------------------------
// Module Functions Declaration (local)
//------------------------------------------------------------------------------------

// Initialize game
fn InitGame() void {
    for (0..LINES_OF_BRICKS) |i| {
        for (0..BRICKS_PER_LINE) |j| {
            bricks[i][j].position.x = PADDING + @as(f32, @floatFromInt(j)) * (WIN_WIDTH / BRICKS_PER_LINE);
            bricks[i][j].position.y = @as(f32, @floatFromInt(i)) * BRICK_SIZE.y + @as(f32, @floatFromInt(i)) * 2;
        }
    }
    ball = Ball{ .position = rl.Vector2{ .x = player.position.x + PLAYER_SIZE.x / 2, .y = player.position.y - ball.radius } };
}

// Update game (one frame)
fn UpdateGame() void {
    if (player.life != 0) {
        if (rl.IsKeyPressed(rl.KEY_P))
            paused = !paused;
        if (!paused) {
            if (rl.IsKeyDown(rl.KEY_L)) {
                if (player.position.x <= WIN_WIDTH - PLAYER_SIZE.x) {
                    player.position.x += PLAYER_SPEED;
                    if (!ball.active)
                        ball.position.x += PLAYER_SPEED;
                }
            }

            if (rl.IsKeyDown(rl.KEY_J)) {
                if (player.position.x >= 0) {
                    player.position.x -= PLAYER_SPEED;
                    if (!ball.active)
                        ball.position.x -= PLAYER_SPEED;
                }
            }
            if (!ball.active) {
                if (rl.IsKeyPressed(rl.KEY_SPACE)) {
                    ball.active = true;
                    ball.position = rl.Vector2{ .x = player.position.x + PLAYER_SIZE.x / 2, .y = player.position.y - 10 };
                    ball.speed = rl.Vector2{ .x = 5, .y = 5 };
                }
            }
            ball.position.x += ball.speed.x;
            ball.position.y -= ball.speed.y;
            // Collision player-ball
            if (rl.CheckCollisionCircleRec(ball.position, ball.radius, rl.Rectangle{ .x = player.position.x, .y = player.position.y, .width = PLAYER_SIZE.x, .height = PLAYER_SIZE.y })) {
                ball.speed.y *= -1;
            }
            // Collision ball-wall
            if ((ball.position.x + ball.radius) >= WIN_WIDTH or (ball.position.x - ball.radius) <= 0)
                ball.speed.x *= -1;
            if ((ball.position.y - ball.radius) <= 0)
                ball.speed.y *= -1;
            if ((ball.position.y + ball.radius) >= WIN_HEIGHT) {
                player.life -= 1;
                ball.position = rl.Vector2{ .x = player.position.x + PLAYER_SIZE.x / 2, .y = player.position.y - ball.radius };
                ball.active = false;
                ball.speed = rl.Vector2{ .x = 0, .y = 0 };
            }
            // Collision ball-bricks
            for (0..LINES_OF_BRICKS) |i| {
                for (0..BRICKS_PER_LINE) |j| {
                    if (bricks[i][j].active) {
                        if (rl.CheckCollisionCircleRec(ball.position, ball.radius, rl.Rectangle{ .x = bricks[i][j].position.x, .y = bricks[i][j].position.y, .width = BRICK_SIZE.x, .height = BRICK_SIZE.y })) {
                            ball.speed.x *= -1;
                            ball.speed.y *= -1;
                            bricks[i][j].active = false;
                        }
                        // hit below
                        // if ((ball.position.y - ball.radius) <= (bricks[i][j].position.y + BRICK_SIZE.y / 2) and
                        //     // (ball.position.y - ball.radius > bricks[i][j].position.y + BRICK_SIZE.y + ball.speed.y) and
                        //     // (std.math.fabs(ball.position.x - bricks[i][j].position.x) < BRICK_SIZE.x / 2 + ball.radius * 2 / 3) and
                        //     ball.speed.y < 0)
                        // {
                        //     rl.TraceLog(rl.LOG_INFO, "HIT ball %f %f brick %d %d - %f", ball.position.y, ball.position.x, i, j, ball.speed.y);
                        // }
                        // if ((ball.position.y - ball.radius) <= (bricks[i][j].position.y + BRICK_SIZE.y / 2) and
                        //     // (ball.position.y - ball.radius > bricks[i][j].position.y + BRICK_SIZE.y + ball.speed.y) and
                        //     // (std.math.fabs(ball.position.x - bricks[i][j].position.x) < BRICK_SIZE.x / 2 + ball.radius * 2 / 3) and
                        //     ball.speed.y < 0)
                        // {
                        //     ball.speed.y *= -1;
                        //     rl.TraceLog(rl.LOG_INFO, "Ball speed %f", ball.speed.y);
                        //     bricks[i][j].active = false;
                        // }
                        // // hit above
                        // else if (false) {
                        //     ball.speed.y *= -1;
                        //     bricks[i][j].active = false;
                        // }
                        // // hit left
                        // else if (false) {
                        //     ball.speed.x *= -1;
                        //     bricks[i][j].active = false;
                        // }
                        // // hit left
                        // else if (false) {
                        //     ball.speed.x *= -1;
                        //     bricks[i][j].active = false;
                        // }
                    }
                }
            }
        }
    }
}

// Draw game (one frame)
fn DrawGame() void {
    drawPlayer(player);
    drawBall(ball);
    for (bricks) |line_of_bricks| {
        for (line_of_bricks) |b| {
            if (b.active)
                drawBrick(b);
        }
    }
}

// Update and Draw (one frame)
fn UpdateDrawFrame() void {
    UpdateGame();
    DrawGame();
}

//------------------------------------------------------------------------------------
// helper functions
// -----------------------------------------------------------------------------------
fn drawBrick(brick: Brick) void {
    rl.DrawRectangleV(brick.position, BRICK_SIZE, rl.BLACK);
}
fn drawPlayer(p: Player) void {
    rl.DrawRectangleV(p.position, PLAYER_SIZE, rl.RED);
}
fn drawBall(b: Ball) void {
    rl.DrawCircleV(b.position, b.radius, rl.GREEN);
}
