import 'package:flutter/material.dart';
import 'package:flutter_gtd/core/card.dart';

final Color kBasketCardColor = Colors.amberAccent;
final Color kEditCardDialogColor = Colors.amberAccent;
final Color kActiveTabColor = Colors.blue[100];
final Color kInactiveTabColor = Colors.deepPurple[100];
final Color kInventoryCardColor = Colors.lightBlue[100];

final TextStyle kCardTitleStyle = TextStyle(
  fontSize: 18,
  color: Colors.black,
  fontWeight: FontWeight.w700,
);

final TextStyle kCommentStyle = TextStyle(
  fontSize: 16,
  color: Colors.black38,
);

final TextStyle kTimeOptionStyle = TextStyle(
  fontSize: 16,
  color: Colors.black45,
  fontWeight: FontWeight.bold,
  fontFamily: "Courier New",
);

final TextStyle kWaitingStyle = TextStyle(
  fontSize: 16,
  color: Colors.black38,
);

final TextStyle kNextActionStyle = TextStyle(
  fontSize: 16,
  color: Colors.black38,
);

final TextStyle kEditCardDialogStyle = TextStyle(
  color: Colors.black,
  fontSize: 24,
);

final TextStyle kFlatButtonStyle = TextStyle(
  color: Colors.blue,
  fontSize: 24,
);

final TextStyle kBottomSheetStyle = TextStyle(
  color: Colors.cyanAccent,
  fontSize: 18,
);

final TextStyle kActiveTabStyle = TextStyle(
  color: Colors.black,
  fontSize: 18,
);

final TextStyle kInactiveTabStyle = TextStyle(
  color: Colors.white,
  fontSize: 18,
);

final TextStyle kCalendarDateStyle = TextStyle(
  color: Colors.black,
  fontSize: 24,
);

Color importanceToColor(Importance importance) {
  if (importance == Importance.extreme) {
    return Colors.red;
  }
  if (importance == Importance.high) {
    return Colors.deepOrange;
  }
  if (importance == Importance.considerable) {
    return Colors.yellowAccent;
  }
  if (importance == Importance.normal) {
    return Colors.greenAccent;
  }
  if (importance == Importance.none) {
    return Colors.lightBlueAccent;
  }
  return Colors.greenAccent;
}