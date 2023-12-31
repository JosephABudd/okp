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

const simple_screen_tab_label: []const u8 = "The Entire Simple Screen";
const hard_screen_tab_label: []const u8 = "The Entire Hard Screen";
const home_panel_tab_label: []const u8 = "Only the Tabs Home Panel";
const other_panel_tab_label: []const u8 = "Only the Other Panel";

const Screen = struct {
    allocator: std.mem.Allocator,
    all_screens: *_framers_.Group,
    all_panels: *_panels_.Panels,
    send_channels: *_channel_.Channels,
    receive_channels: *_channel_.Channels,

    selected_tab_label: []const u8 = undefined,
    selected_tab: tabs = undefined,

    scroll_max: f32 = -1.0,
    scroll_max_count: u8 = 0,

    pub fn deinit(self: *Screen) void {
        self.all_panels.deinit();
        self.allocator.destroy(self);
    }

    fn nameFn(self_ptr: *anyopaque) []const u8 {
        var self: *Screen = @alignCast(@ptrCast(self_ptr));
        _ = self;
        return "htabs";
    }

    fn deinitFn(self_ptr: *anyopaque) void {
        var self: *Screen = @alignCast(@ptrCast(self_ptr));
        self.all_panels.deinit();
        self.allocator.destroy(self);
    }

    fn check_scroll_max(self: *Screen) bool {
        if (self.scroll_max_count < 3) {
            self.scroll_max = self.scroll.si.scroll_max(.horizontal);
            self.scroll_max_count += 1;
            return false;
        }
        var scroll_max: f32 = self.scroll.si.scroll_max(.horizontal);
        if (scroll_max != self.scroll_max) {
            // window size changed.
            self.scroll_max = scroll_max;
            self.scroll_max_count = 1;
            return false;
        }
        return true;
    }

    fn frameFn(self_ptr: *anyopaque, arena: std.mem.Allocator) anyerror {
        var self: *Screen = @alignCast(@ptrCast(self_ptr));

        // The tabbar.
        var scroll = try dvui.scrollArea(
            @src(),
            .{
                .vertical = .none,
                .horizontal = .auto,
                .horizontal_bar = .hide,
            },
            .{ .expand = .horizontal, .color_style = .window },
        );
        var tabbar = try dvui.horizontalTabBar(@src());
        var selected: bool = false;

        // The simple screen tab.
        selected = std.mem.eql(u8, self.selected_tab_label, simple_screen_tab_label);
        var simple_screen_tab: ?dvui.Rect = try dvui.horizontalTabBarItemLabel(@src(), simple_screen_tab_label, selected);
        if (simple_screen_tab != null) {
            if (self.selected_tab != tabs.simple) {
                self.selected_tab = tabs.simple;
                self.selected_tab_label = simple_screen_tab_label;
            }
        }
        // The hard screen tab.
        selected = std.mem.eql(u8, self.selected_tab_label, hard_screen_tab_label);
        var hard_screen_tab: ?dvui.Rect = try dvui.horizontalTabBarItemLabel(@src(), hard_screen_tab_label, selected);
        if (hard_screen_tab != null) {
            if (self.selected_tab != tabs.hard) {
                self.selected_tab = tabs.hard;
                self.selected_tab_label = hard_screen_tab_label;
            }
        }
        // The home panel tab.
        selected = std.mem.eql(u8, self.selected_tab_label, home_panel_tab_label);
        var home_panel_tab: ?dvui.Rect = try dvui.horizontalTabBarItemLabel(@src(), home_panel_tab_label, selected);
        if (home_panel_tab != null) {
            if (self.selected_tab != tabs.home_panel) {
                self.selected_tab = tabs.home_panel;
                self.selected_tab_label = home_panel_tab_label;
            }
        }
        // The other panel tab.
        selected = std.mem.eql(u8, self.selected_tab_label, other_panel_tab_label);
        var other_panel_tab: ?dvui.Rect = try dvui.horizontalTabBarItemLabel(@src(), other_panel_tab_label, selected);
        if (other_panel_tab != null) {
            if (self.selected_tab != tabs.other_panel) {
                self.selected_tab = tabs.other_panel;
                self.selected_tab_label = other_panel_tab_label;
            }
        }
        tabbar.deinit();
        scroll.deinit();

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
    screen.selected_tab_label = simple_screen_tab_label;

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
