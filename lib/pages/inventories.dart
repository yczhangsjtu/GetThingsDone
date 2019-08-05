import 'package:flutter/material.dart';
import 'package:flutter_gtd/core/card.dart';

import 'package:flutter_gtd/components/card.dart';
import 'package:flutter_gtd/components/styles.dart';

class Inventories extends StatefulWidget {
  final VoidCallback onBadgeChanged;

  Inventories(this.onBadgeChanged);

  @override
  State<StatefulWidget> createState() {
    return _InventoriesState();
  }
}

class _InventoriesState extends State<Inventories> {
  int currentIndex = 0;
  List<GTDCard> cards = [];
  TextEditingController _controller = TextEditingController();
  TextEditingController _beginController = TextEditingController();
  TextEditingController _endController = TextEditingController();
  bool _currentIsOr;

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
      }).toList();
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

    cardList = Column(
      children: <Widget>[
        Expanded(
          child: cardList,
        ),
        Inventory.inventories.isNotEmpty
            ? _buildControlPanel(context, currentIndex)
            : Container(),
      ],
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
        onPressed: () {
          _showAddInventoryDialog(context);
        },
      );
    }
    return Container();
  }

  Widget _buildCard(BuildContext context, int index) {
    Inventory inventory = Inventory.inventories[currentIndex];
    return buildCard(context, cards[index],
        controller: _controller,
        onGTDCardCallback: (card) {
      if (card != null) {
        if (GTDCard.updateInventoryCard(index, inventory, card)) {
          setState(() {});
          GTDCard.saveCards();
          widget?.onBadgeChanged();
        }
      }
    }, onRemoveCallback: () {
      if (GTDCard.removeInventoryCard(index, inventory)) {
        setState(() {});
        GTDCard.saveCards();
        widget?.onBadgeChanged();
      }
    });
  }

  void _showAddInventoryDialog(BuildContext context) {
    _controller.text = "";
    showDialog(
        context: context,
        builder: (context) {
          return _buildAddInventoryDialog(context, _controller);
        });
  }

  Widget _buildAddInventoryDialog(BuildContext context,
      TextEditingController controller) {
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
                if (controller.text.isEmpty) {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Text("清单名不能为空", style: kBottomSheetStyle);
                      });
                } else {
                  Inventory.addInventory(controller.text);
                  Inventory.saveInventories();
                  Navigator.of(context).pop();
                  setState(() {});
                  widget?.onBadgeChanged();
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

  Widget _buildControlPanel(BuildContext context, int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              _showEditInventoryDialog(context, index);
            }),
        IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              Inventory.removeInventory(currentIndex);
              Inventory.saveInventories();
              setState(() {});
              widget?.onBadgeChanged();
            }),
      ],
    );
  }

  void _showEditInventoryDialog(BuildContext context, int index) {
    _controller.text = "";
    showDialog(
        context: context,
        builder: (context) {
          return _buildEditInventoryDialog(
              context, index, _beginController, _endController);
        });
  }

  Widget _buildEditInventoryDialog(
      BuildContext context,
      int index,
      TextEditingController _beginController,
      TextEditingController _endController) {
    _currentIsOr = Inventory.inventories[index].filterRule.relationIsOr;
    _beginController.text =
        Inventory.inventories[index].filterRule.beginWithOptions?.join("\n") ??
            "";
    _endController.text =
        Inventory.inventories[index].filterRule.endWithOptions?.join("\n") ??
            "";
    return SimpleDialog(
      contentPadding: EdgeInsets.all(10),
      backgroundColor: kEditCardDialogColor,
      children: <Widget>[
        TextField(
          cursorColor: Colors.black,
          controller: _beginController,
          style: kEditCardDialogStyle,
          maxLines: null,
          decoration: InputDecoration(
            labelText: "开头",
          ),
        ),
        TextField(
          cursorColor: Colors.black,
          controller: _endController,
          style: kEditCardDialogStyle,
          maxLines: null,
          decoration: InputDecoration(
            labelText: "结尾",
          ),
        ),
        BinarySelector(
            trueChild: Text("或"),
            falseChild: Text("且"),
            initialValue: _currentIsOr,
            onChanged: (value) {
              _currentIsOr = value;
            }),
        ButtonBar(
          children: <Widget>[
            FlatButton(
              child: Text("确定", style: kFlatButtonStyle),
              onPressed: () {
                Inventory.updateInventoryFilter(
                    index,
                    FilterRule(
                      beginWithOptions:
                          _beginController.text.split("\n").where((s) {
                        return s.isNotEmpty;
                      }).toList(),
                      endWithOptions:
                          _endController.text.split("\n").where((s) {
                        return s.isNotEmpty;
                      }).toList(),
                      relationIsOr: _currentIsOr,
                    ));
                Inventory.saveInventories();
                Navigator.of(context).pop();
                setState(() {});
                widget?.onBadgeChanged();
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
}

class BinarySelector extends StatefulWidget {
  final Widget trueChild;
  final Widget falseChild;
  final bool horizontal;
  final bool initialValue;
  final ValueChanged<bool> onChanged;

  BinarySelector(
      {this.trueChild,
      this.falseChild,
      this.onChanged,
      this.horizontal = true,
      this.initialValue = true})
      : assert(horizontal != null),
        assert(initialValue != null);

  @override
  State<StatefulWidget> createState() {
    return _BinarySelectorState();
  }
}

class _BinarySelectorState extends State<BinarySelector> {
  bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    Widget first = Radio<bool>(
        groupValue: _value,
        value: true,
        onChanged: (value) {
          setState(() {
            _value = value;
            if (widget.onChanged != null) widget.onChanged(value);
          });
        });
    first = Row(
      children: <Widget>[
        first,
        widget.trueChild,
      ],
    );
    Widget second = Radio<bool>(
        groupValue: _value,
        value: false,
        onChanged: (value) {
          setState(() {
            _value = value;
            if (widget.onChanged != null) widget.onChanged(value);
          });
        });
    second = Row(
      children: <Widget>[
        second,
        widget.falseChild,
      ],
    );
    var list = [first, second];
    return widget.horizontal ? Row(children: list) : Column(children: list);
  }
}
