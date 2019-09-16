import 'package:flutter/material.dart';
import 'package:mp_flutter_chart/chart/mp/chart/chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';

class ActionsBuilder{
  var builder = (BuildContext context) => <PopupMenuItem<String>>[
    _item('View on GitHub', 'A'),
    _item('Toggle Values', 'B'),
    _item('Toggle Icons', 'C'),
    _item('Toggle Filled', 'D'),
    _item('Toggle Circles', 'E'),
    _item('Toggle Cubic', 'F'),
    _item('Toggle Stepped', 'G'),
    _item('Toggle Horizontal Cubic', 'H'),
    _item('Toggle PinchZoom', 'I'),
    _item('Toggle Auto Scale', 'J'),
    _item('Toggle Highlight', 'K'),
    _item('Animate X', 'L'),
    _item('Animate Y', 'M'),
    _item('Animate XY', 'N'),
    _item('Save to Gallery', 'O'),
  ];

  void itemClick(String action, ChartState state) {
    switch (action) {
      case 'A':
        break;
      case 'B':
        break;
      case 'C':
        break;
      case 'D':
        break;
      case 'E':
        break;
      case 'F':
        break;
      case 'G':
        break;
      case 'H':
        break;
      case 'I':
        break;
      case 'J':
        break;
      case 'K':
        break;
      case 'L':
        break;
      case 'M':
        break;
      case 'N':
        break;
      case 'O':
        break;
    }
  }
}

PopupMenuItem _item(String text, String id) {
  return PopupMenuItem<String>(
      value: id,
      child: Container(
          padding: EdgeInsets.only(top: 15.0),
          child: Center(
              child: Text(
                text,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: ColorUtils.BLACK,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ))));
}
