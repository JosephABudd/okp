const std = @import("std");
const dvui = @import("dvui");
const _channel_ = @import("channel");
const _framers_ = @import("framers");
const _panels_ = @import("panels.zig");
const _messenger_ = @import("messenger.zig");

const Screen = struct {
    allocator: std.mem.Allocator,
    all_screens: *_framers_.Group,
    all_panels: *_panels_.Panels,
    send_channels: *_channel_.Channels,
    receive_channels: *_channel_.Channels,

    pub fn deinit(self: *Screen) void {
        self.all_panels.deinit();
        self.allocator.destroy(self);
    }

    fn nameFn(self_ptr: *anyopaque) []const u8 {
        var self: *Screen = @alignCast(@ptrCast(self_ptr));
        _ = self;
        return "simple";
    }

    fn deinitFn(self_ptr: *anyopaque) void {
        var self: *Screen = @alignCast(@ptrCast(self_ptr));
        self.all_panels.deinit();
        self.allocator.destroy(self);
    }

    fn frameFn(self_ptr: *anyopaque, arena: std.mem.Allocator) anyerror {
        var self: *Screen = @alignCast(@ptrCast(self_ptr));
        var scroll = try dvui.scrollArea(
            @src(),
            .{ .horizontal_bar = .hide },
            .{ .expand = .both, .color_style = .window },
        );
        defer scroll.deinit();

        try self.all_panels.frameCurrent(arena);
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
    // The home panel is the default.
    screen.all_panels.setCurrentToHome();

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
