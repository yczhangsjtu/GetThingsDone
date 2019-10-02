import 'dart:io';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';

import 'time.dart';
import 'date_time_utils.dart';

class GTDCard {
  final String title;
  final List<String> comments;

  static List<GTDCard> get cards {
    _cards = _cards ?? [];
    return _cards;
  }

  static List<GTDCard> _cards;

  GTDCard(this.title, {this.comments});

  String toString() {
    return "$title${CardUtils.listIsNullOrEmpty(comments) ? "" : "\n" + comments.join("\n")}";
  }

  static GTDCard fromString(String s) {
    return InventoryCard.fromString(s) ??
        ActionCard.fromString(s) ??
        BasketCard.fromString(s);
  }

  String serialize() {
    return CardUtils.encodeBase64String(toString());
  }

  static GTDCard deserialize(String s) {
    return fromString(CardUtils.decodeBase64String(s));
  }

  static bool addCard(GTDCard card) {
    if (card == null) {
      return false;
    }
    cards.add(card);
    return true;
  }

  static int findCard(int index, bool Function(GTDCard) tester) {
    int count = -1;
    if (index < 0) {
      return null;
    }
    int i = 0;
    for (; i < cards.length; i++) {
      if (tester(cards[i])) {
        count++;
        if (count == index) {
          break;
        }
      }
    }
    if (count == index) {
      return i;
    }
    return null;
  }

  static int countCard(bool Function(GTDCard) tester) {
    int count = 0;
    int n = cards.length;
    for (int i = 0; i < n; i++) {
      if (tester(cards[i])) {
        count++;
      }
    }
    return count;
  }

  static int findBasketCard(int index) {
    return findCard(index, (card) {
      return card is BasketCard;
    });
  }

  static bool removeBasketCard(int index) {
    int i = findBasketCard(index);
    if (i != null) {
      cards.removeAt(i);
      return true;
    }
    return false;
  }

  static bool updateBasketCard(int index, GTDCard card) {
    int i = findBasketCard(index);
    if (i != null) {
      cards[i] = card;
      return true;
    }
    return false;
  }

  static int countBasketCard() {
    return countCard((card) {
      return card is BasketCard;
    });
  }

  static bool isArrangedActionCard(GTDCard card) {
    return card is ActionCard && card.waiting == null && !card.expired();
  }

  static int findArrangedActionCard(int index) {
    return findCard(index, isArrangedActionCard);
  }

  static bool removeArrangedActionCard(int index) {
    int i = findArrangedActionCard(index);
    if (i != null) {
      cards.removeAt(i);
      return true;
    }
    return false;
  }

  static bool updateArrangedActionCard(int index, GTDCard card) {
    int i = findArrangedActionCard(index);
    if (i != null) {
      cards[i] = card;
      return true;
    }
    return false;
  }

  static bool isWaitingActionCard(GTDCard card) {
    return card is ActionCard && card.waiting != null;
  }

  static int findWaitingActionCard(int index) {
    return findCard(index, isWaitingActionCard);
  }

  static bool removeWaitingActionCard(int index) {
    int i = findWaitingActionCard(index);
    if (i != null) {
      cards.removeAt(i);
      return true;
    }
    return false;
  }

  static bool updateWaitingActionCard(int index, GTDCard card) {
    int i = findWaitingActionCard(index);
    if (i != null) {
      cards[i] = card;
      return true;
    }
    return false;
  }

  static bool isExpiredCard(GTDCard card) {
    return card is ActionCard && card.expired();
  }

  static int findExpiredActionCard(int index) {
    return findCard(index, isExpiredCard);
  }

  static bool removeExpiredActionCard(int index) {
    int i = findExpiredActionCard(index);
    if (i != null) {
      cards.removeAt(i);
      return true;
    }
    return false;
  }

  static bool updateExpiredActionCard(int index, GTDCard card) {
    int i = findExpiredActionCard(index);
    if (i != null) {
      cards[i] = card;
      return true;
    }
    return false;
  }

  static int countTodayCard() {
    return countCard((card) {
      return card is ActionCard &&
          card.timeOptions.any((o) {
            return o.match(DateTimeUtils.today());
          });
    });
  }

  static int countTodayUncompletedCard() {
    return countCard((card) {
      return card is ActionCard &&
          card.timeOptions.any((o) {
            return o.match(DateTimeUtils.today());
          }) && !card.getCompleted(DateTimeUtils.today());
    });
  }

  static int countExpiredActionCard() {
    return countCard(isExpiredCard);
  }

  static int findInventoryCard(int index, Inventory inventory) {
    return findCard(index, (card) {
      return card is InventoryCard && inventory.filterRule.match(card.title);
    });
  }

  static bool removeInventoryCard(int index, Inventory inventory) {
    int i = findInventoryCard(index, inventory);
    if (i != null) {
      cards.removeAt(i);
      return true;
    }
    return false;
  }

  static bool updateInventoryCard(
      int index, Inventory inventory, GTDCard card) {
    int i = findInventoryCard(index, inventory);
    if (i != null) {
      cards[i] = card;
      return true;
    }
    return false;
  }

  static String allCardsToString() {
    return cards
        .map((card) {
          return card.serialize();
        })
        .toList()
        .join("\n");
  }

  static void loadCardsFromString(String s) {
    cards.clear();
    if (CardUtils.stringIsNullOrEmpty(s)) {
      return;
    }
    var lines = s.split("\n");
    for (int i = 0; i < lines.length; i++) {
      var card = GTDCard.deserialize(lines[i]);
      addCard(card);
    }
  }

  static void resetCards() {
    _cards = [];
  }

  static Future loadCards() async {
    try {
      final file = await _localFile;
      var s = await file.readAsString();
      loadCardsFromString(s);
    } catch (e) {
      loadCardsFromString("");
    }
  }

  static saveCards() async {
    final file = await _localFile;
    await file.writeAsString(allCardsToString());
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/cards');
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}

enum Importance {
  extreme,
  high,
  considerable,
  normal,
  none,
}

class CardUtils {
  static String importanceToString(Importance importance) {
    if (importance == Importance.extreme) {
      return "极重要";
    }
    if (importance == Importance.high) {
      return "很重要";
    }
    if (importance == Importance.considerable) {
      return "重要";
    }
    if (importance == Importance.normal) {
      return "一般";
    }
    if (importance == Importance.none) {
      return "不重要";
    }
    return null;
  }

  static Importance importanceFromString(String s) {
    if (s == "极重要") {
      return Importance.extreme;
    }
    if (s == "很重要") {
      return Importance.high;
    }
    if (s == "重要") {
      return Importance.considerable;
    }
    if (s == "一般") {
      return Importance.normal;
    }
    if (s == "不重要") {
      return Importance.none;
    }
    return null;
  }

  static String encodeBase64String(String s) {
    return base64Encode(utf8.encode(s));
  }

  static String decodeBase64String(String s) {
    return utf8.decode(base64Decode(s));
  }

  static bool stringIsNullOrEmpty(dynamic s) {
    return s?.isEmpty ?? true;
  }

  static bool listIsNullOrEmpty(List s) {
    return s?.isEmpty ?? true;
  }
}

class ActionCard extends GTDCard {
  final List<TimeOption> timeOptions;
  final String nextAct;
  final Importance importance;
  final String waiting;

  ActionCard(
    String title, {
    this.timeOptions,
    List<String> comments,
    this.nextAct,
    this.importance = Importance.normal,
    this.waiting,
  })  : assert((!CardUtils.listIsNullOrEmpty(timeOptions) &&
                !timeOptions.any((o) {
                  return o == null;
                })) ||
            !CardUtils.stringIsNullOrEmpty(waiting)),
        assert(importance != null),
        super(title, comments: comments);

  @override
  String toString() {
    StringBuffer stringBuffer = StringBuffer();
    stringBuffer.write(title);
    if (!CardUtils.listIsNullOrEmpty(timeOptions)) {
      stringBuffer.write(
          "\n${timeOptions.map((o) => o.toString()).toList().join("\n")}");
    }
    if (nextAct != null) {
      stringBuffer.write("\n$nextAct");
    }
    if (importance != Importance.normal) {
      stringBuffer.write("\n${CardUtils.importanceToString(importance)}");
    }
    if (waiting != null) {
      stringBuffer.write("\n$waiting");
    }
    if (!CardUtils.listIsNullOrEmpty(comments)) {
      stringBuffer.write("\n${comments.join("\n")}");
    }
    return stringBuffer.toString();
  }

  @override
  String serialize() {
    return CardUtils.encodeBase64String(toString());
  }

  bool expired() {
    return waiting == null && !(timeOptions?.any((timeOption) {
          if (timeOption is Period) {
            return true;
          }
          FixedTime fixedTime = timeOption as FixedTime;
          if (fixedTime.day < DateTimeUtils.today()) {
            return false;
          }
          if (fixedTime.day > DateTimeUtils.today()) {
            return true;
          }
          if (fixedTime.start == null) {
            return true;
          }
          return fixedTime.start + (fixedTime.length ?? 0) >
              DateTimeUtils.now();
        }) ??
        true);
  }

  static Set<String> get completedCards {
    _completedCards = _completedCards ?? Set();
    return _completedCards;
  }

  static Set<String> _completedCards;

  void setCompleted(bool value, int day) {
    if (value) {
      completedCards
          .add("${CardUtils.encodeBase64String(this.title)}:$day");
    } else {
      completedCards
          .remove("${CardUtils.encodeBase64String(this.title)}:$day");
    }
  }

  bool countInCalendar() {
    return this.importance != Importance.none;
  }

  bool getCompleted(int day) {
    return completedCards
        .contains("${CardUtils.encodeBase64String(this.title)}:$day");
  }

  static ActionCard fromString(String s) {
    var lines = s.split("\n");
    String title;
    String waiting;
    String nextAct;
    Importance importance;
    List<TimeOption> timeOptions = <TimeOption>[];
    List<String> comments = <String>[];
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].trim().isNotEmpty) {
        if (title == null) {
          title = lines[i];
          continue;
        }
        var timeOption = TimeOption.fromString(lines[i]);
        if (timeOption != null) {
          timeOptions.add(timeOption);
          continue;
        }
        if (lines[i].startsWith("等待") && waiting == null) {
          waiting = lines[i];
          continue;
        }
        if (lines[i].startsWith("下一步") && nextAct == null) {
          nextAct = lines[i];
          continue;
        }
        if (importance == null) {
          importance = CardUtils.importanceFromString(lines[i]);
          if (importance != null) {
            continue;
          }
        }
        comments.add(lines[i]);
      }
    }
    if (title == null) {
      return null;
    }
    if (waiting != null || timeOptions.isNotEmpty) {
      return ActionCard(title,
          waiting: waiting,
          nextAct: nextAct,
          timeOptions: timeOptions,
          importance: importance ?? Importance.normal,
          comments: comments);
    }
    return null;
  }

  static String allCompletedToString() {
    StringBuffer sb = StringBuffer();
    String today = ":${DateTimeUtils.today()}";
    for(var s in completedCards) {
      if(s.endsWith(today)) {
        sb.write("$s\n");
      }
    }
    return sb.toString();
  }

  static void loadCompletedFromString(String s) {
    String today = ":${DateTimeUtils.today()}";
    s.split("\n").forEach((str) {
      str = str.trim();
      if(str.isEmpty) return;
      if(str.endsWith(today)) {
        completedCards.add(str);
      }
    });
  }


  static void resetCompleted() {
    _completedCards = Set();
  }

  static Future loadCompleted() async {
    try {
      final file = await _localFile;
      var s = await file.readAsString();
      loadCompletedFromString(s);
    } catch (e) {
      loadCompletedFromString("");
    }
  }

  static saveCompleted() async {
    final file = await _localFile;
    await file.writeAsString(allCompletedToString());
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/completed');
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}

class InventoryCard extends GTDCard {
  InventoryCard(String title, {List<String> comments})
      : super(title, comments: comments);

  static InventoryCard fromString(String s) {
    var lines = s.split("\n");
    String title;
    List<String> comments = [];
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].trim().isNotEmpty) {
        if (title == null) {
          if (Inventory.firstMatchingInventory(lines[i]) != null) {
            title = lines[i];
            continue;
          } else {
            return null;
          }
        }
        comments.add(lines[i]);
      }
    }
    if (title == null) {
      return null;
    }
    return InventoryCard(title, comments: comments);
  }
}

class BasketCard extends GTDCard {
  BasketCard(String title, {List<String> comments})
      : super(title, comments: comments);

  static BasketCard fromString(String s) {
    var lines = s.split("\n");
    String title;
    List<String> comments = [];
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].trim().isNotEmpty) {
        if (title == null) {
          title = lines[i];
          continue;
        }
        comments.add(lines[i]);
      }
    }
    if (title == null) {
      return null;
    }
    return BasketCard(title, comments: comments);
  }
}

class FilterRule {
  final List<String> beginWithOptions;
  final List<String> endWithOptions;
  final bool relationIsOr;

  FilterRule(
      {this.beginWithOptions, this.endWithOptions, this.relationIsOr = false})

      // For beginWithOptions and endWithOptions, they should not contain any
      // empty string; they can be empty lists, though
      : assert(CardUtils.listIsNullOrEmpty(beginWithOptions) ||
            !beginWithOptions.any(CardUtils.stringIsNullOrEmpty)),
        assert(CardUtils.listIsNullOrEmpty(endWithOptions) ||
            !endWithOptions.any(CardUtils.stringIsNullOrEmpty)),
        assert(relationIsOr != null);

  bool match(String s) {
    if (CardUtils.stringIsNullOrEmpty(s)) {
      return false;
    }
    bool beginWithMatch = CardUtils.listIsNullOrEmpty(beginWithOptions)
        ? null
        : beginWithOptions.any(s.startsWith);
    bool endWithMatch = CardUtils.listIsNullOrEmpty(endWithOptions)
        ? null
        : endWithOptions.any(s.endsWith);
    if (beginWithMatch == null) {
      return endWithMatch ?? false;
    }
    if (endWithMatch == null) {
      return beginWithMatch;
    }
    return relationIsOr
        ? beginWithMatch || endWithMatch
        : beginWithMatch && endWithMatch;
  }

  String serialize() {
    return (beginWithOptions == null
            ? ""
            : beginWithOptions.map(CardUtils.encodeBase64String).join(",")) +
        ";" +
        (endWithOptions == null
            ? ""
            : endWithOptions.map(CardUtils.encodeBase64String).join(",")) +
        ";" +
        (relationIsOr ? "0" : "1");
  }

  static FilterRule deserialize(String s) {
    var list = s.split(";");
    if (list.length != 3) {
      return null;
    }
    var beginWithStr = list[0];
    var endWithStr = list[1];
    var relationStr = list[2];
    var relationIsOr =
        relationStr == "0" ? true : (relationStr == "1" ? false : null);
    if (relationIsOr == null) {
      return null;
    }
    var beginWithOptions = beginWithStr.isEmpty
        ? null
        : beginWithStr.split(",").map(CardUtils.decodeBase64String).toList();
    if (beginWithOptions?.any(CardUtils.stringIsNullOrEmpty) ?? false) {
      return null;
    }
    var endWithOptions = endWithStr.isEmpty
        ? null
        : endWithStr.split(",").map(CardUtils.decodeBase64String).toList();
    if (endWithOptions?.any(CardUtils.stringIsNullOrEmpty) ?? false) {
      return null;
    }
    return FilterRule(
        beginWithOptions: beginWithOptions,
        endWithOptions: endWithOptions,
        relationIsOr: relationIsOr);
  }
}

class Inventory {
  String name;
  FilterRule filterRule;

  Inventory(this.name, this.filterRule)
      : assert(!CardUtils.stringIsNullOrEmpty(name)),
        assert(filterRule != null);

  String serialize() {
    return CardUtils.encodeBase64String(name) +
        ";" +
        this.filterRule.serialize();
  }

  static Inventory deserialize(String s) {
    int split = s.indexOf(";");
    if (split == -1) {
      return null;
    }
    FilterRule filterRule = FilterRule.deserialize(s.substring(split + 1));
    if (filterRule == null) {
      return null;
    }
    String name = CardUtils.decodeBase64String(s.substring(0, split));
    if (name == null) {
      return null;
    }
    return Inventory(name, filterRule);
  }

  static List<Inventory> get inventories {
    _inventories = _inventories ?? [];
    return _inventories;
  }

  static List<Inventory> _inventories;

  static int firstMatchingInventory(String s) {
    if (CardUtils.stringIsNullOrEmpty(s)) {
      return null;
    }
    for (int i = 0; i < inventories.length; i++) {
      if (inventories[i].filterRule.match(s)) {
        return i;
      }
    }
    return null;
  }

  static bool addInventory(String name) {
    if (CardUtils.stringIsNullOrEmpty(name)) {
      return false;
    }
    for (int i = 0; i < inventories.length; i++) {
      if (inventories[i].name == name) {
        return false;
      }
    }
    Inventory inventory = Inventory(name, FilterRule());
    inventories.add(inventory);

    return true;
  }

  static bool addInventoryAndApply(Inventory inventory) {
    if (inventory == null) {
      return false;
    }
    if (!addInventory(inventory.name)) {
      return false;
    }
    if (!updateInventoryFilter(inventories.length - 1, inventory.filterRule)) {
      return false;
    }
    return true;
  }

  static bool removeInventory(int index) {
    if (!updateInventoryFilter(index, FilterRule())) {
      return false;
    }
    inventories.removeAt(index);
    return true;
  }

  static bool updateInventoryFilter(int index, FilterRule filterRule) {
    if (index < 0 || index >= inventories.length) {
      return false;
    }
    Inventory inventory = inventories[index];
    List<int> cardsToUpdate = [];
    for (int i = 0; i < GTDCard.cards.length; i++) {
      GTDCard card = GTDCard.cards[i];
      if ((card is InventoryCard &&
              inventory.filterRule.match(card.title) &&
              !filterRule.match(card.title)) ||
          filterRule.match(card.title)) {
        cardsToUpdate.add(i);
      }
    }
    inventory.filterRule = filterRule;
    for (int i = 0; i < cardsToUpdate.length; i++) {
      GTDCard card = GTDCard.cards[cardsToUpdate[i]];
      GTDCard.cards[cardsToUpdate[i]] = GTDCard.fromString(card.toString());
    }
    return true;
  }

  static int findInventory(String name) {
    if (CardUtils.stringIsNullOrEmpty(name)) {
      return null;
    }
    for (int i = 0; i < inventories.length; i++) {
      if (inventories[i].name == name) {
        return i;
      }
    }
    return null;
  }

  static String allInventoriesToString() {
    return inventories
        .map((inventory) {
          return inventory.serialize();
        })
        .toList()
        .join("\n");
  }

  static void loadInventoriesFromString(String s) {
    inventories.clear();
    if (CardUtils.stringIsNullOrEmpty(s)) {
      return;
    }
    var lines = s.split("\n");
    for (int i = 0; i < lines.length; i++) {
      var inventory = Inventory.deserialize(lines[i]);
      addInventoryAndApply(inventory);
    }
  }

  static void resetInventories() {
    inventories.clear();
  }

  static Future loadInventories() async {
    try {
      final file = await _localFile;
      var s = await file.readAsString();
      loadInventoriesFromString(s);
    } catch (e) {
      loadInventoriesFromString("");
    }
  }

  static saveInventories() async {
    final file = await _localFile;
    await file.writeAsString(allInventoriesToString());
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/inventories');
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}
