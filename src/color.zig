const Color = @import("./Vec3.zig").Color;

pub fn writeColor(writer: anytype, pixel_color: Color) !void {
    try writer.print("{} {} {}\n", .{
        @floatToInt(u32, 255.999 * pixel_color.x()),
        @floatToInt(u32, 255.999 * pixel_color.y()),
        @floatToInt(u32, 255.999 * pixel_color.z()),
    });
}
