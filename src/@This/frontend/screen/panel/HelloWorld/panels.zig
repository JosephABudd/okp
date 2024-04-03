const std = @import("std");
const dvui = @import("dvui");

const _framers_ = @import("framers");
const _messenger_ = @import("messenger.zig");
const _various_ = @import("various");
const ExitFn = @import("various").ExitFn;
const MainView = @import("framers").MainView;
const _HelloWorld_ = @import("HelloWorld_panel.zig");

const PanelTags = enum {
    HelloWorld,
    none,
};

pub const Panels = struct {
    allocator: std.mem.Allocator,
    HelloWorld: ?*_HelloWorld_.Panel,
    current_panel_tag: PanelTags,

    pub fn deinit(self: *Panels) void {
        if (self.HelloWorld) |HelloWorld| {
            HelloWorld.deinit();
        }
        self.allocator.destroy(self);
    }

    pub fn frameCurrent(self: *Panels, allocator: std.mem.Allocator) !void {
        var result = switch (self.current_panel_tag) {
            .HelloWorld => self.HelloWorld.?.frame(allocator),
            .none => self.HelloWorld.?.frame(allocator),
        };
        return result;
    }

    pub fn refresh(self: *Panels) void {
        switch (self.current_panel_tag) {
            .HelloWorld => self.HelloWorld.?.refresh(),
            .none => self.HelloWorld.?.refresh(),
        }
    }

    pub fn setCurrentToHelloWorld(self: *Panels) void {
        self.current_panel_tag = PanelTags.HelloWorld;
    }

    pub fn setContainer(self: *Panels, container: *_various_.Container) void {
        self.HelloWorld.?.setContainer(container);
    }
};

pub fn init(allocator: std.mem.Allocator, main_view: *MainView, messenger: *_messenger_.Messenger, exit: ExitFn, window: *dvui.Window) !*Panels {
    var panels: *Panels = try allocator.create(Panels);
    panels.allocator = allocator;
    panels.HelloWorld = try _HelloWorld_.init(allocator, main_view, panels, messenger, exit, window);
    errdefer panels.deinit();

    return panels;
}
