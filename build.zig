const std = @import("std");
const Pkg = std.build.Pkg;

const Packages = struct {
    // Declared here because submodule may not be cloned at the time build.zig runs.
    const zmath = std.build.Pkg{
        .name = "zmath",
        .source = .{ .path = "libs/zmath/src/zmath.zig" },
    };
};

pub fn build(b: *std.build.Builder) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const dvui_mod = b.addModule("dvui", .{
        .source_file = .{ .path = "src/dvui/dvui.zig" },
        .dependencies = &.{},
    });

    const sdl_mod = b.addModule("SDLBackend", .{
        .source_file = .{ .path = "src/dvui/SDLBackend.zig" },
        .dependencies = &.{
            .{ .name = "dvui", .module = dvui_mod },
        },
    });

    // shared modules.
    const message_mod = b.addModule("message", .{
        .source_file = .{ .path = "src/okp/shared/message/api.zig" },
        .dependencies = &.{},
    });
    const channel_mod = b.addModule("channel", .{
        .source_file = .{ .path = "src/okp/shared/channel/api.zig" },
        .dependencies = &.{
            .{ .name = "message", .module = message_mod },
        },
    });

    // frontend dependencies.
    const framers_mod = b.addModule("framers", .{
        .source_file = .{ .path = "src/okp/frontend/lib/framers/api.zig" },
        .dependencies = &.{},
    });

    const examples = [_][]const u8{
        "standalone-sdl",
        "ontop-sdl",
    };

    inline for (examples) |ex| {
        const exe = b.addExecutable(.{
            .name = ex,
            .root_source_file = .{ .path = ex ++ ".zig" },
            .target = target,
            .optimize = optimize,
        });

        exe.addModule("dvui", dvui_mod);
        exe.addModule("SDLBackend", sdl_mod);
        const freetype_dep = b.dependency("freetype", .{
            .target = target,
            .optimize = optimize,
        });

        // frontend modules.
        exe.addModule("framers", framers_mod);

        // shared modules.
        exe.addModule("message", message_mod);
        exe.addModule("channel", channel_mod);
        exe.linkLibrary(freetype_dep.artifact("freetype"));

        exe.linkSystemLibrary("SDL2");
        exe.linkLibC();
        if (target.isWindows()) {
            exe.linkSystemLibrary("setupapi");
            exe.linkSystemLibrary("winmm");
            exe.linkSystemLibrary("gdi32");
            exe.linkSystemLibrary("imm32");
            exe.linkSystemLibrary("version");
            exe.linkSystemLibrary("oleaut32");
            exe.linkSystemLibrary("ole32");
        }

        const compile_step = b.step(ex, "Compile " ++ ex);
        compile_step.dependOn(&b.addInstallArtifact(exe, .{}).step);
        b.getInstallStep().dependOn(compile_step);

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(compile_step);

        const run_step = b.step("run-" ++ ex, "Run " ++ ex);
        run_step.dependOn(&run_cmd.step);
    }

    // sdl test
    {
        const exe = b.addExecutable(.{
            .name = "sdl-test",
            .root_source_file = .{ .path = "sdl-test" ++ ".zig" },
            .target = target,
            .optimize = optimize,
        });

        exe.addModule("dvui", dvui_mod);
        exe.addModule("SDLBackend", sdl_mod);

        const freetype_dep = b.dependency("freetype", .{
            .target = target,
            .optimize = optimize,
        });
        exe.linkLibrary(freetype_dep.artifact("freetype"));

        //const sdl_dep = b.dependency("sdl", .{
        //.target = target,
        //.optimize = optimize,
        //});
        //exe.linkLibrary(sdl_dep.artifact("SDL2"));

        exe.linkSystemLibrary("SDL2");
        //exe.addIncludePath("/home/dvanderson/SDL/include");
        //exe.addObjectFile("/home/dvanderson/SDL/build/libSDL3.a");

        if (target.isDarwin()) {
            exe.linkSystemLibrary("z");
            exe.linkSystemLibrary("bz2");
            exe.linkSystemLibrary("iconv");
            exe.linkFramework("AppKit");
            exe.linkFramework("AudioToolbox");
            exe.linkFramework("Carbon");
            exe.linkFramework("Cocoa");
            exe.linkFramework("CoreAudio");
            exe.linkFramework("CoreFoundation");
            exe.linkFramework("CoreGraphics");
            exe.linkFramework("CoreHaptics");
            exe.linkFramework("CoreVideo");
            exe.linkFramework("ForceFeedback");
            exe.linkFramework("GameController");
            exe.linkFramework("IOKit");
            exe.linkFramework("Metal");
        } else if (target.isWindows()) {
            exe.linkSystemLibrary("setupapi");
            exe.linkSystemLibrary("winmm");
            exe.linkSystemLibrary("gdi32");
            exe.linkSystemLibrary("imm32");
            exe.linkSystemLibrary("version");
            exe.linkSystemLibrary("oleaut32");
            exe.linkSystemLibrary("ole32");
        }

        const compile_step = b.step("compile-" ++ "sdl-test", "Compile " ++ "sdl-test");
        compile_step.dependOn(&b.addInstallArtifact(exe, .{}).step);
        b.getInstallStep().dependOn(compile_step);

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(compile_step);

        const run_step = b.step("sdl-test", "Run " ++ "sdl-test");
        run_step.dependOn(&run_cmd.step);
    }
}
