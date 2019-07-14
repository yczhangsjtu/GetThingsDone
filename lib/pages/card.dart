import 'package:flutter/material.dart';
import 'package:flutter_gtd/core/card.dart';
import 'styles.dart';

typedef Future<dynamic> OnGTDCardCallback(dynamic card);

Widget buildCard(
    BuildContext context,
    GTDCard card,
    TextEditingController controller,
    FocusNode focusNode,
    OnGTDCardCallback onGTDCardCallback,
    VoidCallback onRemoveCallback) {
  Widget comments = card.comments.isEmpty
      ? Container()
      : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: card.comments.map((s) {
            return Text(s, style: kCommentStyle);
          }).toList());
  Widget timeOptions =
      (card is ActionCard && (card.timeOptions?.isNotEmpty ?? false))
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: card.timeOptions.map((timeOption) {
                return Text(timeOption.toString(), style: kTimeOptionStyle);
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
      timeOptions,
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
            InkWell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.edit, size: 24),
                ),
                onTap: () {
                  controller.text = card.toString();
                  showDialog(
                      context: context,
                      builder: (context) {
                        return buildCardEditingDialog(
                            context, controller, focusNode);
                      }).then(onGTDCardCallback);
                }),
            InkWell(
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

Widget buildCardEditingDialog(BuildContext context,
    TextEditingController controller, FocusNode focusNode) {
  return SimpleDialog(
    backgroundColor: kEditCardDialogColor,
    children: <Widget>[
      EditableText(
        backgroundCursorColor: Colors.black,
        cursorColor: Colors.black,
        controller: controller,
        focusNode: focusNode,
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
