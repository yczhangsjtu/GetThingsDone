import 'package:flutter/material.dart';
import 'package:flutter_gtd/core/card.dart';
import 'package:flutter_gtd/components/card.dart';

class Basket extends StatefulWidget {
  final VoidCallback onBadgeChanged;

  Basket(this.onBadgeChanged);

  @override
  State<StatefulWidget> createState() {
    return _BasketState();
  }
}

class _BasketState extends State<Basket> {
  List<GTDCard> cards;
  TextEditingController _controller = TextEditingController();
  FocusNode _focusNode = FocusNode();

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
    return buildCard(context, cards[index],
        controller: _controller,
        focusNode: _focusNode, onGTDCardCallback: (card) {
      if (card != null) {
        if (GTDCard.updateBasketCard(index, card)) {
          setState(() {});
          GTDCard.saveCards();
          widget?.onBadgeChanged();
        }
      }
    }, onRemoveCallback: () {
      if (GTDCard.removeBasketCard(index)) {
        setState(() {});
        GTDCard.saveCards();
        widget?.onBadgeChanged();
      }
    });
  }
}
