const std = @import("std");
const ArrayListUnmanaged = std.ArrayListUnmanaged;
const Allocator = std.mem.Allocator;

const Hittable = @import("./Hittable.zig");
const HitRecord = Hittable.HitRecord;
const Ray = @import("./Ray.zig");
const Sphere = @import("./Sphere.zig");
const Vec3 = @import("./Vec3.zig");
const Point3 = Vec3.Point3;

objects: ArrayListUnmanaged(Hittable),
allocator: Allocator,

const HittableList = @This();

pub fn init(allocator: Allocator) HittableList {
    return .{
        .objects = ArrayListUnmanaged(Hittable){},
        .allocator = allocator,
    };
}

pub fn deinit(self: *HittableList) void {
    self.objects.deinit(self.allocator);
}

pub fn clear(self: *HittableList) void {
    self.objects.clearAndFree(self.allocator);
}

pub fn add(self: *HittableList, object: Hittable) !void {
    try self.objects.append(self.allocator, object);
}

pub fn hittable(self: *const HittableList) Hittable {
    return .{
        .impl = @ptrCast(*const anyopaque, self),
        .hitFn = hit,
    };
}

pub fn hit(self_opaque: *const anyopaque, r: Ray, t_min: f64, t_max: f64) ?HitRecord {
    const self = @ptrCast(*const HittableList, @alignCast(@alignOf(HittableList), self_opaque));
    var closest_so_far = t_max;
    var record: ?HitRecord = null;

    for (self.objects.items) |object| {
        if (object.hit(r, t_min, closest_so_far)) |rec| {
            closest_so_far = rec.t;
            record = rec;
        }
    }

    return record;
}

test "HittableList.hit" {
    var hl = init(std.testing.allocator);
    defer hl.deinit();

    const s1 = Sphere.init(Point3.init(-2.0, 0.0, 0.0), 1.0);
    const s2 = Sphere.init(Point3.init(2.0, 0.0, 0.0), 1.0);
    try hl.add(s1.hittable());
    try hl.add(s2.hittable());

    // hit s1
    try std.testing.expectEqual(HitRecord{
        .p = Point3.init(-2.0, 1.0, 0.0),
        .normal = Vec3.init(0.0, 1.0, 0.0),
        .t = 1.0,
        .front_face = true,
    }, hl.hittable().hit(Ray.init(Point3.init(-2.0, 2.0, 0.0), Vec3.init(0.0, -1.0, 0.0)), 0.0, 10.0).?);
    // hit s2
    try std.testing.expectEqual(HitRecord{
        .p = Point3.init(2.0, 1.0, 0.0),
        .normal = Vec3.init(0.0, 1.0, 0.0),
        .t = 1.0,
        .front_face = true,
    }, hl.hittable().hit(Ray.init(Point3.init(2.0, 2.0, 0.0), Vec3.init(0.0, -1.0, 0.0)), 0.0, 10.0).?);
    // hit s1 (first)
    try std.testing.expectEqual(HitRecord{
        .p = Point3.init(-3.0, 0.0, 0.0),
        .normal = Vec3.init(-1.0, 0.0, 0.0),
        .t = 1.0,
        .front_face = true,
    }, hl.hittable().hit(Ray.init(Point3.init(-4.0, 0.0, 0.0), Vec3.init(1.0, 0.0, 0.0)), 0.0, 10.0).?);
    // hit s2 (too late for s1)
    try std.testing.expectEqual(HitRecord{
        .p = Point3.init(1.0, 0.0, 0.0),
        .normal = Vec3.init(-1.0, 0.0, 0.0),
        .t = 5.0,
        .front_face = true,
    }, hl.hittable().hit(Ray.init(Point3.init(-4.0, 0.0, 0.0), Vec3.init(1.0, 0.0, 0.0)), 3.01, 10.0).?);
}
