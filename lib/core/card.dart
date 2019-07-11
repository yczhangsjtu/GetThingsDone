import 'time.dart';

class Card {
  final int id;
  final String title;
  final List<String> comments;

  Card(this.id, this.title, {this.comments});

  String toString() {
    return "$title${comments?.isEmpty ?? true ? "" : "\n" + comments.join("\n")}";
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
  })  : assert(((timeOptions?.isNotEmpty ?? false) &&
                !timeOptions.any((o) {
                  return o == null;
                })) ||
            (waiting?.isNotEmpty ?? false)),
        assert(importance != null),
        super(id, title, comments: comments);

  @override
  String toString() {
    StringBuffer stringBuffer = StringBuffer();
    stringBuffer.write(title);
    if (timeOptions?.isNotEmpty ?? false) {
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
    if (comments?.isNotEmpty ?? false) {
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
      : assert((beginWithOptions?.isEmpty ?? true) ||
            beginWithOptions.any((s) {
              return s?.isNotEmpty ?? false;
            })),
        assert((endWithOptions?.isEmpty ?? true) ||
            endWithOptions.any((s) {
              return s?.isNotEmpty ?? false;
            })),
        assert(relationIsOr != null);

  bool match(String s) {
    if (s?.isEmpty ?? true) {
      return false;
    }
    bool beginWithMatch = (beginWithOptions?.isEmpty ?? true)
        ? null
        : beginWithOptions.any((start) {
            return s.startsWith(start);
          });
    bool endWithMatch = (endWithOptions?.isEmpty ?? true)
        ? null
        : endWithOptions.any((end) {
            return s.endsWith(end);
          });
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
}
