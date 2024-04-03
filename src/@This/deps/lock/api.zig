const std = @import("std");

pub const ThreadLock = struct {
    allocator: std.mem.Allocator,
    depth: usize,
    thread_id: ?std.Thread.Id,
    mutex: std.Thread.Mutex,

    pub fn deinit(self: *ThreadLock) void {
        self.allocator.destroy(self);
    }

    pub fn lock(self: *ThreadLock) void {
        var current_thread_id: std.Thread.Id = std.Thread.getCurrentId();
        if (self.thread_id) |lock_thread_id| {
            if (current_thread_id == lock_thread_id) {
                // This thread already controls the lock.
                // Let it keep the lock.
                self.depth += 1;
                return;
            } else {
                // This thread does not control the lock.
                // Let it wait.
                self.mutex.lock();
                self.thread_id = current_thread_id;
                self.depth = 1;
                return;
            }
        } else {
            // There is no current id.
            self.mutex.lock();
            self.thread_id = current_thread_id;
            self.depth = 1;
        }
    }

    pub fn unlock(self: *ThreadLock) void {
        var current_thread_id: std.Thread.Id = std.Thread.getCurrentId();
        if (self.thread_id) |lock_thread_id| {
            // A thread has this locked.
            if (current_thread_id != lock_thread_id) {
                // Another thread has this lock.
                return;
            }
        } else {
            // No thread has this lock.
            return;
        }
        // This thread has this lock.
        self.depth -= 1;
        if (self.depth > 0) {
            // This thread still controls this lock.
            return;
        } else {
            // This thread no longer controls this lock.
            self.thread_id = null;
            self.mutex.unlock();
        }
    }
};

pub fn init(allocator: std.mem.Allocator) !*ThreadLock {
    var self: *ThreadLock = try allocator.create(ThreadLock);
    self.allocator = allocator;
    self.thread_id = null;
    self.depth = 0;
    return self;
}