const std = @import("std");
const _channel_ = @import("channel");
const _initialize_ = @import("initialize.zig");
const _add_ = @import("add.zig");
const _edit_ = @import("edit.zig");

// Messenger is the back-end message dispatcher.
// It dispatches messages from the front-end to the correct back-end message handler.
pub const Messenger = struct {
    allocator: std.mem.Allocator,
    initialize: *_initialize_.Messenger,

    add: *_add_.Messenger,
    edit: *_edit_.Messenger,

    pub fn deinit(self: *Messenger) void {
        self.initialize.deinit();
        self.add.deinit();
        self.edit.deinit();
    }
};

pub fn init(allocator: std.mem.Allocator, send_channels: *_channel_.Channels, receive_channels: *_channel_.Channels) !*Messenger {
    var messenger: *Messenger = try allocator.create(Messenger);
    messenger.initialize = try _initialize_.init(allocator, send_channels, receive_channels);
    errdefer {
        messenger.allocator.destroy(messenger);
    }
    messenger.add = try _add_.init(allocator, send_channels, receive_channels);
    errdefer {
        messenger.initialize.deinit();
        messenger.allocator.destroy(messenger);
    }
    messenger.edit = try _edit_.init(allocator, send_channels, receive_channels);
    errdefer {
        messenger.add.deinit();
        messenger.initialize.deinit();
        messenger.allocator.destroy(messenger);
    }
    return messenger;
}
