const std = @import("std");

pub const Behavior = struct {
    allocator: std.mem.Allocator,
    nameFn: *const fn (self: *anyopaque) []const u8,
    frameFn: *const fn (self: *anyopaque, allocator: std.mem.Allocator) anyerror,
    self: *anyopaque,

    pub fn deinit(self: *Behavior) void {
        self.allocator.destroy(self);
    }
};

pub const Group = struct {
    allocator: std.mem.Allocator,
    current: ?*Behavior,
    members: std.StringHashMap(*Behavior),

    /// initBehavior constructs a Behavior.
    /// The Group has control over the Bahavior after subscribed.
    pub fn initBehavior(self: *Group) !*Behavior {
        var behavior: *Behavior = try self.allocator.create(Behavior);
        behavior.allocator = self.allocator;
        return behavior;
    }

    pub fn deinit(self: *Group) void {
        // each framer.
        var iter = self.members.iterator();
        while (iter.next()) |member| {
            member.value_ptr.*.deinit();
        }
        self.members.deinit();
    }

    pub fn frame(self: *Group, arena: std.mem.Allocator) !void {
        if (self.current) |behavior| {
            var err = behavior.frameFn(behavior.self, arena);
            if (err != error.Null) {
                return err;
            }
        }
    }

    /// subscribe assumes complete control over behavior
    pub fn subscribe(self: *Group, behavior: *Behavior) !void {
        var name = behavior.nameFn(behavior.self);
        try self.members.put(name, behavior);
    }

    pub fn unsubscribe(self: *Group, name: []const u8) bool {
        if (self.members.getEntry(name)) |entry| {
            var behavior: *Behavior = @ptrCast(entry.value_ptr.*);
            self.allocator.destroy(behavior);
            return self.members.remove(name);
        }
    }

    /// get returns a Behavior.
    pub fn get(self: *Group, name: []const u8) ?*Behavior {
        var value_ptr = self.members.get(name);
        if (value_ptr != null) {
            return value_ptr;
        }
        return null;
    }

    /// setCurrent signals that a framer is the currently displayed framer.
    /// This is the current framer displayed by the window.
    pub fn setCurrent(self: *Group, name: []const u8) void {
        var behavior: ?*Behavior = self.members.get(name);
        if (behavior != null) {
            self.current = behavior;
        }
    }

    /// getCurrent returns the current framer.
    pub fn getCurrent(self: *Group) ?*Behavior {
        return self.current;
    }
};

pub fn init(allocator: std.mem.Allocator) !*Group {
    var members: *Group = try allocator.create(Group);
    members.allocator = allocator;
    members.current = null;
    members.members = std.StringHashMap(*Behavior).init(allocator);
    return members;
}
