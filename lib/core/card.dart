import 'dart:convert';
import 'time.dart';

class Card {
  final int id;
  final String title;
  final List<String> comments;

  Card(this.id, this.title, {this.comments});

  String toString() {
    return "$title${CardUtils.listIsNullOrEmpty(comments) ? "" : "\n" + comments.join("\n")}";
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
  static importanceToString(Importance importance) {
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

  static importanceFromString(String s) {
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

class ActionCard extends Card {
  final List<TimeOption> timeOptions;
  final String nextAct;
  final Importance importance;
  final String waiting;

  ActionCard(
    int id,
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
        super(id, title, comments: comments);

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
}

class InventoryCard extends Card {
  InventoryCard(int id, String title, {List<String> comments})
      : super(id, title, comments: comments);
}

class BasketCard extends Card {
  BasketCard(int id, String title, {List<String> comments})
      : super(id, title, comments: comments);
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
  final List<int> cards;

  Inventory(this.name, this.filterRule, this.cards)
      : assert(!CardUtils.stringIsNullOrEmpty(name)),
        assert(cards != null);

  static List<Inventory> inventories;
}
