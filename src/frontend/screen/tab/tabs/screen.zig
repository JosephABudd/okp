const std = @import("std");
const dvui = @import("dvui");
const _channel_ = @import("channel");
const _framers_ = @import("framers");
const _panels_ = @import("panels.zig");
const _messenger_ = @import("messenger.zig");

const tabs = enum {
    simple,
    hard,
    home_panel,
    other_panel,
    none,
};

const Screen = struct {
    allocator: std.mem.Allocator,
    all_screens: *_framers_.Group,
    all_panels: *_panels_.Panels,
    send_channels: *_channel_.Channels,
    receive_channels: *_channel_.Channels,

    selected_tab: tabs,

    pub fn deinit(self: *Screen) void {
        self.all_panels.deinit();
        self.allocator.destroy(self);
    }

    fn nameFn(self_ptr: *anyopaque) []const u8 {
        var self: *Screen = @alignCast(@ptrCast(self_ptr));
        _ = self;
        return "tabs";
    }

    fn deinitFn(self_ptr: *anyopaque) void {
        var self: *Screen = @alignCast(@ptrCast(self_ptr));
        self.all_panels.deinit();
        self.allocator.destroy(self);
    }

    fn frameFn(self_ptr: *anyopaque, arena: std.mem.Allocator) anyerror {
        var self: *Screen = @alignCast(@ptrCast(self_ptr));
        var accent_style = dvui.themeGet().style_content.accent orelse unreachable;
        _ = accent_style;

        // The tabbar.
        var tabbar = try dvui.menu(@src(), .horizontal, .{ .background = true, .expand = .horizontal });

        // The simple screen tab.
        var simple_screen_tab: ?dvui.Rect = try dvui.menuItemLabel(@src(), "Simple Screen", .{}, .{});
        if (simple_screen_tab != null) {
            self.selected_tab = tabs.simple;
        }

        // The hard screen tab.
        var hard_screen_tab: ?dvui.Rect = try dvui.menuItemLabel(@src(), "Hard Screen", .{}, .{});
        if (hard_screen_tab != null) {
            self.selected_tab = tabs.hard;
        }

        // The home panel tab.
        var home_panel_tab: ?dvui.Rect = try dvui.menuItemLabel(@src(), "Tabs Home Panel", .{}, .{});
        if (home_panel_tab != null) {
            self.selected_tab = tabs.home_panel;
        }

        // The other panel tab.
        var other_panel_tab: ?dvui.Rect = try dvui.menuItemLabel(@src(), "Tabs Other Panel", .{}, .{});
        if (other_panel_tab != null) {
            self.selected_tab = tabs.other_panel;
        }
        tabbar.deinit();

        // The content area for a tab's content.

        switch (self.selected_tab) {
            .simple => {
                var behavior: ?*_framers_.Behavior = self.all_screens.get("simple");
                if (behavior != null) {
                    var err = behavior.?.frameFn(behavior.?.self, arena);
                    if (err != error.Null) {
                        return err;
                    }
                }
            },
            .hard => {
                var behavior: ?*_framers_.Behavior = self.all_screens.get("hard");
                if (behavior != null) {
                    var err = behavior.?.frameFn(behavior.?.self, arena);
                    if (err != error.Null) {
                        return err;
                    }
                }
            },
            .home_panel => {
                try self.all_panels.home.?.frame(arena);
            },
            .other_panel => {
                try self.all_panels.other.?.frame(arena);
            },
            .none => {},
        }
        return error.Null;
    }
};

/// init constructs this screen, subscribes it to all_screens and returns the error.
pub fn init(allocator: std.mem.Allocator, all_screens: *_framers_.Group, send_channels: *_channel_.Channels, receive_channels: *_channel_.Channels) !void {
    var screen: *Screen = try allocator.create(Screen);
    screen.allocator = allocator;
    screen.all_screens = all_screens;
    screen.receive_channels = receive_channels;
    screen.send_channels = send_channels;

    // The simple tab is selected by default.
    screen.selected_tab = tabs.simple;

    // The messenger.
    var messenger: *_messenger_.Messenger = try _messenger_.init(allocator, all_screens, screen.all_panels, send_channels, receive_channels);
    errdefer {
        screen.deinit();
    }

    // All of the panels.
    screen.all_panels = try _panels_.init(allocator, all_screens, messenger);
    errdefer {
        messenger.deinit();
        screen.deinit();
    }

    // Subscribe to all screens.
    var behavior: *_framers_.Behavior = try all_screens.initBehavior();
    errdefer {
        screen.all_panels.deinit();
        messenger.deinit();
        screen.deinit();
    }
    behavior.nameFn = &Screen.nameFn;
    behavior.frameFn = &Screen.frameFn;
    behavior.self = screen;
    try all_screens.subscribe(behavior);
    errdefer {
        behavior.deinit();
        screen.all_panels.deinit();
        messenger.deinit();
        screen.deinit();
    }
    // screen is now controlled by all_screens.
}
