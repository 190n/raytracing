const std = @import("std");

e: [3]f64,

const Vec3 = @This();

pub fn create(e0: f64, e1: f64, e2: f64) Vec3 {
    return .{ .e = [3]f64{ e0, e1, e2} };
}

pub fn x(self: *const Vec3) f64 {
    return self.e[0];
}

pub fn y(self: *const Vec3) f64 {
    return self.e[1];
}

pub fn z(self: *const Vec3) f64 {
    return self.e[2];
}

pub fn neg(self: *const Vec3) Vec3 {
    return create(-self.e[0], -self.e[1], -self.e[2]);
}

pub fn incBy(self: *Vec3, v: *const Vec3) *Vec3 {
    self.e[0] += v.e[0];
    self.e[1] += v.e[1];
    self.e[2] += v.e[2];
    return self;
}

pub fn mulBy(self: *Vec3, t: f64) *Vec3 {
    self.e[0] *= t;
    self.e[1] *= t;
    self.e[2] *= t;
    return self;
}

pub fn divBy(self: *Vec3, t: f64) *Vec3 {
    return self.mulBy(1.0 / t);
}

pub fn length(self: *const Vec3) f64 {
    return std.math.sqrt(self.lengthSquared());
}

pub fn lengthSquared(self: *const Vec3) f64 {
    return self.e[0] * self.e[0] + self.e[1] * self.e[1] + self.e[2] * self.e[2];
}

pub const Point3 = Vec3;
pub const Color = Vec3;

fn expectEqualVector(expected: []const f64, actual: Vec3) !void {
    try std.testing.expectEqualSlices(f64, expected, &actual.e);
}

test "Vec3.create" {
    const v = Vec3.create(0.1, 0.2, 0.3);
    try std.testing.expectEqualSlices(f64, &[_]f64{ 0.1, 0.2, 0.3 }, &v.e);
}

test "Vec3.[xyz]" {
    const v = Vec3.create(0.1, 0.2, 0.3);
    try std.testing.expectEqual(@as(f64, 0.1), v.x());
    try std.testing.expectEqual(@as(f64, 0.2), v.y());
    try std.testing.expectEqual(@as(f64, 0.3), v.z());
}

test "Vec3.neg" {
    const v = Vec3.create(0.1, 0.2, 0.3).neg();
    try expectEqualVector(&[_]f64{ -0.1, -0.2, -0.3 }, v);
}

test "Vec3.incBy" {
    var v1 = Vec3.create(1.0, 2.0, 3.0);
    const v2 = Vec3.create(-6.0, 2.5, 8.0);
    const sum = v1.incBy(&v2);
    try expectEqualVector(&[_]f64{ -5.0, 4.5, 11.0 }, v1);
    try std.testing.expectEqual(&v1, sum);
}

test "Vec3.mulBy" {
    var v = Vec3.create(1.0, 2.0, 3.0);
    const multiplied = v.mulBy(2.0);
    try expectEqualVector(&[_]f64{ 2.0, 4.0, 6.0 }, v);
    try std.testing.expectEqual(&v, multiplied);
}

test "Vec3.divBy" {
    var v = Vec3.create(1.0, 2.0, 3.0);
    const divided = v.divBy(2.0);
    try expectEqualVector(&[_]f64{ 0.5, 1.0, 1.5 }, v);
    try std.testing.expectEqual(&v, divided);
}

test "Vec3.length" {
    const v = Vec3.create(12.0, 3.0, 4.0);
    try std.testing.expectEqual(@as(f64, 13.0), v.length());
}

test "Vec3.lengthSquared" {
    const v = Vec3.create(2.3, 3.1, 4.7);
    try std.testing.expectEqual(@as(f64, 36.99), v.lengthSquared());
}
