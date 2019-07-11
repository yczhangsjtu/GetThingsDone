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
  })  : assert(timeOptions?.isNotEmpty ?? false),
        assert(!timeOptions.any((o) {
          return o == null;
        })),
        assert(importance != null),
        super(id, title, comments: comments);

  @override
  String toString() {
    StringBuffer stringBuffer = StringBuffer();
    stringBuffer.write(title);
    stringBuffer
        .write("\n${timeOptions.map((o) => o.toString()).toList().join("\n")}");
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

