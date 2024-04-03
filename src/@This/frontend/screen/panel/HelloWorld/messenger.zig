const std = @import("std");

const _channel_ = @import("channel");
const _message_ = @import("message");
const _modal_params_ = @import("modal_params");
const _panels_ = @import("panels.zig");
const ExitFn = @import("various").ExitFn;
const MainView = @import("framers").MainView;
const OKModalParams = _modal_params_.OK;

pub const Messenger = struct {
    allocator: std.mem.Allocator,

    main_view: *MainView,
    all_panels: *_panels_.Panels,
    send_channels: *_channel_.FrontendToBackend,
    receive_channels: *_channel_.BackendToFrontend,
    exit: ExitFn,

    pub fn deinit(self: *Messenger) void {
        self.allocator.destroy(self);
    }

    // Below is an example of a send function.
    // sendFubar is provided as an example.
    // It sends the Fubar message.
    // pub fn sendFubar(self: *Messenger, some_text: []const u8) !void {
    //     var message: *_message_.Fubar.Message = try _message_.Fubar.init(self.allocator);
    //     try message.frontend_payload.set(.{.foobar = some_text});
    //     try self.send_channels.Fubar.send(message);
    // }

    // Below is an example of a receive function.
    // receiveFubar is provided as an example.
    // It receives the Fubar message.
    // It implements a behavior required by receive_channels.Fubar.
    // pub fn receiveFubar(implementor: *anyopaque, message: *_message_.Fubar.Message) anyerror!void {
    //     var self: *Messenger = @alignCast(@ptrCast(implementor));
    //     defer message.deinit();
    //     _ = self;
    //
    //     // message.backend_payload is the struct holding the message from the backend.
    //     if (message.backend_payload.user_error_message) |user_error_message| {
    //         // There was a user error so inform the user.
    //         const ok_args = try OKModalParams.init(
    //            self.allocator,
    //            "Error",
    //            user_error_message,
    //         );
    //         // The ok modal screen owns the ok_args.
    //         // So do not deinit the ok_args.
    //         self.main_view.showOK(ok_args)
    //         // This was only a user error not a fatal error.
    //         return;
    //     }
    //     // No user error.
    //     // Pass on the information contained in the message to panels.
    //     // Handling Errors: Call exit and return the error.
    //     self.panels.HelloWorld.setHeading(message.BackendPayload.something) catch |err| {
    //         // Handle the error.
    //         self.exit(@src(), err, "self.panels.HelloWorld.setHeading(message.BackendPayload.something)");
    //         return err;
    //     };
    // }
};

pub fn init(allocator: std.mem.Allocator, main_view: *MainView, send_channels: *_channel_.FrontendToBackend, receive_channels: *_channel_.BackendToFrontend, exit: ExitFn) !*Messenger {
    var messenger: *Messenger = try allocator.create(Messenger);
    messenger.allocator = allocator;
    messenger.main_view = main_view;
    messenger.send_channels = send_channels;
    messenger.receive_channels = receive_channels;
    messenger.exit = exit;

    // For a messenger to receive a message, the messenger must:
    //
    // 1. Implement the behavior of the message's channel.
    // var fubarBehavior = try receive_channels.Fubar.initBehavior();
    // errdefer {
    //     allocator.destroy(messenger);
    // }
    // fubarBehavior.implementor = messenger;
    // fubarBehavior.receiveFn = Messenger.receiveFubar;
    //
    // 2. Subscribe to the Fubar channel in order to receive the Fubar messages.
    // try receive_channels.Fubar.subscribe(fubarBehavior);
    // errdefer {
    //     allocator.destroy(messenger);
    // }

    return messenger;
}