import 'package:flutter/widgets.dart';
import 'package:mp_flutter_chart/chart/mp/core/data.dart';
import 'package:mp_flutter_chart/chart/mp/painter/painter.dart';

abstract class Chart extends StatefulWidget {}

abstract class ChartState<T extends Chart> extends State<T> {
  bool _singleTap = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        children: [
          ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: double.infinity, minWidth: double.infinity),
              child: GestureDetector(
                  onTapDown: (detail) {
                    _singleTap = true;
                    onTapDown(detail);
                  },
                  onTapUp:(detail){
                    if(_singleTap){
                      _singleTap = false;
                      onSingleTapUp(detail);
                    }
                  },
                  onDoubleTap: () {
                    _singleTap = false;
                    onDoubleTap();
                  },
                  onScaleStart: (detail) {
                    onScaleStart(detail);
                  },
                  onScaleUpdate: (detail) {
                    _singleTap = false;
                    onScaleUpdate(detail);
                  },
                  onScaleEnd: (detail) {
                    onScaleEnd(detail);
                  },
                  child: CustomPaint(painter: getPainter()))),
        ]);
  }

  @override
  void reassemble() {
    super.reassemble();
    getPainter().reassemble();
  }

  ChartPainter getPainter();

  void onDoubleTap();

  void onScaleStart(ScaleStartDetails detail);

  void onScaleUpdate(ScaleUpdateDetails detail);

  void onScaleEnd(ScaleEndDetails detail);

  void onTapDown(TapDownDetails detail);

  void onSingleTapUp(TapUpDetails detail);
}
