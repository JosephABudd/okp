const std = @import("std");
const _channel_ = @import("channel");
const _message_ = @import("message");

pub const Messenger = struct {
    allocator: std.mem.Allocator,
    send_channels: *_channel_.Channels,

    pub fn deinit(self: *Messenger) void {
        self.allocator.destroy(self);
    }

    /// receiveFn receives an add_message from the front-end.
    /// add_message is only valid during this function.
    pub fn receiveFn(self_ptr: *anyopaque, add_message: *_message_.add.Message) void {
        var self: *Messenger = @alignCast(@ptrCast(self_ptr));
        _ = self;
        _ = add_message;

        std.debug.print("backend got the add message.\n", .{});
    }
};

pub fn init(allocator: std.mem.Allocator, send_channels: *_channel_.Channels, receive_channels: *_channel_.Channels) !*Messenger {
    var messenger: *Messenger = try allocator.create(Messenger);
    messenger.allocator = allocator;
    messenger.send_channels = send_channels;
    var behavior = try receive_channels.add.initBehavior();
    errdefer {
        messenger.deinit();
    }
    behavior.self = messenger;
    behavior.receiveFn = &Messenger.receiveFn;
    try receive_channels.add.subscribe(behavior);
    errdefer {
        messenger.deinit();
    }
    return messenger;
}
