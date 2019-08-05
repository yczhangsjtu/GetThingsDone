import 'package:flutter/material.dart';
import 'package:flutter_gtd/core/card.dart';
import 'package:flutter_gtd/components/card.dart';
import 'package:flutter_gtd/components/styles.dart';

class Actions extends StatefulWidget {
  final VoidCallback onBadgeChanged;

  Actions(this.onBadgeChanged);

  @override
  State<StatefulWidget> createState() {
    return _ActionsState();
  }
}

class _ActionsState extends State<Actions> {
  int currentIndex = 0;
  TextEditingController _controller = TextEditingController();

  final List<GTDCard> arrangedCards = [];
  final List<GTDCard> waitingCards = [];
  final List<GTDCard> expiredCards = [];
  List<List<GTDCard>> cardLists;

  @override
  void initState() {
    super.initState();
    cardLists = [arrangedCards, waitingCards, expiredCards];
  }

  @override
  Widget build(BuildContext context) {
    arrangedCards.clear();
    waitingCards.clear();
    expiredCards.clear();
    for (int i = 0; i < GTDCard.cards.length; i++) {
      GTDCard card = GTDCard.cards[i];
      if (card is ActionCard) {
        if (card.waiting != null) {
          waitingCards.add(card);
        } else if (!card.expired()) {
          arrangedCards.add(card);
        } else {
          expiredCards.add(card);
        }
      }
    }

    Widget leftPanel = Column(
      children: <Widget>[
        GestureDetector(
          child: buildTabButton("已安排", currentIndex == 0),
          onTap: () {
            setState(() {
              currentIndex = 0;
            });
          },
        ),
        GestureDetector(
          child: buildTabButton("等待中", currentIndex == 1),
          onTap: () {
            setState(() {
              currentIndex = 1;
            });
          },
        ),
        GestureDetector(
          child: buildTabButton("已过期", currentIndex == 2),
          onTap: () {
            setState(() {
              currentIndex = 2;
            });
          },
        ),
      ],
    );
    Widget cardList = ListView.builder(
        itemBuilder: _buildCard, itemCount: cardLists[currentIndex].length);
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
        title: Text("行动"),
      ),
      body: body,
    );
  }

  Widget _buildCard(BuildContext context, int index) {
    return buildCard(context, cardLists[currentIndex][index],
        controller: _controller, onGTDCardCallback: (card) {
      if (card != null) {
        bool updated = false;
        if (currentIndex == 0) {
          updated = GTDCard.updateArrangedActionCard(index, card);
        } else if (currentIndex == 1) {
          updated = GTDCard.updateWaitingActionCard(index, card);
        } else if (currentIndex == 2) {
          updated = GTDCard.updateExpiredActionCard(index, card);
        }
        if (updated) {
          setState(() {});
          GTDCard.saveCards();
          widget.onBadgeChanged();
        }
      }
    }, onRemoveCallback: () {
      bool removed = false;
      if (currentIndex == 0) {
        removed = GTDCard.removeArrangedActionCard(index);
      } else if (currentIndex == 1) {
        removed = GTDCard.removeWaitingActionCard(index);
      } else if (currentIndex == 2) {
        removed = GTDCard.removeExpiredActionCard(index);
      }
      if (removed) {
        setState(() {});
        GTDCard.saveCards();
        widget.onBadgeChanged();
      }
    });
  }
}
