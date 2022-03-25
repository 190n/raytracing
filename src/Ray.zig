const Vec3 = @import("./Vec3.zig");
const Point3 = Vec3.Point3;

orig: Point3,
dir: Vec3,

const Ray = @This();

pub fn zero() Ray {
    return .{ .orig = Point3.zero(), .dir = Vec3.zero() };
}

pub fn create(origin: *const Point3, direction: *const Vec3) Ray {
    return .{ .orig = origin.*, .dir = direction.* };
}

pub fn at(self: *const Ray, t: f64) Point3 {
    return self.orig.add(&self.dir.mulScalar(t));
}

const expectEqualVector = Vec3.expectEqualVector;

test "Ray.zero" {
    const r = Ray.zero();
    try expectEqualVector(&[_]f64{ 0.0, 0.0, 0.0 }, r.orig);
    try expectEqualVector(&[_]f64{ 0.0, 0.0, 0.0 }, r.dir);
}

test "Ray.create" {
    const r = Ray.create(&Vec3.create(1.0, 2.0, 3.0), &Vec3.create(4.0, 5.0, 6.0));
    try expectEqualVector(&[_]f64{ 1.0, 2.0, 3.0 }, r.orig);
    try expectEqualVector(&[_]f64{ 4.0, 5.0, 6.0 }, r.dir);
}

test "Ray.at" {
    const r = Ray.create(&Vec3.create(6.0, 7.0, 8.0), &Vec3.create(12.0, 3.0, 4.0).unitVector());
    try expectEqualVector(&[_]f64{ 18.0, 10.0, 12.0 }, r.at(13.0));
}
