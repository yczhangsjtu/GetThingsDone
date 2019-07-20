import 'package:flutter/material.dart';

class BottomNavigationItem {
  BottomNavigationItem({
    @required this.icon,
    @required this.title,
    @required this.page,
  })  : assert(icon != null),
        assert(title != null),
        assert(page != null);
  final Icon icon;
  final String title;
  final Widget page;
}

class BadgeMap with ChangeNotifier {
  final Map<String, String> _badges = Map();

  void updateBadge(String key, String value) {
    _badges[key] = value;
    notifyListeners();
  }

  void removeBadge(String key) {
    _badges.remove(key);
    notifyListeners();
  }

  String getBadge(String key) {
    return _badges[key];
  }
}

class BottomNavigationScaffold extends StatefulWidget {
  BottomNavigationScaffold({
    Key key,
    @required this.items,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomBarColor,
    this.badges,
  })  : assert(items != null && items.length > 0),
        super(key: key);

  final Widget floatingActionButton;
  final List<BottomNavigationItem> items;
  final FloatingActionButtonLocation floatingActionButtonLocation;
  final Color bottomBarColor;
  final BadgeMap badges;

  @override
  State<StatefulWidget> createState() {
    return _BottomNavigationScaffoldState();
  }
}

class _BottomNavigationScaffoldState extends State<BottomNavigationScaffold> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.badges?.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body = widget.items[currentIndex].page;

    return Scaffold(
      body: body,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      bottomNavigationBar: BottomNavigationBar(
        items: widget.items.map((item) {
          String _badgeText = widget.badges?.getBadge(item.title);
          Widget badge = _badgeText == null
              ? null
              : Positioned(
                  right: 0,
                  child: new Container(
                    decoration: new BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: new Text(
                      _badgeText,
                      style: new TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
          Widget icon = Padding(
            padding: EdgeInsets.all(5),
            child: item.icon,
          );
          return BottomNavigationBarItem(
            icon: badge == null ? icon : Stack(
              children: <Widget>[icon, badge],
            ),
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
        backgroundColor:
            widget.bottomBarColor ?? Theme.of(context).bottomAppBarColor,
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Theme.of(context).accentColor,
        selectedItemColor: Theme.of(context).primaryColorLight,
      ),
    );
  }
}
