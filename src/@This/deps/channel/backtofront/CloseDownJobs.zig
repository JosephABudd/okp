/// Through this channel:
/// Messages flow from the back-end to the front-end:
/// 1. Any back-end messenger can send a "CloseDownJobs" message to the subscribed front-end messengers.
/// 2. Every subscribed front-end messenger receives a copy of each "CloseDownJobs" message sent from the back-end.
/// This file was generated by kickzig when you added the "CloseDownJobs" message.
/// It will be removed when you remove the "CloseDownJobs" message.
const std = @import("std");

pub const _message_ = @import("message").CloseDownJobs;
const ExitFn = @import("various").ExitFn;

/// Behavior is call-backs and state.
/// .implementor implements the recieveFn.
/// .receiveFn receives a CloseDownJobs message from the front-end.
pub const Behavior = struct {
    implementor: *anyopaque,
    receiveFn: *const fn (implementor: *anyopaque, message: *_message_.Message) anyerror!void,
};

pub const Group = struct {
    allocator: std.mem.Allocator = undefined,
    members: std.AutoHashMap(*anyopaque, *Behavior),
    exit: ExitFn,

    /// initBehavior constructs an empty Behavior.
    pub fn initBehavior(self: *Group) !*Behavior {
        return self.allocator.create(Behavior);
    }

    pub fn deinit(self: *Group) void {
        // deint each Behavior.
        var iterator = self.members.iterator();
        while (iterator.next()) |entry| {
            var behavior: *Behavior = @ptrCast(entry.value_ptr.*);
            self.allocator.destroy(behavior);
        }
        self.members.deinit();
        self.allocator.destroy(self);
    }

    /// subscribe adds a Behavior that will receiver the message to the Group.
    /// Group owns the Behavior not the caller.
    /// So if there is an error the Behavior is destroyed.
    pub fn subscribe(self: *Group, behavior: *Behavior) !void {
        self.members.put(behavior.implementor, behavior) catch |err| {
            self.allocator.destroy(behavior);
            return err;
        };
    }

    /// unsubscribe removes a Behavior from the Group.
    /// It also destroys the Behavior.
    /// Returns true if anything was removed.
    pub fn unsubscribe(self: *Group, caller: *anyopaque) bool {
        if (self.members.getEntry(caller)) |entry| {
            var behavior: *Behavior = @ptrCast(entry.value_ptr.*);
            self.allocator.destroy(behavior);
            return self.members.remove(caller);
        }
    }

    /// send dispatches the message to the Behaviors in Group.
    /// It dispatches in another thread.
    /// It returns after spawning the thread while the thread runs.
    /// It takes control of the message and deinits it.
    /// Receive functions own the message they receive and must deinit it.
    pub fn send(self: *Group, message: *_message_.Message) !void {
        var copy: *_message_.Message = try message.copy();
        var thread = try std.Thread.spawn(.{ .allocator = self.allocator }, Group.dispatchDeinit, .{ self, copy });
        std.Thread.detach(thread);
    }

    fn dispatchDeinit(self: *Group, message: *_message_.Message) void {
        defer message.deinit();

        var iterator = self.members.iterator();
        while (iterator.next()) |entry| {
            var behavior: *Behavior = entry.value_ptr.*;
            // Send the receiver a copy of the message.
            // The receiver owns the copy and must deinit it.
            var receiver_copy: *_message_.Message = message.copy() catch |err| {
                self.exit(@src(), err, "message.copy()");
                return;
            };
            // The receiveFn must handle it's own error.
            // If the receiveFn returns an error then stop.
            behavior.receiveFn(behavior.implementor, receiver_copy) catch {
                // Error: Stop dispatching.
                return;
            };
        }
    }
};

pub fn init(allocator: std.mem.Allocator, exit: ExitFn) !*Group {
    var channel: *Group = try allocator.create(Group);
    channel.members = std.AutoHashMap(*anyopaque, *Behavior).init(allocator);
    channel.allocator = allocator;
    channel.exit = exit;
    return channel;
}
