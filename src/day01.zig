const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const testing = std.testing;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day01.txt");

pub fn main() !void {
    var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_allocator.deinit();
    const arena_instance = arena_allocator.allocator();

    const part1 = try Solution.solvePart1(data, arena_instance);
    print("part1: {d}\n", .{part1});

    const part2 = try Solution.solvePart2(data, arena_instance);
    print("part2: {d}\n", .{part2});
}

const Solution = struct {
    const NumList = std.ArrayList(isize);

    fn getList(input: []const u8, allocator: std.mem.Allocator) ![]NumList {
        var it = tokenizeSca(u8, input, '\n');
        const lists = try allocator.alloc(NumList, 2);
        for (lists) |*list| list.* = NumList.init(allocator);
        while (it.next()) |line| {
            var it_line = std.mem.tokenizeScalar(u8, line, ' ');
            var i: usize = 0;
            while (it_line.next()) |elem| : (i += 1) {
                const num = try std.fmt.parseInt(isize, elem, 10);
                try lists[i].append(num);
            }
        }
        return lists;
    }

    fn solvePart1(input: []const u8, allocator: std.mem.Allocator) !usize {
        var sum: usize = 0;
        const lists = try getList(input, allocator);
        for (lists) |list| sort(isize, list.items, {}, std.sort.asc(isize));
        for (0..lists[0].items.len) |i| {
            sum += @abs(lists[0].items[i] - lists[1].items[i]);
        }
        return sum;
    }

    fn solvePart2(input: []const u8, allocator: std.mem.Allocator) !usize {
        var sum: usize = 0;
        const lists = try getList(input, allocator);
        for (0..lists[0].items.len) |i| {
            var search = [_]isize{lists[0].items[i]};
            const count = std.mem.count(isize, lists[1].items, &search);
            sum += count * @as(usize, @intCast(lists[0].items[i]));
        }
        return sum;
    }
};

test "part1" {
    const test_data =
        \\3   4
        \\4   3
        \\2   5
        \\1   3
        \\3   9
        \\3   3
    ;

    var arena_allocator = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena_allocator.deinit();
    const arena_instance = arena_allocator.allocator();

    try testing.expectEqual(11, try Solution.solvePart1(test_data, arena_instance));
}

test "part2" {
    const test_data =
        \\3   4
        \\4   3
        \\2   5
        \\1   3
        \\3   9
        \\3   3
    ;

    var arena_allocator = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena_allocator.deinit();
    const arena_instance = arena_allocator.allocator();

    try testing.expectEqual(31, try Solution.solvePart2(test_data, arena_instance));
}

// Useful stdlib functions
const tokenizeAny = std.mem.tokenizeAny;
const tokenizeSeq = std.mem.tokenizeSequence;
const tokenizeSca = std.mem.tokenizeScalar;
const splitAny = std.mem.splitAny;
const splitSeq = std.mem.splitSequence;
const splitSca = std.mem.splitScalar;
const indexOf = std.mem.indexOfScalar;
const indexOfAny = std.mem.indexOfAny;
const indexOfStr = std.mem.indexOfPosLinear;
const lastIndexOf = std.mem.lastIndexOfScalar;
const lastIndexOfAny = std.mem.lastIndexOfAny;
const lastIndexOfStr = std.mem.lastIndexOfLinear;
const trim = std.mem.trim;
const sliceMin = std.mem.min;
const sliceMax = std.mem.max;

const parseInt = std.fmt.parseInt;
const parseFloat = std.fmt.parseFloat;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.block;
const asc = std.sort.asc;
const desc = std.sort.desc;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
