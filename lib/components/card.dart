import 'package:flutter/material.dart';
import 'package:flutter_gtd/core/card.dart';
import 'package:flutter_gtd/core/date_time_utils.dart';
import 'styles.dart';

typedef Future<dynamic> OnGTDCardCallback(dynamic card);

Widget buildCard(BuildContext context, GTDCard card,
    {TextEditingController controller,
    OnGTDCardCallback onGTDCardCallback,
    VoidCallback onRemoveCallback,
    int restrictedToDay}) {
  assert(onGTDCardCallback == null || controller != null);
  Widget comments = card.comments.isEmpty
      ? Container()
      : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: card.comments.map((s) {
            return Text(s, style: kCommentStyle);
          }).toList());
  var timeOptions = card is ActionCard ? card.timeOptions : null;
  if (restrictedToDay != null && timeOptions != null) {
    timeOptions = timeOptions.where((o) {
      return o.match(restrictedToDay) && o.start != null;
    }).toList();
  }
  Widget timeOptionList = (timeOptions?.isNotEmpty ?? false)
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: timeOptions.map((timeOption) {
            var str = restrictedToDay == null
                ? timeOption.toString()
                : TimeInterval(
                        start: timeOption.start, length: timeOption.length)
                    .toString();
            return str.isNotEmpty
                ? Text(str, style: kTimeOptionStyle)
                : Container();
          }).toList())
      : Container();
  Widget waiting = (card is ActionCard && card.waiting != null)
      ? Text(card.waiting, style: kWaitingStyle)
      : Container();
  Widget nextAct = (card is ActionCard && card.nextAct != null)
      ? Text(card.nextAct, style: kNextActionStyle)
      : Container();

  Widget subtitle = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      timeOptionList,
      waiting,
      nextAct,
      comments,
    ],
  );

  Color cardColor = card is BasketCard
      ? kBasketCardColor
      : (card is ActionCard
          ? importanceToColor(card.importance)
          : kInventoryCardColor);

  Widget child = ListTile(
    title: Text(card.title, style: kCardTitleStyle),
    subtitle: subtitle,
    trailing: Container(
        width: 80,
        child: Row(
          children: <Widget>[
            onGTDCardCallback == null
                ? Container()
                : InkWell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.edit, size: 24),
                    ),
                    onTap: () {
                      controller.text = card.toString();
                      showDialog(
                          context: context,
                          builder: (context) {
                            return buildCardEditingDialog(context, controller);
                          }).then(onGTDCardCallback);
                    }),
            onRemoveCallback == null
                ? Container()
                : InkWell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.delete, size: 24),
                    ),
                    onTap: onRemoveCallback),
          ],
        )),
  );
  child = Padding(
      padding: EdgeInsets.only(left: 20, right: 5, top: 5, bottom: 10),
      child: child);
  return Card(
    color: cardColor,
    elevation: 4.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    ),
    child: child,
  );
}

class _ActionCardCompleteCheckbox extends StatefulWidget {
  final ActionCard card;
  final VoidCallback onBadgeChanged;

  _ActionCardCompleteCheckbox(this.card, this.onBadgeChanged);

  @override
  State<StatefulWidget> createState() {
    return _ActionCardCompleteCheckboxState();
  }
}

class _ActionCardCompleteCheckboxState
    extends State<_ActionCardCompleteCheckbox> {
  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: widget.card.getCompleted(DateTimeUtils.today()),
      onChanged: (value) {
        widget.card.setCompleted(value, DateTimeUtils.today());
        ActionCard.saveCompleted();
        setState(() {});
        if (widget.onBadgeChanged != null) {
          widget.onBadgeChanged();
        }
      },
    );
  }
}

Widget buildCalendarCard(BuildContext context, GTDCard card,
    {TextEditingController controller,
    int restrictedToDay,
    bool showComments,
    bool showWaiting,
    bool showNextAct,
    bool showCheckbox,
    VoidCallback onBadgeChanged}) {
  Widget comments = card.comments.isEmpty || (showComments != true)
      ? Container()
      : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: card.comments.map((s) {
            return Text(s, style: kCommentStyle);
          }).toList());
  var timeOptions = card is ActionCard ? card.timeOptions : null;
  if (restrictedToDay != null && timeOptions != null) {
    timeOptions = timeOptions.where((o) {
      return o.match(restrictedToDay) && o.start != null;
    }).toList();
  }
  Widget timeOptionList = (timeOptions?.isNotEmpty ?? false)
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: timeOptions.map((timeOption) {
            var str = restrictedToDay == null
                ? timeOption.toString()
                : TimeInterval(
                        start: timeOption.start, length: timeOption.length)
                    .toString();
            return str.isNotEmpty
                ? Text(str, style: kTimeOptionStyle)
                : Container();
          }).toList())
      : Container();
  Widget waiting =
      (card is ActionCard && card.waiting != null && (showWaiting ?? false))
          ? Text(card.waiting, style: kWaitingStyle)
          : Container();
  Widget nextAct =
      (card is ActionCard && card.nextAct != null && (showNextAct ?? false))
          ? Text(card.nextAct, style: kNextActionStyle)
          : Container();

  Widget subtitle = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      timeOptionList,
      waiting,
      nextAct,
      comments,
    ],
  );

  Color cardColor = card is BasketCard
      ? kBasketCardColor
      : (card is ActionCard
          ? importanceToColor(card.importance)
          : kInventoryCardColor);

  Widget child = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(card.title, style: kCardTitleStyle),
      subtitle,
    ],
  );

  if (showCheckbox == true) {
    child = Row(
      children: <Widget>[
        Expanded(child: child),
        _ActionCardCompleteCheckbox(card, onBadgeChanged),
      ],
    );
  }

  child = Padding(
      padding: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
      child: child);

  return Card(
    margin: EdgeInsets.only(bottom: 1, top: 1),
    color: cardColor,
    child: child,
  );
}

Widget buildCardEditingDialog(
    BuildContext context, TextEditingController controller) {
  return SimpleDialog(
    contentPadding: EdgeInsets.all(10),
    backgroundColor: kEditCardDialogColor,
    children: <Widget>[
      TextField(
        cursorColor: Colors.black,
        controller: controller,
        style: kEditCardDialogStyle,
        maxLines: null,
      ),
      ButtonBar(
        children: <Widget>[
          FlatButton(
            child: Text("确定", style: kFlatButtonStyle),
            onPressed: () {
              GTDCard card = GTDCard.fromString(controller.text);
              if (card == null) {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Text("卡片内容无效", style: kBottomSheetStyle);
                    });
              } else {
                Navigator.of(context).pop(card);
              }
            },
          ),
          FlatButton(
            child: Text("取消", style: kFlatButtonStyle),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    ],
  );
}

Widget buildTabButton(String name, bool active) {
  return Container(
      width: 80,
      height: 48,
      child: Text(name, style: active ? kActiveTabStyle : kInactiveTabStyle),
      decoration: active
          ? BoxDecoration(
              color: kActiveTabColor,
            )
          : BoxDecoration(
              color: kInactiveTabColor,
              border: Border.all(color: Colors.white),
            ));
}
