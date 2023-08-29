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
    var edit: *Message = try allocator.create(Message);
    edit._allocator = allocator;
    edit._reinits = 0;
    return edit;
}
