import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mp_flutter_chart/demo/actions_builder.dart';

abstract class ActionState<T extends StatefulWidget> extends State<T> {
  ActionsBuilder _builder = ActionsBuilder();

  @override
  Widget build(BuildContext context) {
    chartInit();
    return Scaffold(
        appBar: AppBar(
            actions: <Widget>[
              PopupMenuButton<String>(
                itemBuilder: _builder.builder,
                onSelected: (String action) {
                  itemClick(action);
                },
              ),
            ],
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text(getTitle())),
        body: getBody());
  }

  void itemClick(String action);

  void chartInit();

  Widget getBody();

  String getTitle();
}
