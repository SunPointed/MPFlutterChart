import 'package:flutter/widgets.dart';
import 'package:mp_flutter_chart/old/chart_enums.dart';
import 'package:mp_flutter_chart/old/chart_paint.dart';

class BarChart extends StatefulWidget {
  BarChartState _barChartState = BarChartState();
  List<List<String>> _xVals;
  List<List<double>> _yVals;
  List<String> _legendNames;

  BarChart.values(List<List<String>> xVals, List<List<double>> yVals,
      List<String> legendNames) {
    _xVals = xVals;
    _yVals = yVals;
    _legendNames = legendNames;
  }

  @override
  State<StatefulWidget> createState() {
    return _barChartState;
  }
}

class BarChartState extends State<BarChart> {
  double _x = 0.0;
  double _deltaX = 0.0;

  BarLineChartBasePainter _painter;

  @override
  Widget build(BuildContext context) {
    _painter = BarChartPainter(
        xVals: widget._xVals,
        yVals: widget._yVals,
        xPosOffset: _deltaX,
        legendNames: widget._legendNames);
    return Container(
      child: Center(
        child: GestureDetector(
          onHorizontalDragStart: (detail) {
            _x = detail.globalPosition.dx;
          },
          onHorizontalDragUpdate: (detail) {
            var dx = detail.globalPosition.dx - _x;
            _x = detail.globalPosition.dx;
            setState(() {
              _deltaX = _painter.adjustXPosOffset(_deltaX - dx);
            });
          },
          child: Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: double.infinity, minWidth: double.infinity),
                child: CustomPaint(painter: _painter)),
          ),
        ),
      ),
    );
  }
}

class LineChart extends StatefulWidget {
  LineChartState _lineChartState = LineChartState();
  List<List<String>> _xVals;
  List<List<double>> _yVals;
  List<String> _legendNames;
  LineMode _lineMode;

  LineChart.values(List<List<String>> xVals, List<List<double>> yVals,
      List<String> legendNames, [LineMode lineMode = LineMode.LINEAR])
      : _xVals = xVals,
        _yVals = yVals,
        _legendNames = legendNames,
        _lineMode = lineMode;

  @override
  State<StatefulWidget> createState() => _lineChartState;
}

class LineChartState extends State<LineChart> {
  double _x = 0.0;
  double _deltaX = 0.0;

  BarLineChartBasePainter _painter;

  @override
  Widget build(BuildContext context) {
    _painter = LineChartPainter(
        xVals: widget._xVals,
        yVals: widget._yVals,
        xPosOffset: _deltaX,
        legendNames: widget._legendNames,
        lineMode: widget._lineMode);
    return Container(
      child: Center(
        child: GestureDetector(
          onHorizontalDragStart: (detail) {
            _x = detail.globalPosition.dx;
          },
          onHorizontalDragUpdate: (detail) {
            var dx = detail.globalPosition.dx - _x;
            _x = detail.globalPosition.dx;
            setState(() {
              _deltaX = _painter.adjustXPosOffset(_deltaX - dx);
            });
          },
          child: Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: double.infinity, minWidth: double.infinity),
                child: CustomPaint(painter: _painter)),
          ),
        ),
      ),
    );
  }
}

class PieChart extends StatefulWidget {
  PieState _pieState = new PieState();
  List<String> _xVals;
  List<double> _yVals;

  @override
  State<StatefulWidget> createState() {
    return _pieState;
  }

  PieChart.values(List<String> xVals, List<double> yVals)
      : _xVals = xVals,
        _yVals = yVals;
}

class PieState extends State<PieChart> {
  PieChartPainter _painter;

  @override
  Widget build(BuildContext context) {
    _painter =
        PieChartPainter(pieXVals: widget._xVals, pieYVals: widget._yVals);
    return Container(
      child: Center(
        child: GestureDetector(
          onHorizontalDragStart: (detail) {
//            _x = detail.globalPosition.dx;
          },
          onHorizontalDragUpdate: (detail) {
//            var dx = detail.globalPosition.dx - _x;
//            _x = detail.globalPosition.dx;
//            setState(() {
//              _deltaX = _painter.adjustXPosOffset(_deltaX - dx);
//            });
          },
          child: Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: double.infinity, minWidth: double.infinity),
                child: CustomPaint(painter: _painter)),
          ),
        ),
      ),
    );
  }
}
