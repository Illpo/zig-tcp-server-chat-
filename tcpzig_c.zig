const std = @import("std");
const net = std.net;

pub fn main() anyerror!void {
    var addr = try std.net.Address.parseIp("127.0.0.1", 8080);
    var socket = try std.net.tcpConnectToAddress(addr);
    defer socket.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const stdin = std.io.getStdIn();
    defer stdin.close();

    while (true) {
        std.log.info("Connected to a server...", .{});
        var buff: [128]u8 = undefined;
        const c = try socket.read(&buff);
        if (c == 0) return;
        std.log.info("[SERVER]: {s}", .{buff[0..c]});

        while (true) {
            std.debug.print(">_ ", .{});
            const input = try stdin.reader().readUntilDelimiterAlloc(allocator, '\n', 128);
            _ = try socket.write(input);
            defer allocator.free(input);
        }
        socket.close();
    } else |err| {
        return err;
    }
}