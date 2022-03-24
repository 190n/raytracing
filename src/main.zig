const std = @import("std");

const Vec3 = @import("./Vec3.zig");
const Color = Vec3.Color;
const writeColor = @import("./color.zig").writeColor;

pub fn main() anyerror!void {
    const image_width = 256;
    const image_height = 256;

    var buf = std.io.bufferedWriter(std.io.getStdOut().writer());
    const writer = buf.writer();
    try writer.print("P3\n{} {}\n255\n", .{ image_width, image_height });

    const err_writer = std.io.getStdErr().writer();

    var j: i32 = image_height - 1;
    while (j >= 0) : (j -= 1) {
        try err_writer.print("\rScanlines remaining: {d: <3}", .{@intCast(u32, j)});

        var i: u32 = 0;
        while (i < image_width) : (i += 1) {
            const pixel_color = Color.create(
                @intToFloat(f64, i) / (image_width - 1),
                @intToFloat(f64, j) / (image_height - 1),
                0.25,
            );
            try writeColor(writer, &pixel_color);
        }
    }

    try buf.flush();
}
