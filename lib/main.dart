import 'package:flutter/material.dart';
import 'components/bottom_navigation_scaffold.dart';
import 'core/card.dart';
import 'pages/basket.dart';
import 'pages/actions.dart';
import 'pages/calendar.dart';
import 'pages/inventories.dart';
import 'pages/card.dart';

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
  @override
  Widget build(BuildContext context) {
    Widget home = Builder(builder: (context) {
      return BottomNavigationScaffold(
        items: <BottomNavigationItem>[
          BottomNavigationItem(
              icon: Icon(Icons.archive), title: "收集箱", page: Basket()),
          BottomNavigationItem(
              icon: Icon(Icons.directions_run), title: "行动", page: Actions()),
          BottomNavigationItem(
              icon: Icon(Icons.calendar_today), title: "日历", page: Calendar()),
          BottomNavigationItem(
              icon: Icon(Icons.format_list_bulleted),
              title: "清单",
              page: Inventories()),
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
                }
              });
            },
            child: Icon(Icons.add)),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
}
