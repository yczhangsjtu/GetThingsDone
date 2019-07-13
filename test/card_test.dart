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

    // Test Importance
    expect(CardUtils.importanceToString(Importance.extreme), "极重要");
    expect(CardUtils.importanceToString(Importance.high), "很重要");
    expect(CardUtils.importanceToString(Importance.considerable), "重要");
    expect(CardUtils.importanceToString(Importance.normal), "一般");
    expect(CardUtils.importanceToString(Importance.none), "不重要");
    expect(CardUtils.importanceFromString("极重要"), Importance.extreme);
    expect(CardUtils.importanceFromString("很重要"), Importance.high);
    expect(CardUtils.importanceFromString("重要"), Importance.considerable);
    expect(CardUtils.importanceFromString("一般"), Importance.normal);
    expect(CardUtils.importanceFromString("不重要"), Importance.none);

    // Test Base64 Encode and Decode
    expect(CardUtils.decodeBase64String(CardUtils.encodeBase64String("")), "");
    expect(CardUtils.decodeBase64String(CardUtils.encodeBase64String("a")), "a");
    expect(CardUtils.decodeBase64String(CardUtils.encodeBase64String("中文")), "中文");
    expect(CardUtils.decodeBase64String(CardUtils.encodeBase64String("中文\nabc")), "中文\nabc");

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
    expect(FilterRule.deserialize(FilterRule().serialize()).match(""), false);
    expect(FilterRule.deserialize(FilterRule().serialize()).match("看书《白鹿原》"), false);
    expect(FilterRule.deserialize(FilterRule(beginWithOptions: ["看书"]).serialize()).match("看书《白鹿原》"), true);
    expect(FilterRule.deserialize(FilterRule(beginWithOptions: ["看书《"]).serialize()).match("看书《白鹿原》"), true);
    expect(FilterRule.deserialize(FilterRule(beginWithOptions: ["《"]).serialize()).match("看书《白鹿原》"), false);
    expect(FilterRule.deserialize(FilterRule(endWithOptions: ["》"]).serialize()).match("看书《白鹿原》"), true);
    expect(FilterRule.deserialize(FilterRule(endWithOptions: ["》书"]).serialize()).match("看书《白鹿原》"), false);
    expect(FilterRule.deserialize(FilterRule(beginWithOptions: ["《"], endWithOptions: ["》"]).serialize()).match("看书《白鹿原》"), false);
    expect(FilterRule.deserialize(FilterRule(beginWithOptions: ["《"], endWithOptions: ["》"], relationIsOr: false).serialize()).match("看书《白鹿原》"), false);
    expect(FilterRule.deserialize(FilterRule(beginWithOptions: ["《"], endWithOptions: ["》"], relationIsOr: true).serialize()).match("看书《白鹿原》"), true);
    expect(FilterRule.deserialize(FilterRule(beginWithOptions: ["看书《"], endWithOptions: ["》"], relationIsOr: false).serialize()).match("看书《白鹿原》"), true);
    expect(FilterRule.deserialize(FilterRule(beginWithOptions: ["看书《"], endWithOptions: ["》"], relationIsOr: true).serialize()).match("看书《白鹿原》"), true);
    expect(FilterRule.deserialize(FilterRule(beginWithOptions: ["《", "看书《"], endWithOptions: ["》"], relationIsOr: true).serialize()).match("看书《白鹿原》"), true);

  });
}
