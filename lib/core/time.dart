import 'date_time_utils.dart';

class TimeOption {
  final int start;
  final int length;

  TimeOption({this.start, this.length});

  String toString() {
    return start == null
        ? ""
        : DateTimeUtils.timeToString(start) +
            (length == null
                ? ""
                : "到${DateTimeUtils.timeToString(start + length)}");
  }
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
}
