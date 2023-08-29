const std = @import("std");
const _framers_ = @import("framers");
const _messenger_ = @import("messenger.zig");
const home_panel = @import("home_panel.zig");
const other_panel = @import("other_panel.zig");

const PanelTags = enum {
    home,
    other,
    none,
};

pub const Panels = struct {
    allocator: std.mem.Allocator,
    home: ?*home_panel.Panel,
    other: ?*other_panel.Panel,
    _current: PanelTags,

    pub fn deinit(self: *Panels) void {
        if (self.home) |home| {
            home.deinit();
        }
        if (self.other) |other| {
            other.deinit();
        }
        self.allocator.destroy(self);
    }

    pub fn frameCurrent(self: *Panels, allocator: std.mem.Allocator) !void {
        var result = switch (self._current) {
            .home => self.home.?.frame(allocator),
            .other => self.other.?.frame(allocator),
            .none => self.home.?.frame(allocator),
        };
        return result;
    }

    pub fn setCurrentToHome(self: *Panels) void {
        self._current = PanelTags.home;
    }

    pub fn setCurrentToOther(self: *Panels) void {
        self._current = PanelTags.other;
    }
};

pub fn init(allocator: std.mem.Allocator, all_screens: *_framers_.Group, messenger: *_messenger_.Messenger) !*Panels {
    var panels: *Panels = try allocator.create(Panels);
    panels.allocator = allocator;

    panels.home = try home_panel.init(allocator, all_screens, panels, messenger);
    errdefer {
        panels.deinit();
    }
    panels.other = try other_panel.init(allocator, all_screens, panels, messenger);
    errdefer {
        panels.deinit();
    }

    return panels;
}
