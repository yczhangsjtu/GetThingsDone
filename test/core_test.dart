import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_gtd/core/date_time_utils.dart';
import 'package:flutter_gtd/core/time.dart';

void main() {
  test("Test time utils", () {
    // Test that (year, month, day) tuple and int transform is consistent
    expect(DateTimeUtils.yearMonthDayFromInt(DateTimeUtils.yearMonthDayToInt(2018, 2, 28)), 20180228);
    expect(DateTimeUtils.yearMonthDayFromInt(DateTimeUtils.yearMonthDayToInt(2018, 2, 29)) != 20180229, true);
    expect(DateTimeUtils.yearMonthDayFromInt(DateTimeUtils.yearMonthDayToInt(2020, 2, 29)), 20200229);
    expect(DateTimeUtils.yearMonthDayFromInt(DateTimeUtils.yearMonthDayToInt(1900, 2, 29)) != 19000229, true);

    // Test toString functions
    expect(DateTimeUtils.dayToString(DateTimeUtils.yearMonthDayToInt(2020, 2, 28)), "2020-2-28");
    expect(DateTimeUtils.dayToString(DateTimeUtils.yearMonthDayToInt(2020, 2, 29)), "2020-2-29");
    expect(DateTimeUtils.dayToString(DateTimeUtils.yearMonthDayToInt(2020, 3, 31)), "2020-3-31");
    expect(DateTimeUtils.dayToString(DateTimeUtils.yearMonthDayToInt(2019, 4, 30)), "2019-4-30");
    expect(DateTimeUtils.timeToString(1400), "23:20");
    expect(DateTimeUtils.timeToString(0), "0:00");
    expect(DateTimeUtils.durationToString(0), "0m");
    expect(DateTimeUtils.durationToString(10), "10m");
    expect(DateTimeUtils.durationToString(60), "1h");
    expect(DateTimeUtils.durationToString(70), "1h10m");

    expect(DateTimeUtils.weekDayName(0), "日");
    expect(DateTimeUtils.weekDayName(1), "一");
    expect(DateTimeUtils.weekDayName(2), "二");
    expect(DateTimeUtils.weekDayName(3), "三");
    expect(DateTimeUtils.weekDayName(4), "四");
    expect(DateTimeUtils.weekDayName(5), "五");
    expect(DateTimeUtils.weekDayName(6), "六");
  });

  test("Test string to time functions", () {
    expect(DateTimeUtils.absoluteTime("2:50"), 170);
    expect(DateTimeUtils.absoluteTime("5点"), 300);
    expect(DateTimeUtils.absoluteTime("5点20"), 320);
    expect(DateTimeUtils.absoluteTime("5点59分"), 359);
    expect(DateTimeUtils.absoluteTime("15点半"), 930);
    expect(DateTimeUtils.absoluteTime("上午2:50"), 170);
    expect(DateTimeUtils.absoluteTime("上午5点"), 300);
    expect(DateTimeUtils.absoluteTime("上午5点20"), 320);
    expect(DateTimeUtils.absoluteTime("上午5点59分"), 359);
    expect(DateTimeUtils.absoluteTime("上午15点半"), 930);
    expect(DateTimeUtils.absoluteTime("下午2:50"), 890);
    expect(DateTimeUtils.absoluteTime("下午5点"), 1020);
    expect(DateTimeUtils.absoluteTime("下午5点20"), 1040);
    expect(DateTimeUtils.absoluteTime("下午5点59分"), 1079);
    expect(DateTimeUtils.absoluteTime("下午3点半"), 930);
  });

  test("Test time", () {

    // Test TimeOption
    expect(TimeOption().toString(), "");
    expect(TimeOption(length: 10).toString(), "");
    expect(TimeOption(start: 10).toString(), "0:10");
    expect(TimeOption(start: 650).toString(), "10:50");
    expect(TimeOption(start: 600, length: 200).toString(), "10:00到13:20");

    // Test FixedTime
    expect(FixedTime(DateTimeUtils.yearMonthDayToInt(2018, 1, 19)).toString(), "2018-1-19");
    expect(FixedTime(DateTimeUtils.yearMonthDayToInt(2018, 1, 19), length: 100).toString(), "2018-1-19");
    expect(FixedTime(DateTimeUtils.yearMonthDayToInt(2018, 1, 19), start: 700).toString(), "2018-1-19 11:40");
    expect(FixedTime(DateTimeUtils.yearMonthDayToInt(2018, 1, 19), start: 700, length: 120).toString(), "2018-1-19 11:40到13:40");

    // Test Period
    expect(Period(PeriodType.everyWeek, 0).toString(), "每周日");
    expect(Period(PeriodType.everyWeek, 6, start: 999).toString(), "每周六16:39");
    expect(Period(PeriodType.everyDay, 1, start: 1001).toString(), "每天16:41");
    expect(Period(PeriodType.everyMonth, 1, start: 1111, length: 111).toString(), "每月1日18:31到20:22");

  });
}
