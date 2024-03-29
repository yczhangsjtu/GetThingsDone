import 'date_time_utils.dart';

abstract class TimeOption extends TimeInterval {
  TimeOption({int start, int length}) : super(start: start, length: length);

  static TimeOption fromString(String s) {
    return FixedTime.fromString(s) ?? Period.fromString(s);
  }

  bool match(int dayOfInterest);
}

class FixedTime extends TimeOption {
  final int day;

  FixedTime(this.day, {int start, int length})
      : assert(day != null),
        super(start: start, length: length);

  @override
  String toString() {
    String time = super.toString();
    return DateTimeUtils.dayToString(day) + (time == "" ? "" : " $time");
  }

  static final fixedTimeExp = RegExp(r"^(" + // start group 1
      DateTimeUtils.relativeDayPattern +
      "|" +
      DateTimeUtils.relativeWeekDayPattern + // 2 groups
      "|" +
      DateTimeUtils.monthDayPattern + // 2 groups
      "|" +
      DateTimeUtils.yearMonthDayPattern + // 3 groups
      r")?\s*(" + // end group 1, start group 9
      DateTimeUtils.timeIntervalPattern +
      "|" +
      DateTimeUtils.hourMinutePattern +
      r")?\s*$");

  static FixedTime fromString(String s) {
    var match = fixedTimeExp.firstMatch(s);
    if (match == null) {
      return null;
    }
    var dateStr = match.group(1);
    var timeStr = match.group(9);
    if (dateStr == null && timeStr == null) {
      return null;
    }
    var day = DateTimeUtils.absoluteDateToday(dateStr);
    if(timeStr == null) {
      return FixedTime(day);
    }
    var absoluteTime = DateTimeUtils.absoluteTime(timeStr);
    if (absoluteTime != null) {
      return FixedTime(day ?? DateTimeUtils.today(), start: absoluteTime);
    }
    var timeInterval = DateTimeUtils.absoluteTimeInterval(timeStr);
    if (timeInterval != null) {
      return FixedTime(day ?? DateTimeUtils.today(),
          start: timeInterval?.start, length: timeInterval?.length);
    }
    assert(false);
    return null;
  }

  @override
  bool match(int dayOfInterest) {
    return day == dayOfInterest;
  }

}

enum PeriodType {
  everyDay,
  everyWeek,
  everyMonth,
}

class Period extends TimeOption {
  final PeriodType periodType;
  final int day;

  Period(this.periodType, this.day, {int start, int length})
      : assert(periodType != PeriodType.everyWeek || (day >= 0 && day <= 6)),
        super(start: start, length: length);

  @override
  String toString() {
    String time = super.toString();
    switch (periodType) {
      case PeriodType.everyDay:
        return "每天$time";
      case PeriodType.everyWeek:
        return "每周${DateTimeUtils.weekDayName(day)}$time";
      case PeriodType.everyMonth:
        return "每月$day日$time";
    }
    return "";
  }

  static final periodExp = RegExp(
      r"^每(天|日|周(日|一|二|三|四|五|六)|月([1-3]?[0-9])(?:日|号)?)\s*(" + // 3 groups, start group 4
          DateTimeUtils.timeIntervalPattern +
          "|" +
          DateTimeUtils.hourMinutePattern +
          r")?\s*$");

  static Period fromString(String s) {
    var match = periodExp.firstMatch(s);
    if (match == null) {
      return null;
    }
    var dateStr = match.group(1);
    var timeStr = match.group(4);
    var dayStr = match.group(3);
    var timeInterval = timeStr == null
        ? TimeInterval()
        : DateTimeUtils.absoluteTimeInterval(timeStr);
    if (timeInterval == null) {
      return null;
    }
    var periodType = PeriodType.everyDay;
    var day = 0;
    if (dateStr.startsWith("周")) {
      periodType = PeriodType.everyWeek;
      day = DateTimeUtils.dayOfWeekByName(dateStr[1]);
      assert(day != null);
    } else if (dateStr.startsWith("月")) {
      periodType = PeriodType.everyMonth;
      day = int.parse(dayStr);
      assert(day != null);
      if (day < 1 || day > 31) {
        return null;
      }
    }
    return Period(periodType, day,
        start: timeInterval.start, length: timeInterval.length);
  }

  @override
  bool match(int dayOfInterest) {
    if(periodType == PeriodType.everyDay) {
      return true;
    }
    if(periodType == PeriodType.everyWeek) {
      return DateTimeUtils.dayOfWeek(dayOfInterest) == day;
    }
    if(periodType == PeriodType.everyMonth) {
      return DateTimeUtils.yearMonthDayFromInt(dayOfInterest) % 100 == day;
    }
    return false;
  }
}
