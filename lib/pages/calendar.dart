import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_gtd/core/card.dart';
import 'package:flutter_gtd/core/time.dart';
import 'package:flutter_gtd/core/date_time_utils.dart';
import 'package:flutter_gtd/components/card.dart';
import 'package:flutter_gtd/components/styles.dart';

class Calendar extends StatefulWidget {
  final VoidCallback onBadgeChanged;

  Calendar(this.onBadgeChanged);

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

    Widget cardList;
    cardList = ListView.separated(
      itemBuilder: _buildCard,
      itemCount: cards.length,
      separatorBuilder: (context, index) {
        return Divider(
          height: 3,
          color: kActiveTabColor,
        );
      },
    );
    if (currentIndex == 1) {
      final day = DateTimeUtils.yearMonthDayFromInt(currentDay);
      cardList = Column(
        children: <Widget>[
          /*  _buildDaySelector(context),
          Text(
            "${DateTimeUtils.dayToString(currentDay)} 周${DateTimeUtils.weekDayName(DateTimeUtils.dayOfWeek(currentDay))}",
            style: kCalendarDateStyle,
          ),*/
          TableCalendar(
            events: _createEventsMap(),
            selectedDay: DateTime(day~/10000, (day~/100)%100, day%100),
            onDaySelected: (dateTime, list) {
              setState(() {
                currentDay = DateTimeUtils.yearMonthDayToInt(
                    dateTime.year, dateTime.month, dateTime.day);
              });
            },
          ),
          Expanded(child: cardList),
        ],
      );
    }

    cardList = Container(
      padding: EdgeInsets.all(5),
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

  Map<DateTime, List> _createEventsMap() {
    final resultCards = Map<DateTime, List>();
    GTDCard.cards.forEach((card) {
      if(card is ActionCard) {
        card.timeOptions.forEach((timeOption) {
          if(timeOption is FixedTime) {
            final date = DateTimeUtils.yearMonthDayFromInt(timeOption.day);
            final dateTime = DateTime(date~/10000, (date~/100) % 100, date%100);
            if(!resultCards.containsKey(dateTime)) {
              resultCards[dateTime] = [];
            }
            resultCards[dateTime].add(card);
          } else if(timeOption is Period) {
            var today = DateTime.now();
            today = DateTime(today.year, today.month, today.day);
            for(int i = 0; i < 365; i++) {
              final dateTime = today.add(Duration(days: i));
              final day = DateTimeUtils.yearMonthDayToInt(
                  dateTime.year, dateTime.month, dateTime.day);
              if(timeOption.match(day)) {
                if(!resultCards.containsKey(dateTime)) {
                  resultCards[dateTime] = [];
                }
                resultCards[dateTime].add(card);
              }
            }
          }
        });
      }
    });
    final result = Map<DateTime, List>();
    resultCards.forEach((dateTime, list) {
      final day = DateTimeUtils.yearMonthDayToInt(
          dateTime.year, dateTime.month, dateTime.day);
      list.sort((card1, card2) {
        return _compareCards(card1, card2, day);
      });
      result[dateTime] = list.map((card) => card.title).toList();
    });
    return result;
  }

  List<GTDCard> _filterActionCardsForDay(int day) {
    return GTDCard.cards.where((card) {
      return card is ActionCard &&
          card.waiting == null &&
          card.timeOptions.any((timeOption) {
            return timeOption.match(day);
          });
    }).toList()
      ..sort((card1, card2) {return _compareCards(card1, card2, day);});
  }

  static int _compareCards(GTDCard card1, GTDCard card2, int day) {
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
    for (int i = 0; i < _card2.timeOptions.length; i++) {
      if (!_card2.timeOptions[i].match(day)) {
        continue;
      }
      if (_card2.timeOptions[i].start != null &&
          (start2 == null || _card2.timeOptions[i].start < start2)) {
        start2 = _card2.timeOptions[i].start;
      }
    }
    if (start1 == null && start2 != null) {
      return 1;
    }
    if (start1 != null && start2 == null) {
      return -1;
    }
    if (start1 != null && start2 != null && start1 != start2) {
      return start1 - start2;
    }
    return _card1.importance.index - _card2.importance.index;
  }

  Widget _buildCard(BuildContext context, int index) {
    GTDCard card = cards[index];
    return buildCalendarCard(context, card,
        restrictedToDay: currentIndex == 0 ? DateTimeUtils.today() : currentDay,
        showComments: currentIndex == 0,
        showWaiting: currentIndex == 0,
        showNextAct: currentIndex == 0,
        showCheckbox: currentIndex == 0,
        onBadgeChanged: widget.onBadgeChanged);
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
