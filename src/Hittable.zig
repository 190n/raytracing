const Vec3 = @import("./Vec3.zig");
const Point3 = Vec3.Point3;
const Ray = @import("./Ray.zig");

const Hittable = @This();

pub const HitRecord = struct {
    p: point3,
    normal: vec3,
    t: f64,
};

impl: *anyopaque,
hitFn: fn (impl: *anyopaque, r: Ray, t_min: f64, t_max: f64) ?HitRecord,

pub fn hit(iface: *const Hittable, r: Ray, t_min: f64, t_max: f64) ?HitRecord {
    return iface.hitFn(iface.impl, r, t_min, t_max);
}
