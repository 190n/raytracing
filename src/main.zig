const std = @import("std");

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
            const r = @intToFloat(f64, i) / (image_width - 1);
            const g = @intToFloat(f64, j) / (image_height - 1);
            const b = 0.25;

            const ir = @floatToInt(u32, 255.999 * r);
            const ig = @floatToInt(u32, 255.999 * g);
            const ib = @floatToInt(u32, 255.999 * b);

            try writer.print("{} {} {}\n", .{ ir, ig, ib });
        }
    }

    try buf.flush();
}
