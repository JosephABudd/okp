const std = @import("std");

pub const Message = struct {
    _allocator: std.mem.Allocator = undefined,
    _reinits: i32 = 0,

    pub fn deinit(self: *Message) void {
        self._reinits -= 1;
        if (self._reinits == 0) {
            self._allocator.destroy(self);
        }
    }

    pub fn reinit(self: *Message) void {
        self._reinits += 1;
    }
};

pub fn init(allocator: std.mem.Allocator) !*Message {
    var add: *Message = try allocator.create(Message);
    add._allocator = allocator;
    add._reinits = 0;
    return add;
}
