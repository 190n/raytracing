const std = @import("std");

e: [3]f64,

const Vec3 = @This();

pub fn zero() Vec3 {
    return .{ .e = [3]f64{ 0.0, 0.0, 0.0 } };
}

pub fn create(e0: f64, e1: f64, e2: f64) Vec3 {
    return .{ .e = [3]f64{ e0, e1, e2 } };
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

pub fn format(self: Vec3, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
    _ = fmt;
    _ = options;

    try writer.print("{d} {d} {d}", .{ self.e[0], self.e[1], self.e[2] });
}

pub fn add(u: *const Vec3, v: *const Vec3) Vec3 {
    return Vec3.create(
        u.e[0] + v.e[0],
        u.e[1] + v.e[1],
        u.e[2] + v.e[2],
    );
}

pub fn sub(u: *const Vec3, v: *const Vec3) Vec3 {
    return Vec3.create(
        u.e[0] - v.e[0],
        u.e[1] - v.e[1],
        u.e[2] - v.e[2],
    );
}

pub fn mulTerms(u: *const Vec3, v: *const Vec3) Vec3 {
    return Vec3.create(
        u.e[0] * v.e[0],
        u.e[1] * v.e[1],
        u.e[2] * v.e[2],
    );
}

pub fn mulScalar(self: *const Vec3, t: f64) Vec3 {
    return Vec3.create(t * self.e[0], t * self.e[1], t * self.e[2]);
}

pub fn divScalar(self: *const Vec3, t: f64) Vec3 {
    return self.mulScalar(1.0 / t);
}

pub fn dot(u: *const Vec3, v: *const Vec3) f64 {
    return u.e[0] * v.e[0] + u.e[1] * v.e[1] + u.e[2] * v.e[2];
}

pub fn cross(u: *const Vec3, v: *const Vec3) Vec3 {
    return Vec3.create(
        u.e[1] * v.e[2] - u.e[2] * v.e[1],
        u.e[2] * v.e[0] - u.e[0] * v.e[2],
        u.e[0] * v.e[1] - u.e[1] * v.e[0],
    );
}

pub fn unitVector(v: *const Vec3) Vec3 {
    return v.divScalar(v.length());
}

pub const Point3 = Vec3;
pub const Color = Vec3;

fn expectEqualVector(expected: []const f64, actual: Vec3) !void {
    for (expected) |v, i| {
        try std.testing.expectApproxEqRel(v, actual.e[i], 0.0001);
    }
}

test "Vec3.zero" {
    const v = Vec3.zero();
    try expectEqualVector(&[_]f64{ 0.0, 0.0, 0.0 }, v);
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

test "Vec3 formatting" {
    const v = Vec3.create(1.0, 2.0, 3.0);
    const v_string = try std.fmt.allocPrint(std.testing.allocator, "{}", .{v});
    defer std.testing.allocator.free(v_string);
    try std.testing.expectEqualStrings("1 2 3", v_string);
}

const test_u = Vec3.create(-2.0, 6.0, 2.0);
const test_v = Vec3.create(3.0, -4.0, 1.0);

test "Vec3.add" {
    try expectEqualVector(&[_]f64{ 1.0, 2.0, 3.0 }, test_u.add(&test_v));
    try expectEqualVector(&[_]f64{ 1.0, 2.0, 3.0 }, test_v.add(&test_u));
}

test "Vec3.sub" {
    try expectEqualVector(&[_]f64{ -5.0, 10.0, 1.0 }, test_u.sub(&test_v));
    try expectEqualVector(&[_]f64{ 5.0, -10.0, -1.0 }, test_v.sub(&test_u));
}

test "Vec3.mulTerms" {
    try expectEqualVector(&[_]f64{ -6.0, -24.0, 2.0 }, test_u.mulTerms(&test_v));
    try expectEqualVector(&[_]f64{ -6.0, -24.0, 2.0 }, test_v.mulTerms(&test_u));
}

test "Vec3.mulScalar" {
    try expectEqualVector(&[_]f64{ 6.0, -8.0, 2.0 }, test_v.mulScalar(2.0));
}

test "Vec3.divScalar" {
    try expectEqualVector(&[_]f64{ 1.5, -2.0, 0.5 }, test_v.divScalar(2.0));
}

test "Vec3.dot" {
    try std.testing.expectEqual(@as(f64, -28.0), test_u.dot(&test_v));
    try std.testing.expectEqual(@as(f64, -28.0), test_v.dot(&test_u));
}

test "Vec3.cross" {
    try expectEqualVector(&[_]f64{ 14.0, 8.0, -10.0 }, test_u.cross(&test_v));
    try expectEqualVector(&[_]f64{ -14.0, -8.0, 10.0 }, test_v.cross(&test_u));
}

test "Vec3.unitVector" {
    try expectEqualVector(&[_]f64{ -0.301511, 0.904534, 0.301511 }, test_u.unitVector());
    try expectEqualVector(&[_]f64{ 0.588348, -0.784465, 0.196116 }, test_v.unitVector());
}
