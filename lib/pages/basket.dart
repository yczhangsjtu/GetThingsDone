import 'package:flutter/material.dart';

class Basket extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BasketState();
  }

}

class _BasketState extends State<Basket> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("收集箱"),
      ),
    );
  }

}