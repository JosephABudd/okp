const std = @import("std");

pub const Message = struct {
    _allocator: std.mem.Allocator = undefined,
    _reinits: i32 = 0,
    errorName: ?[:0]const u8 = undefined,

    pub fn deinit(self: *Message) void {
        self._reinits -= 1;
        if (self._reinits == 0) {
            self._allocator.destroy(self);
        }
        // This message does not have controls of errName becuase it's from the stack.
    }

    pub fn reinit(self: *Message) void {
        self._reinits += 1;
    }

    pub fn setError(self: *Message, err: anyerror) void {
        self.errorName = @errorName(err);
    }
};

pub fn init(allocator: std.mem.Allocator, err: ?anyerror) !*Message {
    var fatal: *Message = try allocator.create(Message);
    fatal._allocator = allocator;
    fatal._reinits = 0;
    if (err != null) {
        fatal.errorName = @errorName(err.?);
    }
    return fatal;
}
