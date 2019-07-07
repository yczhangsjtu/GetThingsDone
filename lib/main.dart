import 'package:flutter/material.dart';
import 'components/bottom_navigation_scaffold.dart';
import 'pages/basket.dart';

void main() => runApp(GTDApp());

class GTDApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    Widget home = BottomNavigationScaffold(
      items: <BottomNavigationItem> [
        BottomNavigationItem(
          icon: Icon(Icons.archive),
          title: "收集箱",
          page: Basket()
        ),
        BottomNavigationItem(
            icon: Icon(Icons.directions_run),
            title: "行动",
            page: Text("行动")
        ),
        BottomNavigationItem(
            icon: Icon(Icons.calendar_today),
            title: "日历",
            page: Text("日历")
        ),
        BottomNavigationItem(
            icon: Icon(Icons.format_list_bulleted),
            title: "清单",
            page: Text("清单")
        ),
      ],
    );

    return MaterialApp(
      title: 'Getting Things Done',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: home,
    );
  }
}