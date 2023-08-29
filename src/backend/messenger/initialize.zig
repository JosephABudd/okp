const std = @import("std");
const _channel_ = @import("channel");
const _message_ = @import("message");

pub const Messenger = struct {
    allocator: std.mem.Allocator,
    send_channels: *_channel_.Channels,

    pub fn deinit(self: *Messenger) void {
        self.allocator.destroy(self);
    }

    /// receiveFn receives an initialize_message from the front-end.
    /// initialize_message is only valid during this function.
    pub fn receiveFn(self_ptr: *anyopaque, initialize_message: *_message_.initialize.Message) void {
        var self: *Messenger = @alignCast(@ptrCast(self_ptr));
        _ = initialize_message;
        // initialize_message is only valid during this function.

        std.debug.print("backend got the initialize message.\n", .{});

        // Send the add message to the frontend.
        var allocator: std.mem.Allocator = self.allocator;
        var add_message: *_message_.add.Message = _message_.add.init(allocator) catch |err| {
            self.send_channels.fatal.sendError(err);
            return;
        };
        defer add_message.deinit();
        self.send_channels.add.send(add_message) catch |err| {
            self.send_channels.fatal.sendError(err);
            return;
        };

        // Send the edit message to the frontend.
        var edit_message: *_message_.edit.Message = _message_.edit.init(self.allocator) catch |err| {
            self.send_channels.fatal.sendError(err);
            return;
        };
        defer edit_message.deinit();
        self.send_channels.edit.send(edit_message) catch |err| {
            self.send_channels.fatal.sendError(err);
            return;
        };
    }
};

pub fn init(allocator: std.mem.Allocator, send_channels: *_channel_.Channels, receive_channels: *_channel_.Channels) !*Messenger {
    var messenger: *Messenger = try allocator.create(Messenger);
    messenger.allocator = allocator;
    messenger.send_channels = send_channels;
    var behavior = try receive_channels.initialize.initBehavior();
    errdefer {
        messenger.deinit();
    }
    behavior.self = messenger;
    behavior.receiveFn = &Messenger.receiveFn;
    try receive_channels.initialize.subscribe(behavior);
    errdefer {
        messenger.deinit();
    }
    return messenger;
}
