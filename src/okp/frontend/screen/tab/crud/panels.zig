const std = @import("std");
const _framers_ = @import("framers");
const _messenger_ = @import("messenger.zig");
const add_panel = @import("add_panel.zig");

const PanelTags = enum {
    add,
    none,
};

pub const Panels = struct {
    allocator: std.mem.Allocator,
    add: ?*add_panel.Panel,
    _current: PanelTags,

    pub fn deinit(self: *Panels) void {
        if (self.add) |add| {
            add.deinit();
        }
        self.allocator.destroy(self);
    }
};

pub fn init(allocator: std.mem.Allocator, all_screens: *_framers_.Group, messenger: *_messenger_.Messenger) !*Panels {
    var panels: *Panels = try allocator.create(Panels);
    panels.allocator = allocator;

    panels.add = try add_panel.init(allocator, all_screens, panels, messenger);
    errdefer {
        panels.deinit();
    }

    return panels;
}
