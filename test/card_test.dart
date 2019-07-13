import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_gtd/core/time.dart';
import 'package:flutter_gtd/core/date_time_utils.dart';
import 'package:flutter_gtd/core/card.dart';

void main() {
  test("Test card creation and toString", () {
    // Test Card toString
    expect(GTDCard("看书《白鹿原》").toString(), "看书《白鹿原》");
    expect(GTDCard("看书《白鹿原》", comments: []).toString(), "看书《白鹿原》");
    expect(GTDCard("洗衣服", comments: ["周日"]).toString(), "洗衣服\n周日");
    expect(GTDCard("洗澡", comments: ["周日下午6点", "重要"]).toString(), "洗澡\n周日下午6点\n重要");

    // Test ActionCard toString
    expect(
        ActionCard("看书《白鹿原》", timeOptions: [
          FixedTime(DateTimeUtils.yearMonthDayToInt(2019, 7, 11),
              start: 17 * 60)
        ]).toString(),
        "看书《白鹿原》\n2019-7-11 17:00");
    expect(ActionCard("看书《白鹿原》", waiting: "等待买到《白鹿原》这本书").toString(),
        "看书《白鹿原》\n等待买到《白鹿原》这本书");
  });

  test("Test util functions", () {
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
    expect(
        CardUtils.decodeBase64String(CardUtils.encodeBase64String("a")), "a");
    expect(
        CardUtils.decodeBase64String(CardUtils.encodeBase64String("中文")), "中文");
    expect(
        CardUtils.decodeBase64String(CardUtils.encodeBase64String("中文\nabc")),
        "中文\nabc");
  });

  test("Test filter rules and inventories", () {
    // Test Filter Rule
    expect(FilterRule().match(""), false);
    expect(FilterRule().match("看书《白鹿原》"), false);
    expect(FilterRule(beginWithOptions: ["看书"]).match("看书《白鹿原》"), true);
    expect(FilterRule(beginWithOptions: ["看书《"]).match("看书《白鹿原》"), true);
    expect(FilterRule(beginWithOptions: ["《"]).match("看书《白鹿原》"), false);
    expect(FilterRule(endWithOptions: ["》"]).match("看书《白鹿原》"), true);
    expect(FilterRule(endWithOptions: ["》书"]).match("看书《白鹿原》"), false);
    expect(
        FilterRule(beginWithOptions: ["《"], endWithOptions: ["》"])
            .match("看书《白鹿原》"),
        false);
    expect(
        FilterRule(
                beginWithOptions: ["《"],
                endWithOptions: ["》"],
                relationIsOr: false)
            .match("看书《白鹿原》"),
        false);
    expect(
        FilterRule(
                beginWithOptions: ["《"],
                endWithOptions: ["》"],
                relationIsOr: true)
            .match("看书《白鹿原》"),
        true);
    expect(
        FilterRule(
                beginWithOptions: ["看书《"],
                endWithOptions: ["》"],
                relationIsOr: false)
            .match("看书《白鹿原》"),
        true);
    expect(
        FilterRule(
                beginWithOptions: ["看书《"],
                endWithOptions: ["》"],
                relationIsOr: true)
            .match("看书《白鹿原》"),
        true);
    expect(FilterRule.deserialize(FilterRule().serialize()).match(""), false);
    expect(FilterRule.deserialize(FilterRule().serialize()).match("看书《白鹿原》"),
        false);
    expect(
        FilterRule.deserialize(FilterRule(beginWithOptions: ["看书"]).serialize())
            .match("看书《白鹿原》"),
        true);
    expect(
        FilterRule.deserialize(
                FilterRule(beginWithOptions: ["看书《"]).serialize())
            .match("看书《白鹿原》"),
        true);
    expect(
        FilterRule.deserialize(FilterRule(beginWithOptions: ["《"]).serialize())
            .match("看书《白鹿原》"),
        false);
    expect(
        FilterRule.deserialize(FilterRule(endWithOptions: ["》"]).serialize())
            .match("看书《白鹿原》"),
        true);
    expect(
        FilterRule.deserialize(FilterRule(endWithOptions: ["》书"]).serialize())
            .match("看书《白鹿原》"),
        false);
    expect(
        FilterRule.deserialize(
                FilterRule(beginWithOptions: ["《"], endWithOptions: ["》"])
                    .serialize())
            .match("看书《白鹿原》"),
        false);
    expect(
        FilterRule.deserialize(FilterRule(
                    beginWithOptions: ["《"],
                    endWithOptions: ["》"],
                    relationIsOr: false)
                .serialize())
            .match("看书《白鹿原》"),
        false);
    expect(
        FilterRule.deserialize(FilterRule(
                    beginWithOptions: ["《"],
                    endWithOptions: ["》"],
                    relationIsOr: true)
                .serialize())
            .match("看书《白鹿原》"),
        true);
    expect(
        FilterRule.deserialize(FilterRule(
                    beginWithOptions: ["看书《"],
                    endWithOptions: ["》"],
                    relationIsOr: false)
                .serialize())
            .match("看书《白鹿原》"),
        true);
    expect(
        FilterRule.deserialize(FilterRule(
                    beginWithOptions: ["看书《"],
                    endWithOptions: ["》"],
                    relationIsOr: true)
                .serialize())
            .match("看书《白鹿原》"),
        true);
    expect(
        FilterRule.deserialize(FilterRule(
                    beginWithOptions: ["《", "看书《"],
                    endWithOptions: ["》"],
                    relationIsOr: true)
                .serialize())
            .match("看书《白鹿原》"),
        true);

    // Test Inventories
    Inventory.inventories = <Inventory>[
      Inventory(
          "书单",
          FilterRule(
              beginWithOptions: ["看书《", "《"],
              endWithOptions: ["》"],
              relationIsOr: false)),
    ];
    expect(Inventory.addInventory(""), false);
    expect(Inventory.inventories.length, 1);
    expect(Inventory.addInventory("购物"), true);
    expect(Inventory.inventories.length, 2);
    expect(Inventory.addInventory("购物"), false);
    expect(Inventory.inventories.length, 2);
    expect(Inventory.addInventory("游泳"), true);
    expect(Inventory.inventories.length, 3);
    int index = Inventory.findInventory("");
    expect(index, null);
    index = Inventory.findInventory("看书");
    expect(index, null);
    index = Inventory.findInventory("购物");
    expect(index, 1);
    var inventory = Inventory.inventories[index];
    inventory.filterRule = FilterRule(beginWithOptions: ["买"]);
    index = Inventory.findInventory("游泳");
    expect(index, 2);
    inventory = Inventory.inventories[index];
    inventory.filterRule = FilterRule(beginWithOptions: ["游泳要带"]);
    expect(Inventory.firstMatchingInventory("看书《白鹿原》"), 0);
    expect(Inventory.firstMatchingInventory("买书《白鹿原》"), 1);
    expect(Inventory.firstMatchingInventory("游泳要带泳衣"), 2);
    expect(Inventory.firstMatchingInventory("要买衣服"), null);
  });

  test("Test inventory update", () {
    GTDCard.resetCards();
    Inventory.inventories = <Inventory>[
      Inventory(
          "书单",
          FilterRule(
              beginWithOptions: ["看书《", "《"],
              endWithOptions: ["》"],
              relationIsOr: false)),
    ];
    expect(Inventory.addInventory("购物"), true);
    expect(Inventory.addInventory("游泳"), true);
    expect(GTDCard.addCard(GTDCard.fromString("洗衣服\n周日")), true);
    expect(GTDCard.addCard(ActionCard.fromString("洗澡\n周日下午6点\n重要")), true);
    expect(GTDCard.addCard(GTDCard.fromString("看书《白鹿原》\n7月11日 下午5点")), true);
    expect(GTDCard.addCard(GTDCard.fromString("看书《白鹿原》\n等待买到《白鹿原》这本书")), true);
    expect(GTDCard.addCard(GTDCard.fromString("书《白鹿原》")), true);
    expect(GTDCard.cards[0] is ActionCard, true);
    expect(GTDCard.cards[1] is ActionCard, true);
    expect(GTDCard.cards[2] is InventoryCard, true);
    expect(GTDCard.cards[3] is InventoryCard, true);
    expect(GTDCard.cards[4] is BasketCard, true);
    int index = Inventory.findInventory("书单");
    Inventory.updateInventoryFilter(
        index,
        FilterRule(
            beginWithOptions: ["书《", "《"],
            endWithOptions: ["》"],
            relationIsOr: false));
    expect(GTDCard.cards[0] is ActionCard, true);
    expect(GTDCard.cards[1] is ActionCard, true);
    expect(GTDCard.cards[2] is ActionCard, true);
    expect(GTDCard.cards[3] is ActionCard, true);
    expect(GTDCard.cards[4] is InventoryCard, true);
  });

  test("Test card serialization and deserialization", () {
    Inventory.inventories = <Inventory>[
      Inventory(
          "书单",
          FilterRule(
              beginWithOptions: ["看书《", "《"],
              endWithOptions: ["》"],
              relationIsOr: false)),
    ];
    expect(Inventory.addInventory("购物"), true);
    expect(Inventory.addInventory("游泳"), true);
    int index = Inventory.findInventory("购物");
    var inventory = Inventory.inventories[index];
    inventory.filterRule = FilterRule(beginWithOptions: ["买"]);
    index = Inventory.findInventory("游泳");
    inventory = Inventory.inventories[index];
    inventory.filterRule = FilterRule(beginWithOptions: ["游泳要带"]);
    var card = GTDCard.fromString("看书《白鹿原》");
    expect(card.serialize(), GTDCard.deserialize(card.serialize()).serialize());
    card = GTDCard.fromString("洗衣服\n周日");
    expect(card is ActionCard, true);
    expect(GTDCard.deserialize(card.serialize()) is ActionCard, true);
    expect(card.serialize(), GTDCard.deserialize(card.serialize()).serialize());
    card = GTDCard.fromString("洗澡\n2019-7-14 18:00\n重要");
    expect(card is ActionCard, true);
    expect(GTDCard.deserialize(card.serialize()) is ActionCard, true);
    expect(card.serialize(), GTDCard.deserialize(card.serialize()).serialize());
    card = GTDCard.fromString("洗澡\n周日下午6点\n重要");
    expect(card is ActionCard, true);
    expect(GTDCard.deserialize(card.serialize()) is ActionCard, true);
    expect(card.serialize(), GTDCard.deserialize(card.serialize()).serialize());
    card = GTDCard.fromString("看书《白鹿原》\n7月11日 下午5点");
    expect(card is InventoryCard, true);
    expect(GTDCard.deserialize(card.serialize()) is InventoryCard, true);
    expect(card.serialize(), GTDCard.deserialize(card.serialize()).serialize());
    card = GTDCard.fromString("看书《白鹿原》\n等待买到《白鹿原》这本书");
    expect(card is InventoryCard, true);
    expect(GTDCard.deserialize(card.serialize()) is InventoryCard, true);
    expect(card.serialize(), GTDCard.deserialize(card.serialize()).serialize());
  });

  test("Test load and save", () async {
    GTDCard.resetCards();
    Inventory.inventories = null;
    expect(GTDCard.addCard(GTDCard.fromString("洗衣服\n周日")), true);
    expect(GTDCard.addCard(ActionCard.fromString("洗澡\n周日下午6点\n重要")), true);
    expect(GTDCard.addCard(GTDCard.fromString("看书《白鹿原》\n7月11日 下午5点")), true);
    expect(GTDCard.addCard(GTDCard.fromString("看书《白鹿原》\n等待买到《白鹿原》这本书")), true);
    var s = GTDCard.allCardsToString();
    GTDCard.resetCards();
    GTDCard.loadCardsFromString(s);
    expect(GTDCard.cards != null, true);
    expect(GTDCard.cards[0].title, "洗衣服");
    expect(GTDCard.cards[1].title, "洗澡");
    expect((GTDCard.cards[1] as ActionCard).importance, Importance.considerable);
    expect(GTDCard.cards[2].title, "看书《白鹿原》");
    expect(GTDCard.cards[3].title, "看书《白鹿原》");
    expect((GTDCard.cards[3] as ActionCard).waiting, "等待买到《白鹿原》这本书");
  });
}
