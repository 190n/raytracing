const std = @import("std");

pub fn main() anyerror!void {
    const imageWidth = 256;
    const imageHeight = 256;

    const writer = std.io.getStdOut().writer();
    try writer.print("P3\n{} {}\n255\n", .{ imageWidth, imageHeight });

    var j: i32 = imageHeight - 1;
    while (j >= 0) : (j -= 1) {
        var i: u32 = 0;
        while (i < imageWidth) : (i += 1) {
            const r = @intToFloat(f64, i) / (imageWidth - 1);
            const g = @intToFloat(f64, j) / (imageHeight - 1);
            const b = 0.25;

            const ir = @floatToInt(u32, 255.999 * r);
            const ig = @floatToInt(u32, 255.999 * g);
            const ib = @floatToInt(u32, 255.999 * b);

            try writer.print("{} {} {}\n", .{ ir, ig, ib });
        }
    }
}
