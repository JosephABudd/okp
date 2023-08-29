const std = @import("std");
const dvui = @import("dvui");
const SDLBackend = @import("SDLBackend");

const frontend = @import("src/frontend/api.zig");
const backend = @import("src/backend/api.zig");
const channel = @import("channel");

var gpa_instance = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_instance.allocator();

var show_dialog_outside_frame: bool = false;

/// This example shows how to use the dvui for a normal application:
/// - dvui renders the whole application
/// - render frames only when needed
pub fn main() !void {
    // init SDL gui_backend (creates OS window)
    var gui_backend = try SDLBackend.init(.{
        .width = 500,
        .height = 600,
        .vsync = true,
        .title = "GUI Standalone Example",
    });
    defer gui_backend.deinit();

    // init dvui Window (maps onto a single OS window)
    var win = try dvui.Window.init(@src(), 0, gpa, gui_backend.backend());
    defer win.deinit();

    // GP allocator for backend and channels.
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = general_purpose_allocator.allocator();

    // The channels between the front and back ends.
    var initialized_channels: bool = false;
    const backToFront: *channel.Channels = try channel.init(allocator);
    const frontToBack: *channel.Channels = try channel.init(allocator);

    // Initialize the front and back ends.
    try frontend.init(allocator, frontToBack, backToFront);
    defer frontend.deinit();
    try backend.init(allocator, backToFront, frontToBack);
    defer backend.deinit();

    main_loop: while (true) {
        // Arena allocator for the front end.
        var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena_allocator.deinit();
        var arena = arena_allocator.allocator();

        // beginWait coordinates with waitTime below to run frames only when needed
        var nstime = win.beginWait(gui_backend.hasEvent());

        // marks the beginning of a frame for dvui, can call dvui functions after this
        try win.begin(arena, nstime);

        // send all SDL events to dvui for processing
        const quit = try gui_backend.addAllEvents(&win);
        if (quit) break :main_loop;

        try frontend.frame(arena);

        if (!initialized_channels) {
            initialized_channels = true;
            // Send the initialize message telling the backend that the frontend is ready.
            frontToBack.initialize.send();
        }

        // marks end of dvui frame, don't call dvui functions after this
        // - sends all dvui stuff to gui_backend for rendering, must be called before renderPresent()
        const end_micros = try win.end(.{});

        // cursor management
        gui_backend.setCursor(win.cursorRequested());

        // render frame to OS
        gui_backend.renderPresent();

        // waitTime and beginWait combine to achieve variable framerates
        const wait_event_micros = win.waitTime(end_micros, null);
        gui_backend.waitEventTimeout(wait_event_micros);

        // Example of how to show a dialog from another thread (outside of win.begin/win.end)
        if (show_dialog_outside_frame) {
            show_dialog_outside_frame = false;
            try dvui.dialog(@src(), .{ .window = &win, .modal = false, .title = "Dialog from Outside", .message = "This is a non modal dialog that was created outside win.begin()/win.end(), usually from another thread." });
        }
    }
}
