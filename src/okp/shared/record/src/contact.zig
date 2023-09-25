const std = @import("std");

const Contact = struct {
    allocator: std.mem.Allocator,
    id: usize,
    name: []const u8,

    fn init(allocator: std.mem.Allocator, id: usize, name: []const u8) !*Contact {
        var contact: *Contact = try allocator.create(Contact);
        contact.id = id;
        contact.name = allocator.alloc(u8, name.len);
        @memcpy(contact.name, name);
        return contact;
    }

    fn deinit(self: *Contact) void {
        self.allocator.free(self.name);
        self.allocator.destroy(self);
    }
};
