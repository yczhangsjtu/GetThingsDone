import 'package:flutter/material.dart';

class BottomNavigationItem {
  BottomNavigationItem({
    @required this.icon,
    @required this.title,
    @required this.page,
  }) : assert(icon != null),
       assert(title != null),
       assert(page != null);
  final Icon icon;
  final String title;
  final Widget page;
}

class BottomNavigationScaffold extends StatefulWidget {

  BottomNavigationScaffold({
    Key key,
    @required this.items,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomBarColor,
  }) : assert(items != null && items.length > 0),
        super(key: key);

  final Widget floatingActionButton;
  final List<BottomNavigationItem> items;
  final FloatingActionButtonLocation floatingActionButtonLocation;
  final Color bottomBarColor;

  @override
  State<StatefulWidget> createState() {
    return _BottomNavigationScaffoldState();
  }

}

class _BottomNavigationScaffoldState extends State<BottomNavigationScaffold> {

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {

    Widget body = widget.items[currentIndex].page;

    return Scaffold(
      body: body,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      bottomNavigationBar: BottomNavigationBar(
        items: widget.items.map((item) {
          return BottomNavigationBarItem(
            icon: item.icon,
            title: Text(item.title),
            backgroundColor: Theme.of(context).accentColor,
          );
        }).toList(),
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        currentIndex: currentIndex,
        backgroundColor: widget.bottomBarColor ?? Theme.of(context).primaryColor,
      ),
    );
  }

}