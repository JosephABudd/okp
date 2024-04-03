const std = @import("std");
const Pkg = std.build.Pkg;
const Compile = std.Build.Step.Compile;

pub fn build(b: *std.build.Builder) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // VENDOR MODULES.

    // vendor/dvui/
    const lib_bundle = b.addStaticLibrary(.{
        .name = "dvui_libs",
        .target = target,
        .optimize = optimize,
    });
    lib_bundle.addCSourceFile(.{ .file = .{ .path = "src/vendor/dvui/src/stb/stb_image_impl.c" }, .flags = &.{} });
    lib_bundle.addCSourceFile(.{ .file = .{ .path = "src/vendor/dvui/src/stb/stb_truetype_impl.c" }, .flags = &.{} });
    link_deps(b, lib_bundle);
    b.installArtifact(lib_bundle);

    const dvui_mod = b.addModule("dvui", .{
        .source_file = .{ .path = "src/vendor/dvui/src/dvui.zig" },
        .dependencies = &.{},
    });

    const sdl_mod = b.addModule("SDLBackend", .{
        .source_file = .{ .path = "src/vendor/dvui/src/backends/SDLBackend.zig" },
        .dependencies = &.{
            .{ .name = "dvui", .module = dvui_mod },
        },
    });

    // FRAMEWORK MODULES.

    // channel_mod. A framework deps/ module.
    const channel_mod = b.addModule("channel", .{
        .source_file = .{ .path = "src/@This/deps/channel/api.zig" },
        .dependencies = &.{},
    });

    // closedownjobs_mod. A framework deps/ module.
    const closedownjobs_mod = b.addModule("closedownjobs", .{
        .source_file = .{ .path = "src/@This/deps/closedownjobs/api.zig" },
        .dependencies = &.{},
    });

    // closer_mod. A framework deps/ module.
    const closer_mod = b.addModule("closer", .{
        .source_file = .{ .path = "src/@This/deps/closer/api.zig" },
        .dependencies = &.{},
    });

    // counter_mod. A framework deps/ module.
    const counter_mod = b.addModule("counter", .{
        .source_file = .{ .path = "src/@This/deps/counter/api.zig" },
        .dependencies = &.{},
    });

    // framers_mod. A framework deps/ module.
    const framers_mod = b.addModule("framers", .{
        .source_file = .{ .path = "src/@This/deps/framers/api.zig" },
        .dependencies = &.{},
    });

    // lock_mod. A framework deps/ module.
    const lock_mod = b.addModule("lock", .{
        .source_file = .{ .path = "src/@This/deps/lock/api.zig" },
        .dependencies = &.{},
    });

    // message_mod. A framework deps/ module.
    const message_mod = b.addModule("message", .{
        .source_file = .{ .path = "src/@This/deps/message/api.zig" },
        .dependencies = &.{},
    });

    // modal_params_mod. A framework deps/ module.
    const modal_params_mod = b.addModule("modal_params", .{
        .source_file = .{ .path = "src/@This/deps/modal_params/api.zig" },
        .dependencies = &.{},
    });

    // screen_pointers_mod. A framework frontend/ module.
    const screen_pointers_mod = b.addModule("screen_pointers", .{
        .source_file = .{ .path = "src/@This/frontend/screen_pointers.zig" },
        .dependencies = &.{},
    });

    // startup_mod. A framework deps/ module.
    const startup_mod = b.addModule("startup", .{
        .source_file = .{ .path = "src/@This/deps/startup/api.zig" },
        .dependencies = &.{},
    });

    // various_mod. A framework deps/ module.
    const various_mod = b.addModule("various", .{
        .source_file = .{ .path = "src/@This/deps/various/api.zig" },
        .dependencies = &.{},
    });

    // widget_mod. A framework deps/ module.
    const widget_mod = b.addModule("widget", .{
        .source_file = .{ .path = "src/@This/deps/widget/api.zig" },
        .dependencies = &.{},
    });

    // FRAMEWORK MODULE DEPENDENCIES.

    // Dependencies for channel_mod. A framework deps/ module.
    try channel_mod.dependencies.put("message", message_mod);
    try channel_mod.dependencies.put("various", various_mod);

    // Dependencies for closedownjobs_mod. A framework deps/ module.
    try closedownjobs_mod.dependencies.put("counter", counter_mod);

    // Dependencies for closer_mod. A framework deps/ module.
    try closer_mod.dependencies.put("closedownjobs", closedownjobs_mod);
    try closer_mod.dependencies.put("dvui", dvui_mod);
    try closer_mod.dependencies.put("framers", framers_mod);
    try closer_mod.dependencies.put("lock", lock_mod);
    try closer_mod.dependencies.put("modal_params", modal_params_mod);
    try closer_mod.dependencies.put("various", various_mod);

    // Dependencies for framers_mod. A framework deps/ module.
    try framers_mod.dependencies.put("startup", startup_mod);
    try framers_mod.dependencies.put("dvui", dvui_mod);
    try framers_mod.dependencies.put("modal_params", modal_params_mod);
    try framers_mod.dependencies.put("various", various_mod);
    try framers_mod.dependencies.put("lock", lock_mod);

    // Dependencies for message_mod. A framework deps/ module.
    try message_mod.dependencies.put("counter", counter_mod);
    try message_mod.dependencies.put("closedownjobs", closedownjobs_mod);
    try message_mod.dependencies.put("framers", framers_mod);
    try message_mod.dependencies.put("various", various_mod);

    // Dependencies for modal_params_mod. A framework deps/ module.
    try modal_params_mod.dependencies.put("closedownjobs", closedownjobs_mod);

    // Dependencies for screen_pointers_mod. A framework frontend/ module.
    try screen_pointers_mod.dependencies.put("channel", channel_mod);
    try screen_pointers_mod.dependencies.put("closedownjobs", closedownjobs_mod);
    try screen_pointers_mod.dependencies.put("closer", closer_mod);
    try screen_pointers_mod.dependencies.put("dvui", dvui_mod);
    try screen_pointers_mod.dependencies.put("framers", framers_mod);
    try screen_pointers_mod.dependencies.put("lock", lock_mod);
    try screen_pointers_mod.dependencies.put("message", message_mod);
    try screen_pointers_mod.dependencies.put("modal_params", modal_params_mod);
    try screen_pointers_mod.dependencies.put("screen_pointers", screen_pointers_mod);
    try screen_pointers_mod.dependencies.put("startup", startup_mod);
    try screen_pointers_mod.dependencies.put("various", various_mod);
    try screen_pointers_mod.dependencies.put("widget", widget_mod);

    // Dependencies for startup_mod. A framework deps/ module.
    try startup_mod.dependencies.put("channel", channel_mod);
    try startup_mod.dependencies.put("closedownjobs", closedownjobs_mod);
    try startup_mod.dependencies.put("dvui", dvui_mod);
    try startup_mod.dependencies.put("framers", framers_mod);
    try startup_mod.dependencies.put("modal_params", modal_params_mod);
    try startup_mod.dependencies.put("various", various_mod);
    try startup_mod.dependencies.put("screen_pointers", screen_pointers_mod);

    // Dependencies for widget_mod. A framework deps/ module.
    try widget_mod.dependencies.put("dvui", dvui_mod);
    try widget_mod.dependencies.put("lock", lock_mod);
    try widget_mod.dependencies.put("framers", framers_mod);
    try widget_mod.dependencies.put("startup", startup_mod);
    try widget_mod.dependencies.put("various", various_mod);

    const examples = [_][]const u8{
        "standalone-sdl",
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

        // deps modules.
        exe.addModule("various", various_mod);
        exe.addModule("screen_pointers", screen_pointers_mod);
        exe.addModule("counter", counter_mod);
        exe.addModule("closer", closer_mod);
        exe.addModule("closedownjobs", closedownjobs_mod);
        exe.addModule("channel", channel_mod);
        exe.addModule("lock", lock_mod);
        exe.addModule("framers", framers_mod);
        exe.addModule("message", message_mod);
        exe.addModule("modal_params", modal_params_mod);
        exe.addModule("startup", startup_mod);
        exe.addModule("widget", widget_mod);

        exe.linkLibrary(lib_bundle);
        add_include_paths(b, exe);

        const compile_step = b.step(ex, "Compile " ++ ex);
        compile_step.dependOn(&b.addInstallArtifact(exe, .{}).step);
        b.getInstallStep().dependOn(compile_step);

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(compile_step);

        const run_step = b.step("run-" ++ ex, "Run " ++ ex);
        run_step.dependOn(&run_cmd.step);
    }
}

pub fn link_deps(b: *std.Build, exe: *std.Build.Step.Compile) void {
    // TODO: remove this part about freetype (pulling it from the dvui_dep
    // sub-builder) once https://github.com/ziglang/zig/pull/14731 lands
    const freetype_dep = b.dependency("freetype", .{
        .target = exe.target,
        .optimize = exe.optimize,
    });
    exe.linkLibrary(freetype_dep.artifact("freetype"));

    if (exe.target.cpu_arch == .wasm32) {
        // nothing
    } else if (exe.target.isWindows()) {
        const sdl_dep = b.dependency("sdl", .{
            .target = exe.target,
            .optimize = exe.optimize,
        });
        exe.linkLibrary(sdl_dep.artifact("SDL2"));

        exe.linkSystemLibrary("setupapi");
        exe.linkSystemLibrary("winmm");
        exe.linkSystemLibrary("gdi32");
        exe.linkSystemLibrary("imm32");
        exe.linkSystemLibrary("version");
        exe.linkSystemLibrary("oleaut32");
        exe.linkSystemLibrary("ole32");
    } else {
        if (exe.target.isDarwin()) {
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
        }

        exe.linkSystemLibrary("SDL2");
        //exe.addIncludePath(.{.path = "/Users/dvanderson/SDL2-2.24.1/include"});
        //exe.addObjectFile(.{.path = "/Users/dvanderson/SDL2-2.24.1/build/.libs/libSDL2.a"});
    }
}

const build_runner = @import("root");
const deps = build_runner.dependencies;

pub fn get_dependency_build_root(dep_prefix: []const u8, name: []const u8) []const u8 {
    inline for (@typeInfo(deps.imports).Struct.decls) |decl| {
        if (std.mem.startsWith(u8, decl.name, dep_prefix) and
            std.mem.endsWith(u8, decl.name, name) and
            decl.name.len == dep_prefix.len + name.len)
        {
            return @field(deps.build_root, decl.name);
        }
    }

    std.debug.print("no dependency named '{s}'\n", .{name});
    std.process.exit(1);
}

/// prefix: library prefix. e.g. "dvui."
pub fn add_include_paths(b: *std.Build, exe: *std.Build.CompileStep) void {
    exe.addIncludePath(.{ .path = b.fmt("{s}{s}", .{ get_dependency_build_root(b.dep_prefix, "stb_image"), "/include" }) });
    exe.addIncludePath(.{ .path = b.fmt("{s}{s}", .{ get_dependency_build_root(b.dep_prefix, "freetype"), "/include" }) });
    exe.addIncludePath(.{ .path = b.fmt("{s}/src/stb", .{b.build_root.path.?}) });
}