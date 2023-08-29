const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const dvui_dep = b.dependency("dvui", .{ .target = target, .optimize = optimize });
    // WAS GOING TO TRY THIS. NOT SURE IF IT'S CORRECT.
    // const dvui_mod = b.addModule("dvui", .{
    //     .source_file = .{ .path = "lib/dvui/dvui.zig" },
    //     .dependencies = &.{},
    // });

    const sdl_mod = b.addModule("SDLBackend", .{
        .source_file = .{ .path = "lib/dvui/src/SDLBackend.zig" },
        .dependencies = &.{},
    });
    _ = sdl_mod;

    // shared modules.
    const message_mod = b.addModule("message", .{
        .source_file = .{ .path = "src/shared/message/api.zig" },
        .dependencies = &.{},
    });
    const channel_mod = b.addModule("channel", .{
        .source_file = .{ .path = "src/shared/channel/api.zig" },
        .dependencies = &.{
            .{ .name = "message", .module = message_mod },
        },
    });

    // frontend dependencies.
    const framers_mod = b.addModule("framers", .{
        .source_file = .{ .path = "src/frontend/lib/framers/api.zig" },
        .dependencies = &.{},
    });

    const examples = [_][]const u8{
        "standalone-sdl",
        // "ontop-sdl",
    };

    inline for (examples) |ex| {
        const exe = b.addExecutable(.{
            .name = ex,
            .root_source_file = .{ .path = ex ++ ".zig" },
            .target = target,
            .optimize = optimize,
        });

        exe.addModule("dvui", dvui_dep.module("dvui"));
        exe.addModule("SDLBackend", dvui_dep.module("SDLBackend"));

        // WAS GOING TO TRY THIS. NOT SURE IF IT'S CORRECT.
        // exe.addModule("dvui", dvui_mod);
        // exe.addModule("SDLBackend", sdl_mod);

        // frontend dependencies.
        exe.addModule("framers", framers_mod);

        // shared modules.
        exe.addModule("message", message_mod);
        exe.addModule("channel", channel_mod);

        // TODO: remove this part about freetype (pulling it from the dvui_dep
        // sub-builder) once https://github.com/ziglang/zig/pull/14731 lands
        const freetype_dep = dvui_dep.builder.dependency("freetype", .{
            .target = target,
            .optimize = optimize,
        });
        // WAS GOING TO TRY THIS. NOT SURE IF IT'S CORRECT.
        // const freetype_dep = dvui_mod.builder.dependency("freetype", .{
        //     .target = target,
        //     .optimize = optimize,
        // });
        exe.linkLibrary(freetype_dep.artifact("freetype"));

        exe.linkSystemLibrary("SDL2");
        exe.linkLibC();

        const compile_step = b.step(ex, "Compile " ++ ex);
        compile_step.dependOn(&b.addInstallArtifact(exe, .{}).step);
        b.getInstallStep().dependOn(compile_step);

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(compile_step);

        const run_step = b.step("run-" ++ ex, "Run " ++ ex);
        run_step.dependOn(&run_cmd.step);
    }
}
