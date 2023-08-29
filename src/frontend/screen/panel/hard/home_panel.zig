const std = @import("std");
const dvui = @import("dvui");
const _framers_ = @import("framers");
const _panels_ = @import("panels.zig");
const _messenger_ = @import("messenger.zig");

pub const Panel = struct {
    allocator: std.mem.Allocator,
    all_screens: *_framers_.Group,
    all_panels: *_panels_.Panels,
    messenger: *_messenger_.Messenger,

    pub fn deinit(self: *Panel) void {
        self.allocator.destroy(self);
    }

    // frame is a simple screen rendering one panel at a time.
    pub fn frame(self: *Panel, arena: std.mem.Allocator) !void {
        _ = arena;
        var tl = try dvui.textLayout(@src(), .{}, .{ .expand = .both, .font_style = .title_4 });
        const lorem = "Hard Screen: Home Panel.";
        try tl.addText(lorem, .{});
        tl.deinit();

        var tl2 = try dvui.textLayout(@src(), .{}, .{ .expand = .both });
        try tl2.addText(
            \\The dvui
            \\- paints the entire window
            \\- can show floating windows and dialogs
            \\- example menu at the top of the window
            \\- rest of the window is a scroll area
        , .{});
        try tl2.addText("\n\n", .{});
        try tl2.addText("Framerate is variable and adjusts as needed for input events and animations.", .{});
        try tl2.addText("\n\n", .{});
        try tl2.addText("\n\n", .{});
        try tl2.addText("Cursor is always being set by dvui.", .{});
        tl2.deinit();

        if (dvui.examples.show_demo_window) {
            if (try dvui.button(@src(), "Hide Demo Window", .{})) {
                dvui.examples.show_demo_window = false;
            }
        } else {
            if (try dvui.button(@src(), "Show Demo Window", .{})) {
                dvui.examples.show_demo_window = true;
            }
        }

        if (try dvui.button(@src(), "Show Other Panel", .{})) {
            self.all_panels.setCurrentToOther();
        }

        if (try dvui.button(@src(), "Show Simple Screen", .{})) {
            self.all_screens.setCurrent("simple");
        }

        // look at demo() for examples of dvui widgets, shows in a floating window
        try dvui.examples.demo();
    }
};

pub fn init(allocator: std.mem.Allocator, all_screens: *_framers_.Group, all_panels: *_panels_.Panels, messenger: *_messenger_.Messenger) !*Panel {
    var panel: *Panel = try allocator.create(Panel);
    panel.allocator = allocator;
    panel.all_screens = all_screens;
    panel.all_panels = all_panels;
    panel.messenger = messenger;
    return panel;
}
