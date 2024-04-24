const std = @import("std");
const Build = std.Build;
const raylib = @import("raylib");

const OptimizeMode = std.builtin.OptimizeMode;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const raylib_dep = b.dependency("raylib", .{
        .target = target,
        .optimize = optimize,
    });

    const raylib_artifact = raylib_dep.artifact("raylib");
    b.installArtifact(raylib_artifact);

    const exe = b.addExecutable(.{
        .name = "zig-arkanoid",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    exe.linkLibrary(raylib_artifact);
    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

// this is the regular build for all native platforms, nothing surprising here
fn buildNative(b: *Build, target: Build.ResolvedTarget, optimize: OptimizeMode, dep_raylib: *Build.Dependency) !void {
    const pacman = b.addExecutable(.{
        .name = "pacman",
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/pacman.zig"),
    });
    pacman.root_module.addImport("raylib", dep_raylib.module("raylib"));
    b.installArtifact(pacman);
    const run = b.addRunArtifact(pacman);
    b.step("run", "Run pacman").dependOn(&run.step);
}

// for web builds, the Zig code needs to be built into a library and linked with the Emscripten linker
fn buildWeb(b: *Build, target: Build.ResolvedTarget, optimize: OptimizeMode, dep_raylib: *Build.Dependency) !void {
    // ref https://github.com/floooh/pacman.zig/blob/main/build.zig
    const pacman = b.addStaticLibrary(.{
        .name = "pacman",
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/pacman.zig"),
    });
    pacman.root_module.addImport("raylib", dep_raylib.module("raylib"));

    // create a build step which invokes the Emscripten linker
    const emsdk = dep_raylib.builder.dependency("emsdk", .{});
    const link_step = try raylib.emLinkStep(b, .{
        .lib_main = pacman,
        .target = target,
        .optimize = optimize,
        .emsdk = emsdk,
        .use_webgl2 = true,
        .use_emmalloc = true,
        .use_filesystem = false,
        .shell_file_path = dep_raylib.path("src/raylib/web/shell.html").getPath(b),
    });
    // ...and a special run step to start the web build output via 'emrun'
    const run = raylib.emRunStep(b, .{ .name = "pacman", .emsdk = emsdk });
    run.step.dependOn(&link_step.step);
    b.step("run", "Run pacman").dependOn(&run.step);
}
