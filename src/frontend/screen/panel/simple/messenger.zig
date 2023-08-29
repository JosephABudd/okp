const std = @import("std");
const _message_ = @import("message");
const _channel_ = @import("channel");
const _framers_ = @import("framers");
const _panels_ = @import("panels.zig");

pub const Messenger = struct {
    allocator: std.mem.Allocator,
    arena: std.mem.Allocator,

    all_screens: *_framers_.Group,
    all_panels: *_panels_.Panels,
    send_channels: *_channel_.Channels,
    receive_channels: *_channel_.Channels,

    pub fn deinit(self: *Messenger) void {
        self.allocator.destroy(self);
    }

    pub fn receiveInitialize(self_ptr: *anyopaque, message: *_message_.initialize.Message) void {
        var self: *Messenger = @alignCast(@ptrCast(self_ptr));
        _ = self;
        _ = message;
        std.debug.print("{s} got the {s} message.\n", .{ "simple", "initialize" });
    }

    fn receiveAdd(self_ptr: *anyopaque, message: *_message_.add.Message) void {
        var self: *Messenger = @alignCast(@ptrCast(self_ptr));
        _ = self;
        _ = message;
        std.debug.print("{s} got the {s} message.\n", .{ "simple", "add" });
    }

    fn receiveEdit(self_ptr: *anyopaque, message: *_message_.edit.Message) void {
        var self: *Messenger = @alignCast(@ptrCast(self_ptr));
        _ = self;
        _ = message;
        std.debug.print("{s} got the {s} message.\n", .{ "simple", "edit" });
    }
};

pub fn init(allocator: std.mem.Allocator, all_screens: *_framers_.Group, all_panels: *_panels_.Panels, send_channels: *_channel_.Channels, receive_channels: *_channel_.Channels) !*Messenger {
    var messenger: *Messenger = try allocator.create(Messenger);
    messenger.allocator = allocator;
    messenger.all_screens = all_screens;
    messenger.all_panels = all_panels;
    messenger.send_channels = send_channels;
    messenger.receive_channels = receive_channels;

    // Each message has it's own channel.

    // Initialize message.
    var initializeBehavior = try receive_channels.initialize.initBehavior();
    errdefer {
        allocator.destroy(messenger);
    }
    initializeBehavior.receiveFn = Messenger.receiveInitialize;
    initializeBehavior.self = messenger;
    try receive_channels.initialize.subscribe(initializeBehavior);
    errdefer {
        allocator.destroy(initializeBehavior);
        allocator.destroy(messenger);
    }

    // Add message.
    var addBehavior = try receive_channels.add.initBehavior();
    errdefer {
        allocator.destroy(initializeBehavior);
        allocator.destroy(messenger);
    }
    addBehavior.receiveFn = Messenger.receiveAdd;
    addBehavior.self = messenger;
    try receive_channels.add.subscribe(addBehavior);
    errdefer {
        allocator.destroy(addBehavior);
        allocator.destroy(initializeBehavior);
        allocator.destroy(messenger);
    }

    // Edit message.
    var editBehavior = try receive_channels.edit.initBehavior();
    errdefer {
        allocator.destroy(addBehavior);
        allocator.destroy(initializeBehavior);
        allocator.destroy(messenger);
    }
    editBehavior.receiveFn = Messenger.receiveEdit;
    editBehavior.self = messenger;
    try receive_channels.edit.subscribe(editBehavior);
    errdefer {
        allocator.destroy(editBehavior);
        allocator.destroy(addBehavior);
        allocator.destroy(initializeBehavior);
        allocator.destroy(messenger);
    }
    return messenger;
}
