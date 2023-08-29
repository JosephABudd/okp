const std = @import("std");

pub const _message_ = @import("message").initialize;

pub const Behavior = struct {
    receiveFn: *const fn (self: *anyopaque, message: *_message_.Message) void,
    self: *anyopaque,
};

pub const Group = struct {
    allocator: std.mem.Allocator = undefined,
    members: std.AutoHashMap(*anyopaque, *Behavior),
    _sent: bool,
    _message: *_message_.Message,

    pub fn initBehavior(self: *Group) !*Behavior {
        return self.allocator.create(Behavior);
    }

    pub fn deinit(self: *Group) void {
        self._message.deinit();
        self.members.deinit();
        self.allocator.destroy(self);
    }

    pub fn subscribe(self: *Group, cb: *Behavior) !void {
        try self.members.put(cb.self, cb);
    }

    pub fn unsubscribe(self: *Group, caller: *anyopaque) bool {
        if (self.members.getEntry(caller)) |entry| {
            var cb: *Behavior = @ptrCast(entry.value_ptr.*);
            self.allocator.destroy(cb);
            return self.members.remove(caller);
        }
    }

    // send sends the Inialize message once.
    pub fn send(self: *Group) void {
        if (self._sent) {
            return;
        }
        self._sent = true;
        var iterator = self.members.iterator();
        while (iterator.next()) |entry| {
            var behavior: *Behavior = entry.value_ptr.*;
            behavior.receiveFn(behavior.self, self._message);
        }
    }
};

pub fn init(allocator: std.mem.Allocator) !*Group {
    var channel: *Group = try allocator.create(Group);
    channel.allocator = allocator;
    channel.members = std.AutoHashMap(*anyopaque, *Behavior).init(allocator);
    errdefer {
        allocator.destroy(channel);
    }
    channel._message = try _message_.init(allocator);
    errdefer {
        channel.members.deinit();
        allocator.destroy(channel);
    }
    channel._sent = false;
    return channel;
}
