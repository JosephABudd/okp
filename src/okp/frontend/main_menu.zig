const std = @import("std");
const dvui = @import("dvui");
const _framers_ = @import("framers");

pub fn frame(all_screens: *_framers_.Group) !void {
    var m = try dvui.menu(@src(), .horizontal, .{ .background = true, .expand = .horizontal });

    if (try dvui.menuItemIcon(@src(), "OKP", dvui.icons.entypo.menu, .{ .submenu = true }, .{ .expand = .none })) |r| {
        var fw = try dvui.popup(@src(), dvui.Rect.fromPoint(dvui.Point{ .x = r.x, .y = r.y + r.h }), .{});
        defer fw.deinit();

        if (try dvui.menuItemLabel(@src(), "Simple", .{}, .{}) != null) {
            m.close();
            m.deinit();
            all_screens.setCurrent("simple");
            return;
        }

        if (try dvui.menuItemLabel(@src(), "Hard", .{}, .{}) != null) {
            m.close();
            m.deinit();
            all_screens.setCurrent("hard");
            return;
        }

        if (try dvui.menuItemLabel(@src(), "HTabs", .{}, .{}) != null) {
            m.close();
            m.deinit();
            all_screens.setCurrent("htabs");
            return;
        }

        if (try dvui.menuItemLabel(@src(), "VTabs", .{}, .{}) != null) {
            m.close();
            m.deinit();
            all_screens.setCurrent("vtabs");
            return;
        }

        if (try dvui.menuItemLabel(@src(), "Close Menu", .{}, .{}) != null) {
            // dvui.menuGet().?.close();
            m.close();
            m.deinit();
            return;
        }
    }
    m.deinit();
}
