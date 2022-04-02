const std = @import("std");

const Vec3 = @import("./Vec3.zig");
const Point3 = Vec3.Point3;
const Ray = @import("./Ray.zig");
const Hittable = @import("./Hittable.zig");
const HitRecord = Hittable.HitRecord;

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

pub fn hit(self_opaque: *const anyopaque, r: Ray, t_min: f64, t_max: f64) ?HitRecord {
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
    var rec = HitRecord{
        .t = root,
        .p = point,
        .normal = undefined,
        .front_face = undefined,
    };
    const outward_normal = point.sub(self.center).divScalar(self.radius);
    rec.setFaceNormal(r, outward_normal);
    return rec;
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
    result: ?HitRecord,
};

// zig fmt: off
const sphereTests = [_]SphereTest{
    // miss
    .{
        .sphere = Sphere.init(Point3.zero(), 1.0),
        .ray = Ray.init(Point3.init(-2.0, 0.0, 0.0), Vec3.init(1.0, -1.0, 0.0)),
        .t_min = 0.0,
        .t_max = 10.0,
        .result = null
    },
    // direct hit
    .{
        .sphere = Sphere.init(Point3.zero(), 1.0),
        .ray = Ray.init(Point3.init(-2.0, 0.0, 0.0), Vec3.init(1.0, 0.0, 0.0)),
        .t_min = 0.0,
        .t_max = 1.0,
        .result = HitRecord{
            .p = Point3.init(-1.0, 0.0, 0.0),
            .normal = Vec3.init(-1.0, 0.0, 0.0),
            .t = 1.0,
            .front_face = true,
        },
    },
    // hit too early
    .{
        .sphere = Sphere.init(Point3.zero(), 1.0),
        .ray = Ray.init(Point3.init(-2.0, 0.0, 0.0), Vec3.init(1.0, 0.0, 0.0)),
        .t_min = 1.01,
        .t_max = 1.1,
        .result = null,
    },
    // find the second hit
    .{
        .sphere = Sphere.init(Point3.zero(), 1.0),
        .ray = Ray.init(Point3.init(-2.0, 0.0, 0.0), Vec3.init(1.0, 0.0, 0.0)),
        .t_min = 1.9,
        .t_max = 10.0,
        .result = HitRecord{
            .p = Point3.init(1.0, 0.0, 0.0),
            .normal = Vec3.init(-1.0, 0.0, 0.0),
            .t = 3.0,
            .front_face = false,
        },
    },
};
// zig fmt: on

test "Sphere.hit" {
    for (sphereTests) |st| {
        try std.testing.expectEqual(st.result, st.sphere.hit(st.ray, st.t_min, st.t_max));
    }
}

test "Sphere.hit via interface" {
    for (sphereTests) |st| {
        const hittable_obj = st.sphere.hittable();
        try std.testing.expectEqual(st.result, hittable_obj.hit(st.ray, st.t_min, st.t_max));
    }
}
