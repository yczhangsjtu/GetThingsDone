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
            children: cards[index].comments.map((s) {
            return Text(s, style: kCommentStyle);
          }).toList());
    Widget child = Column(
      children: <Widget>[
        Text(cards[index].title, style: kCardTitleStyle),
        comments,
      ],
    );
    child = Padding(padding: EdgeInsets.all(10), child: child);
    return Card(
      child: child,
    );
  }
}
