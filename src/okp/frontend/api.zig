const std = @import("std");
const dvui = @import("dvui");
const _main_menu_ = @import("main_menu.zig");
const _channel_ = @import("channel");
const _framers_ = @import("framers");

const simple_screen = @import("screen/panel/simple/screen.zig");
const hard_screen = @import("screen/panel/hard/screen.zig");
const htabs_screen = @import("screen/tab/htabs/screen.zig");
const vtabs_screen = @import("screen/tab/vtabs/screen.zig");

var all_screens: ?*_framers_.Group = null;

pub fn init(allocator: std.mem.Allocator, send_channel: *_channel_.Channels, receive_channel: *_channel_.Channels) !void {
    // Screens.
    all_screens = try _framers_.init(allocator);

    // Set up each screen.
    try simple_screen.init(allocator, all_screens.?, send_channel, receive_channel);
    try hard_screen.init(allocator, all_screens.?, send_channel, receive_channel);
    try htabs_screen.init(allocator, all_screens.?, send_channel, receive_channel);
    try vtabs_screen.init(allocator, all_screens.?, send_channel, receive_channel);

    // Set the default screen.
    all_screens.?.setCurrent("simple");
}

pub fn deinit() void {
    all_screens.?.deinit();
}

pub fn frame(arena: std.mem.Allocator) !void {
    // If set the zoom here then
    // 1. there is no app menu. ( a horzontal menu )
    // 👍 the zoom works,

    // The main menu.
    try _main_menu_.frame(all_screens.?);

    // If set the zoom here then
    // 👍 the app menu works and as expected has no zoom,
    // 👍 the vertical tabs work correctly,
    // 👍 the zoom works,
    // 1. my horizontal tabs are not visible, ( a copy of the horizontal menu code )
    // 👍 but the default tab's content is visible as expected.

    // set the zoom.
    const theme: *dvui.Theme = dvui.themeGet();
    const font_body_size: f32 = theme.font_body.size;
    const scale_val: f32 = @round(font_body_size * 2.0) / font_body_size;
    var scaler = try dvui.scale(@src(), scale_val, .{ .expand = .both });
    defer scaler.deinit();

    // Only frame visible screens and panels.
    try all_screens.?.frame(arena);

    // If set the zoom here then obviously no zoom.
}
