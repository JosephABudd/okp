const std = @import("std");
const dvui = @import("dvui");
const _channel_ = @import("channel");
const _panels_ = @import("panels.zig");
const _messenger_ = @import("messenger.zig");
const _startup_ = @import("startup");
const _various_ = @import("various");
const MainView = @import("framers").MainView;

pub const Screen = struct {
    allocator: std.mem.Allocator,
    main_view: *MainView,
    all_panels: ?*_panels_.Panels,
    messenger: ?*_messenger_.Messenger,
    send_channels: *_channel_.FrontendToBackend,
    receive_channels: *_channel_.BackendToFrontend,
    container: ?*_various_.Container,

    /// init constructs this screen.
    pub fn init(startup: _startup_.Frontend) !*Screen {
        var self: *Screen = try startup.allocator.create(Screen);
        self.allocator = startup.allocator;
        self.main_view = startup.main_view;
        self.receive_channels = startup.receive_channels;
        self.send_channels = startup.send_channels;
        self.container = null;

        // The messenger.
        self.messenger = try _messenger_.init(startup.allocator, startup.main_view, startup.send_channels, startup.receive_channels, startup.exit);
        errdefer {
            self.deinit();
        }

        // All of the panels.
        self.all_panels = try _panels_.init(startup.allocator, startup.main_view, self.messenger.?, startup.exit, startup.window);
        errdefer {
            self.deinit();
        }
        self.messenger.?.all_panels = self.all_panels.?;
        // The HelloWorld panel is the default.
        self.all_panels.?.setCurrentToHelloWorld();
        return self;
    }

    pub fn deinit(self: *Screen) void {
        if (self.container) |member| {
            member.deinit();
        }
        if (self.messenger) |member| {
            member.deinit();
        }
        if (self.all_panels) |member| {
            member.deinit();
        }
        self.allocator.destroy(self);
    }

    /// If container is not null then this screen is running inside a container.
    /// Containers run inside the main view.
    pub fn setContainer(self: *Screen, container: *_various_.Container) void {
        self.container = container;
        self.all_panels.?.setContainer(container);
    }

    /// The HelloWorld screen package is offered as an example screen package.
    /// It is set here to always frame:
    /// 1. Inside the main view:
    ///    * as the main menu's startup_screen_tag.
    ///    * in the main menu's sorted_main_menu_screen_tags.
    /// 2. Inside a container.
    pub fn willFrame(_: *Screen) bool {
        return true;
    }

    /// The caller does not own the returned value.
    /// KICKZIG TODO: You may want to edit the returned label.
    pub fn label(_: *Screen) []const u8 {
        return "Hello World";
    }

    pub fn frame(self: *Screen, arena: std.mem.Allocator) !void {
        try self.all_panels.?.frameCurrent(arena);
    }
};