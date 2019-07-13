import 'package:flutter/material.dart';
import 'package:flutter_gtd/core/card.dart';
import 'styles.dart';

class Basket extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BasketState();
  }
}

class _BasketState extends State<Basket> {
  List<GTDCard> cards;

  @override
  Widget build(BuildContext context) {
    cards = GTDCard.cards.where((card) {
      return card is BasketCard;
    }).toList();
    Widget body =
        ListView.builder(itemBuilder: _buildCard, itemCount: cards.length);
    body = Padding(
      padding: EdgeInsets.all(10),
      child: body,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("收集箱"),
      ),
      body: body,
    );
  }

  Widget _buildCard(BuildContext context, int index) {
    Widget comments = cards.isEmpty
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: cards[index].comments.map((s) {
              return Text(s, style: kCommentStyle);
            }).toList());
    Widget child = ListTile(
      title: Text(cards[index].title, style: kCardTitleStyle),
      subtitle: comments,
      trailing: Container(
          width: 80,
          child: Row(
            children: <Widget>[
              InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.edit, size: 24),
                  ),
                  onTap: () {}),
              InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.delete, size: 24),
                  ),
                  onTap: () {
                    if (GTDCard.removeBasketCard(index)) {
                      setState(() {});
                      GTDCard.saveCards();
                    }
                  }),
            ],
          )),
    );
    child = Padding(
        padding: EdgeInsets.only(left: 20, right: 5, top: 5, bottom: 10),
        child: child);
    return Card(
      color: kBasketCardColor,
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: child,
    );
  }
}
