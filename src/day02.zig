const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const testing = std.testing;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day02.txt");

pub fn main() !void {
    const part1 = try Solution.solvePart1(data);
    std.debug.print("part1: {d}\n", .{part1});
}

const LevelType = enum {
    increasing,
    decreasing,
    undetermined,
};

fn isSafeReport(num: isize, last_num_maybe: ?isize, level_type: *LevelType) bool {
    switch (level_type.*) {
        .undetermined => {
            if (last_num_maybe) |last_num| {
                if (last_num > num and last_num - num <= 3) {
                    level_type.* = .decreasing;
                    return true;
                } else if (last_num < num and num - last_num <= 3) {
                    level_type.* = .increasing;
                    return true;
                } else {
                    return false;
                }
            }
            return true;
        },
        .increasing => {
            if (1 <= num - last_num_maybe.? and num - last_num_maybe.? <= 3) {
                return true;
            } else {
                return false;
            }
        },
        .decreasing => {
            if (1 <= last_num_maybe.? - num and last_num_maybe.? - num <= 3) {
                return true;
            } else {
                return false;
            }
        },
    }
}

const Solution = struct {
    fn solvePart1(input: []const u8) !usize {
        var sum: usize = 0;
        var it = tokenizeSca(u8, input, '\n');
        while (it.next()) |line| {
            var last_num: ?isize = null;
            var is_safe_report: bool = false;
            var level_type: LevelType = .undetermined;
            var it_line = tokenizeSca(u8, line, ' ');
            while (it_line.next()) |num_str| {
                const num = try parseInt(isize, num_str, 10);
                defer last_num = num;
                is_safe_report = isSafeReport(num, last_num, &level_type);
                if (!is_safe_report) break;
            }
            if (is_safe_report) sum += 1;
        }
        return sum;
    }

    const ReportList = std.DoublyLinkedList(isize);

    fn solvePart2(input: []const u8, allocator: std.mem.Allocator) !usize {
        var arena_allocator = std.heap.ArenaAllocator.init(allocator);
        defer arena_allocator.deinit();
        const arena_instance = arena_allocator.allocator();

        var sum: usize = 0;
        var it = tokenizeSca(u8, input, '\n');
        while (it.next()) |line| {
            var last_num: ?isize = null;
            var is_safe_report: bool = true;
            var level_type: LevelType = .undetermined;
            var report: ReportList = .{};
            var it_line = tokenizeSca(u8, line, ' ');
            while (it_line.next()) |num_str| {
                const num = try parseInt(isize, num_str, 10);
                defer last_num = num;
                if (is_safe_report) {
                    is_safe_report = isSafeReport(num, last_num, &level_type);
                }
                const node = try arena_instance.create(ReportList.Node);
                node.data = num;
                report.append(node);
            }
            if (!is_safe_report) {
                // post process unsafe reports
                const it_report = report.first.?;
                while (it_report.next) |node| {
                    last_num = null;
                    level_type = .undetermined;

                    const prev_maybe = node.prev;
                    const next_maybe = node.next;
                    report.remove(node);
                    const it_inner = report.first.?;
                    while (it_inner.next) |n| {
                        defer last_num = n.data;
                        is_safe_report = isSafeReport(n.data, last_num, &level_type);
                        if (!is_safe_report) break;
                    }
                    if (is_safe_report) sum += 1;
                    if (prev_maybe) |prev| report.insertAfter(prev, node);
                    if (next_maybe) |next| report.insertBefore(next, node);
                }
            }
            if (is_safe_report) sum += 1;
        }
        return sum;
    }
};

test "part1" {
    const test_data =
        \\7 6 4 2 1
        \\1 2 7 8 9
        \\9 7 6 2 1
        \\1 3 2 4 5
        \\8 6 4 4 1
        \\1 3 6 7 9
    ;
    const safe_num = try Solution.solvePart1(test_data);
    try testing.expectEqual(2, safe_num);
}

test "part2" {
    const test_data =
        \\7 6 4 2 1
        \\1 2 7 8 9
        \\9 7 6 2 1
        \\1 3 2 4 5
        \\8 6 4 4 1
        \\1 3 6 7 9
    ;
    const safe_num = try Solution.solvePart2(test_data, testing.allocator);
    try testing.expectEqual(4, safe_num);
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
