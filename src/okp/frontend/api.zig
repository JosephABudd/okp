const std = @import("std");
const _main_menu_ = @import("main_menu.zig");
const _channel_ = @import("channel");
const _framers_ = @import("framers");

const simple_screen = @import("screen/panel/simple/screen.zig");
const hard_screen = @import("screen/panel/hard/screen.zig");
const tabs_screen = @import("screen/tab/tabs/screen.zig");

var all_screens: ?*_framers_.Group = null;

pub fn init(allocator: std.mem.Allocator, send_channel: *_channel_.Channels, receive_channel: *_channel_.Channels) !void {
    // Screens.
    all_screens = try _framers_.init(allocator);

    // Set up each screen.
    try simple_screen.init(allocator, all_screens.?, send_channel, receive_channel);
    try hard_screen.init(allocator, all_screens.?, send_channel, receive_channel);
    try tabs_screen.init(allocator, all_screens.?, send_channel, receive_channel);

    // Set the default screen.
    all_screens.?.setCurrent("simple");
}

pub fn deinit() void {
    all_screens.?.deinit();
}

pub fn frame(arena: std.mem.Allocator) !void {
    // The main menu.
    try _main_menu_.frame(all_screens.?);
    // Only frame visible screens and panels.
    try all_screens.?.frame(arena);
}
