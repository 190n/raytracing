const std = @import("std");

const Vec3 = @import("./Vec3.zig");
const Color = Vec3.Color;
const Point3 = Vec3.Point3;
const writeColor = @import("./color.zig").writeColor;
const Ray = @import("./Ray.zig");
const Hittable = @import("./Hittable.zig");
const HittableList = @import("./HittableList.zig");
const Sphere = @import("./Sphere.zig");

fn rayColor(r: Ray, world: Hittable) Color {
    if (world.hit(r, 0, std.math.inf(f64))) |rec| {
        return rec.normal.add(Color.init(1.0, 1.0, 1.0)).mulScalar(0.5);
    }

    const unit_direction = r.direction().unitVector();
    const t = 0.5 * (unit_direction.y() + 1.0);
    return Color.init(1.0, 1.0, 1.0).mulScalar(1.0 - t).add(Color.init(0.5, 0.7, 1.0).mulScalar(t));
}

pub fn main() anyerror!void {
    // image
    const aspect_ratio = 16.0 / 9.0;
    const image_width = 400;
    const image_height = @floatToInt(comptime_int, image_width / aspect_ratio);

    // camera
    const viewport_height = 2.0;
    const viewport_width = aspect_ratio * viewport_height;
    const focal_length = 1.0;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var world = HittableList.init(allocator);
    defer world.deinit();
    try world.add(Sphere.init(Point3.init(0.0, 0.0, -1.0), 0.5).hittable());
    try world.add(Sphere.init(Point3.init(0.0, -100.5, -1.0), 100.0).hittable());

    const origin = Point3.zero();
    const horizontal = Vec3.init(viewport_width, 0.0, 0.0);
    const vertical = Vec3.init(0.0, viewport_height, 0.0);
    const lower_left_corner = origin
        .sub(horizontal.divScalar(2.0))
        .sub(vertical.divScalar(2.0))
        .sub(Vec3.init(0.0, 0.0, focal_length));

    var buf = std.io.bufferedWriter(std.io.getStdOut().writer());
    const writer = buf.writer();
    // header
    try writer.print("P3\n{} {}\n255\n", .{ image_width, image_height });

    const err_writer = std.io.getStdErr().writer();

    // render
    var j: i32 = image_height - 1;
    while (j >= 0) : (j -= 1) {
        try err_writer.print("\rScanlines remaining: {d: <3}", .{@intCast(u32, j)});

        var i: u32 = 0;
        while (i < image_width) : (i += 1) {
            const u = @intToFloat(f64, i) / (image_width - 1);
            const v = @intToFloat(f64, j) / (image_height - 1);
            const r = Ray.init(origin, lower_left_corner
                .add(horizontal.mulScalar(u))
                .add(vertical.mulScalar(v))
                .sub(origin));
            const pixel_color = rayColor(r, world.hittable());
            try writeColor(writer, pixel_color);
        }
    }

    try buf.flush();
}
