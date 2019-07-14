import 'package:flutter/material.dart';
import 'components/bottom_navigation_scaffold.dart';
import 'pages/basket.dart';
import 'core/card.dart';
import 'pages/card.dart';

void main() {
  GTDCard.loadCards().then((e) {
    runApp(GTDApp());
  }).then((e) {
/*    GTDCard.addCard(GTDCard.fromString("看书《白鹿原》\n已看到第15页"));
    GTDCard.addCard(GTDCard.fromString("买书《白鹿原》"));
    GTDCard.addCard(GTDCard.fromString("洗衣服"));
    GTDCard.addCard(GTDCard.fromString("洗澡\n今天晚上\n重要"));
    GTDCard.addCard(GTDCard.fromString("买书《穷查理宝典》\n去新华书店"));
    GTDCard.addCard(GTDCard.fromString("买书《苏菲的世界》\n去图书大厦\n很重要"));
    GTDCard.addCard(GTDCard.fromString("去参加会议\n逸夫楼200号"));*/
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
    Basket basket = Basket();
    Widget home = Builder(builder: (context) {
      return BottomNavigationScaffold(
        items: <BottomNavigationItem>[
          BottomNavigationItem(
              icon: Icon(Icons.archive), title: "收集箱", page: basket),
          BottomNavigationItem(
              icon: Icon(Icons.directions_run), title: "行动", page: Text("行动")),
          BottomNavigationItem(
              icon: Icon(Icons.calendar_today), title: "日历", page: Text("日历")),
          BottomNavigationItem(
              icon: Icon(Icons.format_list_bulleted),
              title: "清单",
              page: Text("清单")),
        ],
        floatingActionButton: FloatingActionButton(onPressed: () {
          TextEditingController controller = TextEditingController();
          FocusNode focusNode = FocusNode();
          return showDialog(context: context, builder: (context) {
            return buildCardEditingDialog(context, controller, focusNode);
          }).then((card) {
            if(card != null) {
              GTDCard.addCard(card);
              GTDCard.saveCards();
              setState(() {});
            }
          });
        }, child: Icon(Icons.add)),
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