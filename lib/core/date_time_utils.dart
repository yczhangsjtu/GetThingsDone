class DateTimeUtils {

  static final weekDayNames = <String>["日", "一", "二", "三", "四", "五", "六"];

  static String weekDayName(int day) {
    return weekDayNames[day];
  }

  static int today() {
    var today = DateTime.now();
    return _gregorianToJulian(today.year, today.month, today.day);
  }

  static String durationToString(int minutes) {
    if(minutes == 0) {
      return "0m";
    }
    var h = minutes ~/ 60;
    var m = minutes % 60;
    // If m is 0, omit the minutes part
    return "${h > 0 ? "${h}h" : ""}${m > 0 ? "${m}m" : ""}";
  }

  static String timeToString(int time) {
    var h = time ~/ 60;
    var m = time % 60;
    return "$h:${m~/10}${m%10}";
  }

  static String dayToString(int day) {
    var gregorian = _julianToGregorian(day);
    var y = gregorian ~/ 10000;
    var m = (gregorian % 10000) ~/ 100;
    var d = gregorian % 100;
    return "$y-$m-$d";
  }

  static int yearMonthDayToInt(int y, int m, int d) {
    return _gregorianToJulian(y, m, d);
  }

  static int yearMonthDayFromInt(int day) {
    return _julianToGregorian(day);
  }

  // Refer to http://www.stiltner.org/book/bookcalc.htm for gregorian
  // and julian date
  static int _gregorianToJulian(int y, int m, int d) {
    return ( 1461 * ( y + 4800 + ( m - 14 ) ~/ 12 ) ) ~/ 4 +
        ( 367 * ( m - 2 - 12 * ( ( m - 14 ) ~/ 12 ) ) ) ~/ 12 -
        ( 3 * ( ( y + 4900 + ( m - 14 ) ~/ 12 ) / 100 ) ) ~/ 4 +
        d - 32075;
  }

  static int _julianToGregorian(int jd) {
    var l = jd + 68569;
    var n = ( 4 * l ) ~/ 146097;
    l = l - ( 146097 * n + 3 ) ~/ 4;
    var i = ( 4000 * ( l + 1 ) ) ~/ 1461001;
    l = l - ( 1461 * i ) ~/ 4 + 31;
    var j = ( 80 * l ) ~/ 2447;
    var d = l - ( 2447 * j ) ~/ 80;
    l = j ~/ 11;
    var m = j + 2 - ( 12 * l );
    var y = 100 * ( n - 49 ) + i + l;
    return y * 10000 + m * 100 + d;
  }

}