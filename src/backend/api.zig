const std = @import("std");
const _channel_ = @import("channel");
const _messenger_ = @import("messenger/api.zig");

var _messenger: ?*_messenger_.Messenger = null;

pub fn init(allocator: std.mem.Allocator, send_channels: *_channel_.Channels, receive_channels: *_channel_.Channels) !void {
    _messenger = try _messenger_.init(allocator, send_channels, receive_channels);
}

pub fn deinit() void {
    if (_messenger) |messenger| {
        messenger.deinit();
    }
}
