import 'package:flutter/material.dart';
import 'package:flutter_gtd/core/card.dart';
import 'package:flutter_gtd/core/date_time_utils.dart';

import 'card.dart';
import 'styles.dart';

class Calendar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CalendarState();
  }
}

class _CalendarState extends State<Calendar> {
  int currentIndex = 0;
  int currentDay;

  List<GTDCard> cards;
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    currentDay = currentDay ?? DateTimeUtils.today();
    cards = _filterActionCardsForDay(
        currentIndex == 0 ? DateTimeUtils.today() : currentDay);
    Widget leftPanel = Column(
      children: <Widget>[
        GestureDetector(
          child: buildTabButton("今天", currentIndex == 0),
          onTap: () {
            setState(() {
              currentIndex = 0;
            });
          },
        ),
        GestureDetector(
          child: buildTabButton("日历", currentIndex == 1),
          onTap: () {
            setState(() {
              currentIndex = 1;
            });
          },
        ),
      ],
    );

    Widget cardList =
        ListView.builder(itemBuilder: _buildCard, itemCount: cards.length);

    if (currentIndex == 1) {
      cardList = Column(
        children: <Widget>[
          _buildDaySelector(context),
          Text(
            "${DateTimeUtils.dayToString(currentDay)} 周${DateTimeUtils.weekDayName(DateTimeUtils.dayOfWeek(currentDay))}",
            style: kCalendarDateStyle,
          ),
          Expanded(child: cardList),
        ],
      );
    }

    cardList = Container(
      child: cardList,
      color: kActiveTabColor,
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
      appBar: AppBar(title: Text("日历")),
      body: body,
    );
  }

  List<GTDCard> _filterActionCardsForDay(int day) {
    return GTDCard.cards.where((card) {
      return card is ActionCard &&
          card.waiting == null &&
          card.timeOptions.any((timeOption) {
            return timeOption.match(day);
          });
    }).toList()
      ..sort((GTDCard card1, GTDCard card2) {
        ActionCard _card1 = card1 as ActionCard;
        ActionCard _card2 = card2 as ActionCard;
        int start1;
        for (int i = 0; i < _card1.timeOptions.length; i++) {
          if (!_card1.timeOptions[i].match(day)) {
            continue;
          }
          if (_card1.timeOptions[i].start != null &&
              (start1 == null || _card1.timeOptions[i].start < start1)) {
            start1 = _card1.timeOptions[i].start;
          }
        }
        int start2;
        for (int i = 0; i < _card1.timeOptions.length; i++) {
          if (!_card2.timeOptions[i].match(day)) {
            continue;
          }
          if (_card1.timeOptions[i].start != null &&
              (start2 == null || _card2.timeOptions[i].start < start2)) {
            start2 = _card2.timeOptions[i].start;
          }
        }
        if (start1 == null && start2 != null) {
          return -1;
        }
        if (start1 != null && start2 == null) {
          return 1;
        }
        if (start1 != null && start2 != null && start1 != start2) {
          return start1 - start2;
        }
        return _card1.importance.index - _card2.importance.index;
      });
  }

  Widget _buildCard(BuildContext context, int index) {
    GTDCard card = cards[index];
    return buildCard(context, card,
        restrictedToDay:
            currentIndex == 0 ? DateTimeUtils.today() : currentDay);
  }

  Widget _buildDaySelector(BuildContext context) {
    currentDay = currentDay ?? DateTimeUtils.today();
    Widget child = Row(
      children: <Widget>[
        Expanded(
            child: TextField(
          controller: _controller,
          style: kCalendarDateStyle,
        )),
        GestureDetector(
            child: Text("确定"),
            onTap: () {
              int day = DateTimeUtils.absoluteDateToday(_controller.text);
              if (day != null) {
                setState(() {
                  currentDay = day;
                });
              }
            }),
        GestureDetector(
            child: Icon(Icons.arrow_left),
            onTap: () {
              setState(() {
                currentDay = currentDay ?? DateTimeUtils.today();
                currentDay--;
              });
            }),
        GestureDetector(
            child: Icon(Icons.arrow_right),
            onTap: () {
              setState(() {
                currentDay = currentDay ?? DateTimeUtils.today();
                currentDay++;
              });
            }),
      ],
    );
    return child;
  }
}
