import 'package:flutter/material.dart';
import 'components/bottom_navigation_scaffold.dart';
import 'core/card.dart';
import 'pages/basket.dart';
import 'pages/actions.dart';
import 'pages/calendar.dart';
import 'pages/inventories.dart';
import 'package:flutter_gtd/components/card.dart';

void main() {
  Inventory.loadInventories().then((v) {
    GTDCard.loadCards().then((e) {
      runApp(GTDApp());
    });
  });
}

class GTDApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GTDAppState();
  }
}

class GTDAppState extends State<GTDApp> {
  BadgeMap _badgeMap;

  @override
  void initState() {
    super.initState();
    _badgeMap = BadgeMap();
    _onBadgeChanged();
  }

  @override
  void dispose() {
    _badgeMap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget home = Builder(builder: (context) {
      return BottomNavigationScaffold(
        items: <BottomNavigationItem>[
          BottomNavigationItem(
              icon: Icon(Icons.archive),
              title: "收集箱",
              page: Basket(_onBadgeChanged)),
          BottomNavigationItem(
              icon: Icon(Icons.directions_run),
              title: "行动",
              page: Actions(_onBadgeChanged)),
          BottomNavigationItem(
              icon: Icon(Icons.calendar_today), title: "日历", page: Calendar()),
          BottomNavigationItem(
              icon: Icon(Icons.format_list_bulleted),
              title: "清单",
              page: Inventories(_onBadgeChanged)),
        ],
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              TextEditingController controller = TextEditingController();
              FocusNode focusNode = FocusNode();
              return showDialog(
                  context: context,
                  builder: (context) {
                    return buildCardEditingDialog(
                        context, controller, focusNode);
                  }).then((card) {
                if (card != null) {
                  GTDCard.addCard(card);
                  GTDCard.saveCards();
                  setState(() {});
                  _onBadgeChanged();
                }
              });
            },
            child: Icon(Icons.add)),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        badges: _badgeMap,
      );
    });

    return MaterialApp(
      title: 'Getting Things Done',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: home,
    );
  }

  void _onBadgeChanged() {
    int count = GTDCard.countBasketCard();
    _badgeMap.updateBadge("收集箱", count > 0 ? "$count" : null);
    count = GTDCard.countExpiredActionCard();
    _badgeMap.updateBadge("行动", count > 0 ? "$count" : null);
    count = GTDCard.countTodayCard();
    _badgeMap.updateBadge("日历", count > 0 ? "$count" : null);
  }
}
