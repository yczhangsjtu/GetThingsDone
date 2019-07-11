import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_gtd/core/time.dart';
import 'package:flutter_gtd/core/date_time_utils.dart';
import 'package:flutter_gtd/core/card.dart';

void main() {
  test("Test card creation and toString", () {
    // Test Card toString
    expect(Card(0, "看书《白鹿原》").toString(), "看书《白鹿原》");
    expect(Card(0, "看书《白鹿原》", comments: []).toString(), "看书《白鹿原》");
    expect(Card(1, "洗衣服", comments: ["周日"]).toString(), "洗衣服\n周日");
    expect(
        Card(2, "洗澡", comments: ["周日下午6点", "重要"]).toString(), "洗澡\n周日下午6点\n重要");

    // Test ActionCard toString
    expect(
        ActionCard(0, "看书《白鹿原》", timeOptions: [
          FixedTime(DateTimeUtils.yearMonthDayToInt(2019, 7, 11),
              start: 17 * 60)
        ]).toString(),
        "看书《白鹿原》\n2019-7-11 17:00");
    expect(ActionCard(0, "看书《白鹿原》", waiting: "等待买到《白鹿原》这本书").toString(),
        "看书《白鹿原》\n等待买到《白鹿原》这本书");
    
    // Test Filter Rule
    expect(FilterRule().match(""), false);
    expect(FilterRule().match("看书《白鹿原》"), false);
    expect(FilterRule(beginWithOptions: ["看书"]).match("看书《白鹿原》"), true);
    expect(FilterRule(beginWithOptions: ["看书《"]).match("看书《白鹿原》"), true);
    expect(FilterRule(beginWithOptions: ["《"]).match("看书《白鹿原》"), false);
    expect(FilterRule(endWithOptions: ["》"]).match("看书《白鹿原》"), true);
    expect(FilterRule(endWithOptions: ["》书"]).match("看书《白鹿原》"), false);
    expect(FilterRule(beginWithOptions: ["《"], endWithOptions: ["》"]).match("看书《白鹿原》"), false);
    expect(FilterRule(beginWithOptions: ["《"], endWithOptions: ["》"], relationIsOr: false).match("看书《白鹿原》"), false);
    expect(FilterRule(beginWithOptions: ["《"], endWithOptions: ["》"], relationIsOr: true).match("看书《白鹿原》"), true);
    expect(FilterRule(beginWithOptions: ["看书《"], endWithOptions: ["》"], relationIsOr: false).match("看书《白鹿原》"), true);
    expect(FilterRule(beginWithOptions: ["看书《"], endWithOptions: ["》"], relationIsOr: true).match("看书《白鹿原》"), true);
  });
}
