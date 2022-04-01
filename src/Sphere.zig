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
    const c = oc.lengthSquared() - (self.radius * self.radius);

    const discriminant = (half_b * half_b) - (a * c);
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
    return Hittable.HitRecord{
        .t = root,
        .p = point,
        .normal = point.sub(self.center).divScalar(self.radius),
    };
}

const expectEqualVector = Vec3.expectEqualVector;

test "Sphere.init" {
    const s = Sphere.init(Point3.zero(), 3.0);
    try expectEqualVector(&[_]f64{ 0.0, 0.0, 0.0 }, s.center);
    try std.testing.expectEqual(@as(f64, 3.0), s.radius);
}

const missRay = Ray.init(Point3.init(-2.0, 0.0, 0.0), Vec3.init(1.0, -1.0, 0.0));

const SphereTest = struct {
    sphere: Sphere,
    ray: Ray,
    t_min: f64,
    t_max: f64,
    result: ?Hittable.HitRecord,
};

const sphereTests = [_]SphereTest{
    .{
        .sphere = Sphere.init(Point3.zero(), 1.0),
        .ray = Ray.init(Point3.init(-2.0, 0.0, 0.0), Vec3.init(1.0, -1.0, 0.0)),
        .t_min = 0.0,
        .t_max = 10.0,
        .result = null
    },
    .{
        .sphere = Sphere.init(Point3.zero(), 1.0),
        .ray = Ray.init(Point3.init(-2.0, 0.0, 0.0), Vec3.init(1.0, 0.0, 0.0)),
        .t_min = 0.0,
        .t_max = 1.0,
        .result = Hittable.HitRecord{
            .p = Point3.init(-1.0, 0.0, 0.0),
            .normal = Vec3.init(-1.0, 0.0, 0.0),
            .t = 1.0,
        },
    }
};

test "Sphere.hit" {
    for (sphereTests) |st| {
        try std.testing.expectEqual(st.result, st.sphere.hit(st.ray, st.t_min, st.t_max));
    }
}
