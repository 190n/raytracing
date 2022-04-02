const std = @import("std");

pub inline fn degreesToRadians(degrees: f64) f64 {
    return degrees * std.math.pi / 180.0;
}
