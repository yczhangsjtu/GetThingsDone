import 'package:flutter/material.dart';
import 'package:flutter_gtd/core/card.dart';

import 'card.dart';
import 'styles.dart';

class Inventories extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _InventoriesState();
  }
}

class _InventoriesState extends State<Inventories> {
  int currentIndex = 0;
  List<GTDCard> cards = [];
  TextEditingController _controller = TextEditingController();
  FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    cards.clear();
    if (currentIndex >= Inventory.inventories.length) {
      currentIndex = Inventory.inventories.length - 1;
    }
    if (currentIndex < 0) {
      currentIndex = 0;
    }
    if (Inventory.inventories.isNotEmpty) {
      Inventory inventory = Inventory.inventories[currentIndex];
      cards = GTDCard.cards.where((card) {
        return card is InventoryCard && inventory.filterRule.match(card.title);
      });
    }

    Widget leftPanel = ListView.builder(
      itemCount: Inventory.inventories.length + 1,
      itemBuilder: _buildInventoryTabs,
    );

    leftPanel = Container(
      child: leftPanel,
      width: 100,
    );

    Widget cardList =
        ListView.builder(itemBuilder: _buildCard, itemCount: cards.length);

    cardList = Container(
      color: kActiveTabColor,
      child: cardList,
    );

    Widget body = Row(
      children: <Widget>[
        leftPanel,
        Expanded(
          child: cardList,
        )
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("清单"),
      ),
      body: body,
    );
  }

  Widget _buildInventoryTabs(BuildContext context, int index) {
    if (index < Inventory.inventories.length) {
      return GestureDetector(
        child: buildTabButton(
            Inventory.inventories[index].name, currentIndex == index),
        onTap: () {
          setState(() {
            currentIndex = index;
          });
        },
      );
    }
    if (index == Inventory.inventories.length) {
      return IconButton(
        icon: Icon(Icons.add_circle_outline),
        onPressed: () {},
      );
    }
    return Container();
  }

  Widget _buildCard(BuildContext context, int index) {
    Inventory inventory = Inventory.inventories[currentIndex];
    return buildCard(context, cards[index],
        controller: _controller,
        focusNode: _focusNode, onGTDCardCallback: (card) {
      if (card != null) {
        if (GTDCard.updateInventoryCard(index, inventory, card)) {
          setState(() {});
          GTDCard.saveCards();
        }
      }
    }, onRemoveCallback: () {
      if (GTDCard.removeInventoryCard(index, inventory)) {
        setState(() {});
        GTDCard.saveCards();
      }
    });
  }
}
