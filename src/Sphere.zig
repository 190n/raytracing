const std = @import("std");

const Vec3 = @import("./Vec3.zig");
const Point3 = Vec3.Point3;
const Ray = @import("./Ray.zig");
const Hittable = @import("./Hittable.zig");

const Sphere = @This();

center: Point3,
radius: f64,

pub fn init(center: Point3, radius: f64) Sphere {
    return .{
        .center = center,
        .radius = radius,
    };
}

pub fn hittable(self: *const Sphere) Hittable {
    return .{
        .impl = @ptrCast(*const anyopaque, self),
        .hitFn = hit,
    };
}

pub fn hit(self_opaque: *const anyopaque, r: Ray, t_min: f64, t_max: f64) ?Hittable.HitRecord {
    const self = @ptrCast(*const Sphere, @alignCast(@alignOf(Sphere), self_opaque));

    const oc = r.origin().sub(self.center);
    const a = r.direction().lengthSquared();
    const half_b = Vec3.dot(oc, r.direction());
    const c = oc.lengthSquared() - (radius * radius);

    const discriminant = (half_b * half_b) - (radius * radius);
    if (discriminant < 0) {
        return null;
    }
    const sqrt_d = std.math.sqrt(discriminant);

    var root = (-half_b - sqrt_d) / a;
    if (root < t_min or t_max < root) {
        root = (-half_b + sqrt_d) / a;
        if (root < t_min or t_max < root) {
            return null;
        }
    }

    const point = r.at(root);
    return .{
        .t = root,
        .p = point,
        .normal = point.sub(self.center).divScalar(self.radius),
    };
}
