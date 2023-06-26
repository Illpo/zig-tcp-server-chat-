const std = @import("std");
const net = std.net;

pub fn main() anyerror!void {

    var server = net.StreamServer.init(.{});
    server.reuse_address = true;
    defer server.deinit();
    try server.listen(net.Address.parseIp("127.0.0.1", 8080) catch unreachable);
    std.debug.print("Listening on {}\n", .{server.listen_address});

    while ((server.accept())) |conn| {
        std.log.info("Accepted Connection from: {}", .{conn.address});
        if (conn.stream.write("You are connected")) |size| {
          std.log.info("size message is {}", .{size});
        } else |err| {
          std.log.err("Error: {}", .{err});
        }
        while (true) {
          var buff: [128]u8 = undefined;
          const c = try conn.stream.reader().read(&buff);
          if (c != 0) {
            std.log.info("{}:  {s}", .{conn.address, buff[0..c]});
          }
        }
        conn.stream.close();
    } else |err| {
        return err;
    }
}