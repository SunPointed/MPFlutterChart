import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:mp_flutter_chart/chart/color_template.dart';
import 'package:mp_flutter_chart/chart/utils.dart';

abstract class ChartPainter extends CustomPainter {
  bool _firstDraw = true;

  /// maximum y-value in the y-value array
  double _yMax = 0.0;

  /// the minimum y-value in the y-value array
  double _yMin = 0.0;

  Paint _drawBackgroundPaint;
  TextPainter _descPainter;
  TextPainter _infoPainter;
  TextPainter _valuePainter;

  TextStyle _descTextStyle;
  TextStyle _infoTextStyle;
  TextStyle _valueTextStyle;

  List<Paint> _drawPaints;
  List<Color> _drawColors;

  double _dataWidth = 0.0;
  double _dataHeight = 0.0;
  double _dataLeft;
  double _dataTop;
  double _dataRight;
  double _dataBottom;

  /// flag that indicates if the chart has been fed with data yet
  bool _dataNotSet = true;

  /// the range of y-values the chart displays
  double _deltaY = 1.0;

  /// chart padding to the left
  double _paddingLeft = 30;

  /// chart padding to the top
  double _paddingTop = 20;

  /// chart padding to the right
  double _paddingRight = 30;

  /// chart padding to the bottom
  double _paddingBottom = 20;

  /// list that holds all values of the x-axis
  List<List<String>> _xVals;

  /// list that holds all values of the y-axis
  List<List<double>> _yVals;

  /// description text that appears in the bottom right corner of the chart
  String _description;

  /// if true, circles are drawn at the values position
  bool _drawAdditional;

  /// if true, values are drawn on the chart
  bool _drawValues;

  Color _backgroundColor;

  Color _descriptionColor;
  Color _infoColor;
  Color _valueColor;

  double _descriptionFontSize;
  double _infoFontSize;
  double _valueFontSize;

  ChartPainter(
      {double paddingLeft = 30,
      double paddingTop = 20,
      double paddingRight = 30,
      double paddingBottom = 40,
      List<List<String>> xVals,
      List<List<double>> yVals,
      List<Color> drawColors = null,
      String description = "Description",
      bool drawAdditional = true,
      bool drawValues = true,
      Color backgroundColor = const Color(0xFFFFFFFF),
      Color descriptionColor = const Color(0xFF000000),
      double descriptionFontSize = 12,
      Color infoColor = const Color.fromARGB(255, 247, 189, 51),
      double infoFontSize = 12,
      Color valueColor = const Color.fromARGB(255, 186, 89, 248),
      double valueFontSize = 9})
      : _paddingLeft = paddingLeft,
        _paddingTop = paddingTop,
        _paddingRight = paddingRight,
        _paddingBottom = paddingBottom,
        _xVals = xVals,
        _yVals = yVals,
        _drawColors = drawColors,
        _description = description,
        _drawAdditional = drawAdditional,
        _drawValues = drawValues,
        _backgroundColor = backgroundColor,
        _descriptionColor = descriptionColor,
        _descriptionFontSize = descriptionFontSize,
        _infoColor = infoColor,
        _infoFontSize = infoFontSize,
        _valueColor = valueColor,
        _valueFontSize = valueFontSize {
    _init();
  }

  void _init() {
    // do screen density conversions
    _paddingBottom = Utils.convertDpToPixel(_paddingBottom);
    _paddingLeft = Utils.convertDpToPixel(_paddingLeft);
    _paddingRight = Utils.convertDpToPixel(_paddingRight);
    _paddingTop = Utils.convertDpToPixel(_paddingTop);

    if (_drawColors == null) {
      _drawColors = ColorTemplate.DEFAULT_COLORS;
    }

    _drawBackgroundPaint = Paint()
      ..isAntiAlias = true
      ..color = _backgroundColor;

    _descTextStyle = TextStyle(
        color: _descriptionColor,
        fontSize: Utils.convertDpToPixel(_descriptionFontSize));
    _descPainter = TextPainter(
        text: TextSpan(style: _descTextStyle),
        textDirection: TextDirection.ltr);

    _infoTextStyle = TextStyle(
        color: _infoColor, fontSize: Utils.convertDpToPixel(_infoFontSize));
    _infoPainter = TextPainter(
        text: TextSpan(style: _infoTextStyle),
        textDirection: TextDirection.ltr);

    _valueTextStyle = TextStyle(
        color: _valueColor, fontSize: Utils.convertDpToPixel(_valueFontSize));
    _valuePainter = TextPainter(
        text: TextSpan(style: _valueTextStyle),
        textDirection: TextDirection.ltr);
  }

  void prepare();

  void _calcMinMax() {
    double yMin = double.infinity;
    double yMax = double.negativeInfinity;
    for (var j = 0; j < _yVals.length; j++) {
      for (int i = 0; i < _yVals[j].length; i++) {
        if (_yVals[j][i] < yMin) yMin = _yVals[j][i];
        if (_yVals[j][i] > yMax) yMax = _yVals[j][i];
      }
    }
    _yMin = yMin;
    _yMax = yMax;
    _deltaY = yMin < 0 ? yMax - yMin : yMax;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, _drawBackgroundPaint);

    if (_dataNotSet) {
      // check if there is data
      // if no data, inform the user
      _infoPainter.text =
          TextSpan(text: "No chart data available.", style: _infoTextStyle);
      _infoPainter.layout();
      _infoPainter.paint(
          canvas,
          new Offset(size.width / 2 - _infoPainter.width / 2,
              size.height / 2 - _infoPainter.height / 2));
      return;
    }

    if (_firstDraw) {
      _firstDraw = false;
      firstDraw(size);
    }
  }

  void _drawDescription(Canvas canvas, Size size) {
    _descPainter.text = TextSpan(text: _description, style: _descTextStyle);
    _descPainter.layout();
    _descPainter.paint(
        canvas,
        Offset(size.width - _descPainter.width,
            size.height - _descPainter.height));
  }

  void firstDraw(Size size);

  /// draws all the text-values to the chart
  void drawValues(Canvas canvas, Size size);

  /// draws the actual data
  void drawData(Canvas canvas, Size size);

  /// draws additional stuff, whatever that might be
  void drawAdditional(Canvas canvas, Size size);

  get needDrawValues => _drawValues;

  set needDrawValues(bool drawValues) {
    _drawValues = drawValues;
  }

  get needDrawAdditional => _drawAdditional;

  set needDrawAdditional(bool drawAdditional) {
    _drawAdditional = drawAdditional;
  }

  void setDescriptionTextSize(double size) {
    if (size > 14) size = 14;
    if (size < 7) size = 7;
    _infoTextStyle = TextStyle(
        color: _infoTextStyle.color, fontSize: Utils.convertDpToPixel(size));
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) {
    return oldDelegate._xVals != this._xVals ||
        oldDelegate._yVals != this._yVals;
  }
}

abstract class BarLineChartBasePainter extends ChartPainter {
  bool _drawGrid;
  double _gridWidth;
  double _stepSpace;
  int _yLineSizes;

  Color _gridColor;
  Color _xLegendColor;
  Color _yLegendColor;
  Color _outLineColor;
  Color _gridBackgroundColor;
  double _xLegendFontSize;
  double _yLegendFontSize;
  double _outLineWidth;

  int _maxVisibleCount;
  double _maxVisibleOffset;
  double _zeroYPos = 0.0;
  double _xTotalSize = 0.0;
  double _xPosOffset = 5.3;
  int _curXPos = 0;
  double _xPaintOffset = 0.0;
  bool _drawChartFirst = false;
  int _verticalPosInterval = 1;

  Paint _gridPaint;
  Paint _gridBackgroundPaint;
  Paint _outLinePaint;
  TextPainter _xLegendPaint;
  TextPainter _yLegendPaint;
  TextStyle _xLegendTextStyle;
  TextStyle _yLegendTextStyle;

  /// the decimal format responsible for formatting the y-legend
  NumberFormat _formatYLegend;

  /// the decimalformat responsible for formatting the values in the chart
  NumberFormat _formatValue;

  List<String> _legendNames;

  BarLineChartBasePainter(
      {double xPosOffset = 0,
      double stepSpace = 15,
      double gridWidth = 0.3,
      int yLineSizes = 10,
      bool drawGrid = true,
      Color gridColor = const Color.fromARGB(90, 33, 33, 33),
      Color xLegendColor = const Color(0xFF000000),
      double xLegendFontSize = 9,
      Color yLegendColor = const Color(0xFF000000),
      double yLegendFontSize = 9,
      Color outLineColor = const Color(0xFF000000),
      double outLineWidth = 0.5,
      Color gridBackgroundColor = const Color.fromARGB(255, 240, 240, 240),
      List<String> legendNames,
      double paddingLeft = 30,
      double paddingTop = 20,
      double paddingRight = 30,
      double paddingBottom = 40,
      List<List<String>> xVals,
      List<List<double>> yVals,
      List<Color> drawColors = null,
      String description = "Description",
      bool drawAdditional = true,
      bool drawValues = true,
      Color backgroundColor = const Color(0xFFFFFFFF),
      Color descriptionColor = const Color(0xFF000000),
      double descriptionFontSize = 12,
      Color infoColor = const Color.fromARGB(255, 247, 189, 51),
      double infoFontSize = 12,
      Color valueColor = const Color.fromARGB(255, 186, 89, 248),
      double valueFontSize = 9})
      : _xPosOffset = xPosOffset,
        _drawGrid = drawGrid,
        _gridWidth = gridWidth,
        _stepSpace = stepSpace,
        _yLineSizes = yLineSizes,
        _gridColor = gridColor,
        _xLegendColor = xLegendColor,
        _xLegendFontSize = xLegendFontSize,
        _yLegendColor = yLegendColor,
        _yLegendFontSize = yLegendFontSize,
        _outLineColor = outLineColor,
        _outLineWidth = outLineWidth,
        _gridBackgroundColor = gridBackgroundColor,
        _legendNames = legendNames,
        super(
            paddingLeft: paddingLeft,
            paddingTop: paddingTop,
            paddingRight: paddingRight,
            paddingBottom: paddingBottom,
            xVals: xVals,
            yVals: yVals,
            drawColors: drawColors,
            description: description,
            drawAdditional: drawAdditional,
            drawValues: drawValues,
            backgroundColor: backgroundColor,
            descriptionColor: descriptionColor,
            descriptionFontSize: descriptionFontSize,
            infoColor: infoColor,
            infoFontSize: infoFontSize,
            valueColor: valueColor,
            valueFontSize: valueFontSize) {
    if (xVals == null ||
        xVals.length == 0 ||
        xVals[0].length <= 1 ||
        yVals == null ||
        yVals.length == 0 ||
        yVals[0].length <= 1) {
      _dataNotSet = true;
      return;
    }

    _dataNotSet = false;

    prepare();
  }

  @override
  _init() {
    super._init();
    _xLegendTextStyle = TextStyle(
        color: _xLegendColor,
        fontSize: Utils.convertDpToPixel(_xLegendFontSize));
    _xLegendPaint = TextPainter(
        text: TextSpan(style: _xLegendTextStyle),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);

    _yLegendTextStyle = TextStyle(
        color: _yLegendColor,
        fontSize: Utils.convertDpToPixel(_yLegendFontSize));
    _yLegendPaint = TextPainter(
        text: TextSpan(style: _yLegendTextStyle),
        textAlign: TextAlign.right,
        textDirection: TextDirection.ltr);

    _gridPaint = Paint()
      ..isAntiAlias = true
      ..color = _gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _gridWidth;

    _outLinePaint = Paint()
      ..color = _outLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _outLineWidth;

    _gridBackgroundPaint = Paint()
      ..color = _gridBackgroundColor
      ..style = PaintingStyle.fill;
  }

  @override
  bool shouldRepaint(BarLineChartBasePainter oldDelegate) {
    return super.shouldRepaint(oldDelegate) ||
        oldDelegate._xPosOffset != this._xPosOffset;
  }

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);

    if (_dataNotSet) {
      return;
    }

    /// execute all drawing commands
    _drawOutline(canvas, size);
    _drawGridBackground(canvas, size);

    _drawHorizontalGrid(canvas, size);
    _drawVerticalGrid(canvas, size);
    drawData(canvas, size);
    drawValues(canvas, size);

    _drawXLegend(canvas, size);
    _drawHideAction(canvas, size);
    _drawYLegend(canvas, size);
    drawAdditional(canvas, size);
    _drawDescription(canvas, size);
  }

  @override
  void drawAdditional(Canvas canvas, Size size) {
    _drawLegend(canvas, size);
  }

  void _drawLegend(Canvas canvas, Size size) {
    if (_legendNames.length <= 0) return;

    double bottomCenter = _paddingBottom / 2 + _dataBottom;

    var rectWidth = _yLegendFontSize * 3;
    var offset = 0.0;
    for (int i = 0; i < _legendNames.length; i++) {
      _drawPaints[i].style = PaintingStyle.fill;
      _yLegendPaint.text =
          TextSpan(text: _legendNames[i], style: _yLegendTextStyle);
      _yLegendPaint.layout();
      canvas.drawRect(
          Rect.fromLTRB(
              _dataLeft + offset,
              bottomCenter - _yLegendFontSize / 2,
              _dataLeft + rectWidth + offset,
              bottomCenter + _yLegendFontSize / 2),
          _drawPaints[i]);
      _yLegendPaint.paint(
          canvas,
          Offset(_dataLeft + rectWidth + offset,
              bottomCenter - _yLegendFontSize / 2));
      offset += rectWidth;
      offset += _yLegendPaint.width;
    }
  }

  void _drawHideAction(Canvas canvas, Size size) {
    canvas.drawRect(
        Rect.fromLTRB(0, 0, _dataLeft, size.height), _drawBackgroundPaint);
    canvas.drawRect(Rect.fromLTRB(_dataRight, 0, size.width, size.height),
        _drawBackgroundPaint);
    canvas.drawLine(Offset(_dataLeft, _dataTop), Offset(_dataLeft, _dataBottom),
        _outLinePaint);
    canvas.drawLine(Offset(_dataRight, _dataTop),
        Offset(_dataRight, _dataBottom), _outLinePaint);
  }

  @override
  void firstDraw(Size size) {
    _dataLeft = _paddingLeft;
    _dataTop = _paddingTop;
    _dataRight = size.width - _paddingRight;
    _dataBottom = size.height - _paddingBottom;

    _dataWidth = size.width - _paddingLeft - _paddingRight;
    _dataHeight = size.height - _paddingTop - _paddingBottom;
    if (_yMin < 0 && _yMax > 0) {
      _zeroYPos = _paddingTop + _dataHeight / _deltaY * _yMax;
      _verticalPosInterval = (_yMax - _yMin) ~/ _yLineSizes;
    } else if (_yMax < 0 && _yMax < 0) {
      _zeroYPos = _paddingTop;
      _verticalPosInterval = _yMin ~/ _yLineSizes;
    } else {
      _zeroYPos = size.height - _paddingBottom;
      _verticalPosInterval = _yMax ~/ _yLineSizes;
    }
    _xTotalSize =
        _xVals.length > 0 ? _xVals[0].length * _stepSpace * 2 : size.width;
    _xPaintOffset = _xPosOffset % (2 * _stepSpace);
    _drawChartFirst = _xPaintOffset <= _stepSpace;
    _xPaintOffset =
        _drawChartFirst ? _xPaintOffset : _xPaintOffset - _stepSpace;
    _curXPos = _xPosOffset ~/ (2 * _stepSpace);

    double doubleCount = _dataWidth / _stepSpace;
    _maxVisibleCount = doubleCount.toInt();
    _maxVisibleOffset =
        _dataWidth / doubleCount * (doubleCount - _maxVisibleCount);
  }

  @override
  void drawValues(Canvas canvas, Size size) {
    var position = _curXPos;
    for (int i = 0; i < _maxVisibleCount / 2; i++) {
      double y = _yVals[0][position] * _dataHeight / _deltaY;
      _valuePainter.text = TextSpan(
          text: _formatValue.format(_yVals[0][position++]),
          style: _valueTextStyle);
      _valuePainter.layout();
      var pos = -_xPaintOffset + _dataLeft + i * _stepSpace * 2;
      pos = _drawChartFirst ? pos : pos - _stepSpace;
      if (pos >= _dataLeft && pos <= _dataRight) {
        _valuePainter.paint(
            canvas,
            Offset(pos,
                y < 0 ? _zeroYPos - y : _zeroYPos - y - _valuePainter.height));
      }

      if (!_drawChartFirst &&
          i ==
              (_maxVisibleCount % 2 == 0
                  ? _maxVisibleCount ~/ 2 - 1
                  : _maxVisibleCount ~/ 2) &&
          _yVals[0].length > position &&
          pos + _stepSpace * 2 < _dataRight) {
        pos += _stepSpace * 2;
        y = _yVals[0][position] * _dataHeight / _deltaY;
        _valuePainter.text = TextSpan(
            text: _formatValue.format(_yVals[0][position]),
            style: _valueTextStyle);
        _valuePainter.layout();
        _valuePainter.paint(
            canvas,
            Offset(pos,
                y < 0 ? _zeroYPos - y : _zeroYPos - y - _valuePainter.height));
      }
    }
  }

  @override
  void prepare() {
    if (_dataNotSet) return;
    _calcMinMax();
    // calculate how many digits are needed
    _calcFormats();
  }

  double adjustXPosOffset(double xPosOffset) {
    if (xPosOffset < 0) {
      return 0;
    }

    if (_xTotalSize > _dataWidth && xPosOffset > _xTotalSize - _dataWidth) {
      return _xTotalSize - _dataWidth;
    }

    return xPosOffset;
  }

  void _drawOutline(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTRB(_dataLeft, _dataTop, _dataRight, _dataBottom),
        _outLinePaint);
  }

  void _drawGridBackground(Canvas canvas, Size size) {
    // draw the grid background
    canvas.drawRect(Rect.fromLTRB(_dataLeft, _dataTop, _dataRight, _dataBottom),
        _gridBackgroundPaint);
  }

  void _drawHorizontalGrid(Canvas canvas, Size size) {
    if (!_drawGrid) return;

    Path p = new Path();

    var lineNumbers = _deltaY.ceil();
    var lineSpace = _dataHeight / lineNumbers;

    var upNum = lineNumbers * _zeroYPos ~/ _dataHeight;
    var downNum = lineNumbers - upNum;
    var addNum = 1;

    for (int i = 0; i < upNum + 1; i++) {
      var position = _zeroYPos - i * lineSpace;
      if (position > _dataTop) {
        if (i % _verticalPosInterval == 0) {
          p.reset();
          p.moveTo(_dataLeft, position);
          p.lineTo(_dataRight, position);
          canvas.drawPath(p, _gridPaint);
        }
      } else {
        addNum += 1;
      }
    }

    for (int i = 1; i < downNum + addNum; i++) {
      var position = _zeroYPos + i * lineSpace;
      if (position < _dataBottom) {
        if (i % _verticalPosInterval == 0) {
          p.reset();
          p.moveTo(_dataLeft, position);
          p.lineTo(_dataRight, position);
          canvas.drawPath(p, _gridPaint);
        }
      }
    }
  }

  void _drawVerticalGrid(Canvas canvas, Size size) {
    if (!_drawGrid) return;

    var addLine = false;
    for (int i = 0; i < _maxVisibleCount; i++) {
      var xPos = -_xPaintOffset + _dataLeft + i * _stepSpace;
      if (xPos < _dataLeft) {
        xPos = _dataRight - _xPaintOffset - _maxVisibleOffset;
        addLine = true;
      }
      canvas.drawLine(
          Offset(xPos, _dataTop), Offset(xPos, _dataBottom), _gridPaint);

      if ((addLine && i == 0) || (!addLine && i == _maxVisibleCount - 1)) {
        xPos += _stepSpace;
        if (xPos < _dataRight) {
          canvas.drawLine(
              Offset(xPos, _dataTop), Offset(xPos, _dataBottom), _gridPaint);
        }
      }
    }
  }

  @override
  void _drawXLegend(Canvas canvas, Size size) {
    var position = _curXPos;
    var maxPos = _xVals[0].length - 1;
    if (position > 0) {
      _xLegendPaint.text =
          TextSpan(text: _xVals[0][position - 1], style: _xLegendTextStyle);
      _xLegendPaint.layout();
      var pos = -_xPaintOffset + _dataLeft + (-1) * _stepSpace * 2;
      pos = _drawChartFirst ? pos : pos - _stepSpace;
      _xLegendPaint.paint(canvas,
          Offset(pos + _stepSpace / 2 - _xLegendPaint.width / 2, _zeroYPos));
    }

    for (int i = 0; i < _maxVisibleCount ~/ 2 + 3; i++) {
      if (i > maxPos) {
        break;
      }
      _xLegendPaint.text =
          TextSpan(text: _xVals[0][position], style: _xLegendTextStyle);
      _xLegendPaint.layout();
      var pos = -_xPaintOffset + _dataLeft + i * _stepSpace * 2;
      pos = _drawChartFirst ? pos : pos - _stepSpace;
      _xLegendPaint.paint(canvas,
          Offset(pos + _stepSpace / 2 - _xLegendPaint.width / 2, _zeroYPos));
      position++;
    }
  }

  void _drawYLegend(Canvas canvas, Size size) {
    var lineNumbers = _deltaY.ceil();
    var lineSpace = _dataHeight / lineNumbers;

    var upNum = lineNumbers * _zeroYPos ~/ _dataHeight;
    var downNum = lineNumbers - upNum;
    var addNum = 1;

    for (int i = 0; i < upNum + 1; i++) {
      var position = _zeroYPos - i * lineSpace;

      if (position > _dataTop) {
        if (i % _verticalPosInterval == 0) {
          _yLegendPaint.text = TextSpan(
              text: _formatYLegend.format(i), style: _yLegendTextStyle);
          _yLegendPaint.layout();
          _yLegendPaint.paint(
              canvas, Offset(0, position - _yLegendPaint.height / 2));
        }
      } else {
        addNum += 1;
      }
    }

    for (int i = 1; i < downNum + addNum; i++) {
      var position = _zeroYPos + i * lineSpace;
      if (position < _dataBottom) {
        if (i % _verticalPosInterval == 0) {
          _yLegendPaint.text = TextSpan(
              text: _formatYLegend.format(-i), style: _yLegendTextStyle);
          _yLegendPaint.layout();
          _yLegendPaint.paint(
              canvas, Offset(0, position - _yLegendPaint.height / 2));
        }
      }
    }
  }

  void _calcFormats() {
    _formatYLegend = new NumberFormat("###,###,###,##0.0");

    _formatValue = new NumberFormat("###,###,###,##0.00");
  }

  get needDrawGrid => _drawGrid;

  set needDrawGrid(bool drawGrid) {
    _drawGrid = drawGrid;
  }

  void setXLegendTextSize(double size) {
    if (size > 14) size = 14;
    if (size < 7) size = 7;
    _xLegendTextStyle = TextStyle(
        color: _xLegendTextStyle.color, fontSize: Utils.convertDpToPixel(size));
  }

  void setYLegendTextSize(double size) {
    if (size > 14) size = 14;
    if (size < 7) size = 7;
    _yLegendTextStyle = TextStyle(
        color: _yLegendTextStyle.color, fontSize: Utils.convertDpToPixel(size));
  }

  void setGridColor(Color color) {
    _gridPaint = Paint()
      ..isAntiAlias = true
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _gridWidth;
  }
}

class BarChartPainter extends BarLineChartBasePainter {
  BarChartPainter(
      {double xPosOffset = 0,
      double stepSpace = 15,
      double gridWidth = 0.3,
      int yLineSizes = 10,
      bool drawGrid = true,
      Color gridColor = const Color.fromARGB(90, 33, 33, 33),
      Color xLegendColor = const Color(0xFF000000),
      double xLegendFontSize = 9,
      Color yLegendColor = const Color(0xFF000000),
      double yLegendFontSize = 9,
      Color outLineColor = const Color(0xFF000000),
      double outLineWidth = 0.5,
      Color gridBackgroundColor = const Color.fromARGB(255, 240, 240, 240),
      List<String> legendNames,
      double paddingLeft = 30,
      double paddingTop = 20,
      double paddingRight = 30,
      double paddingBottom = 40,
      List<List<String>> xVals,
      List<List<double>> yVals,
      List<Color> drawColors = null,
      String description = "Description",
      bool drawAdditional = true,
      bool drawValues = true,
      Color backgroundColor = const Color(0xFFFFFFFF),
      Color descriptionColor = const Color(0xFF000000),
      double descriptionFontSize = 12,
      Color infoColor = const Color.fromARGB(255, 247, 189, 51),
      double infoFontSize = 12,
      Color valueColor = const Color.fromARGB(255, 186, 89, 248),
      double valueFontSize = 9})
      : super(
            xPosOffset: xPosOffset,
            stepSpace: stepSpace,
            gridWidth: gridWidth,
            drawGrid: drawGrid,
            yLineSizes: yLineSizes,
            gridColor: gridColor,
            xLegendColor: xLegendColor,
            xLegendFontSize: xLegendFontSize,
            yLegendColor: yLegendColor,
            yLegendFontSize: yLegendFontSize,
            outLineColor: outLineColor,
            outLineWidth: outLineWidth,
            gridBackgroundColor: gridBackgroundColor,
            legendNames: legendNames,
            paddingLeft: paddingLeft,
            paddingTop: paddingTop,
            paddingRight: paddingRight,
            paddingBottom: paddingBottom,
            xVals: xVals,
            yVals: yVals,
            drawColors: drawColors,
            description: description,
            drawAdditional: drawAdditional,
            drawValues: drawValues,
            backgroundColor: backgroundColor,
            descriptionColor: descriptionColor,
            descriptionFontSize: descriptionFontSize,
            infoColor: infoColor,
            infoFontSize: infoFontSize,
            valueColor: valueColor,
            valueFontSize: valueFontSize);

  int _barVisibleCount;

  @override
  void prepare() {
    super.prepare();
    // prepare the paints
    _drawPaints = List<Paint>(_yVals.length);
    for (int i = 0; i < _drawPaints.length; i++) {
      _drawPaints[i] = Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.fill
        ..color = _drawColors[i];
    }
  }

  @override
  void _drawXLegend(Canvas canvas, Size size) {
    if (_yVals.length <= 0) return;

    var paintOffset = _xPosOffset % ((_yVals.length + 1) * _stepSpace);
    var maxPos = _yVals[0].length - 1;
    int offsetPos = _yVals.length ~/ 2;
    var textOffset = _yVals.length % 2 == 0
        ? (offsetPos - 0.5) * _stepSpace
        : offsetPos * _stepSpace;
    int position = _curXPos;
    if (position > 0) {
      _xLegendPaint.text =
          TextSpan(text: _xVals[0][position - 1], style: _xLegendTextStyle);
      _xLegendPaint.layout();
      var pos = -paintOffset +
          _dataLeft +
          (-1) * _stepSpace * (1 + _yVals.length) +
          textOffset;
      _xLegendPaint.paint(canvas,
          Offset(pos + _stepSpace / 2 - _xLegendPaint.width / 2, _zeroYPos));
    }

    for (int i = 0; i < _barVisibleCount ~/ 2 + 3; i++) {
      if (position > maxPos) {
        break;
      }
      _xLegendPaint.text =
          TextSpan(text: _xVals[0][position], style: _xLegendTextStyle);
      _xLegendPaint.layout();
      var pos = -paintOffset +
          _dataLeft +
          i * _stepSpace * (1 + _yVals.length) +
          textOffset;
      _xLegendPaint.paint(canvas,
          Offset(pos + _stepSpace / 2 - _xLegendPaint.width / 2, _zeroYPos));
      position++;
    }
  }

  @override
  void drawValues(Canvas canvas, Size size) {
    if (_yVals.length <= 0) return;

    var paintOffset = _xPosOffset % ((_yVals.length + 1) * _stepSpace);
    var maxPos = _yVals[0].length - 1;
    int position = _curXPos;
    if (position > 0) {
      for (int j = 0; j < _yVals.length; j++) {
        double y = _yVals[j][position - 1] * _dataHeight / _deltaY;
        _valuePainter.text = TextSpan(
            text: _formatValue.format(_yVals[j][position - 1]),
            style: _valueTextStyle);
        _valuePainter.layout();
        double pos = -paintOffset +
            _dataLeft +
            (-1) * _stepSpace * (_yVals.length + 1) +
            j * _stepSpace;
        _valuePainter.paint(
            canvas,
            Offset(pos,
                y < 0 ? _zeroYPos - y : _zeroYPos - y - _valuePainter.height));
      }
    }

    for (int i = 0; i < _barVisibleCount ~/ 2 + 3; i++) {
      if (position > maxPos) {
        break;
      }

      for (int j = 0; j < _yVals.length; j++) {
        double y = _yVals[j][position] * _dataHeight / _deltaY;
        _valuePainter.text = TextSpan(
            text: _formatValue.format(_yVals[j][position]),
            style: _valueTextStyle);
        _valuePainter.layout();
        double pos = -paintOffset +
            _dataLeft +
            i * _stepSpace * (_yVals.length + 1) +
            j * _stepSpace;
        _valuePainter.paint(
            canvas,
            Offset(pos,
                y < 0 ? _zeroYPos - y : _zeroYPos - y - _valuePainter.height));
      }

      position++;
    }
  }

  @override
  void drawData(Canvas canvas, Size size) {
    if (_yVals.length <= 0) return;

    var paintOffset = _xPosOffset % ((_yVals.length + 1) * _stepSpace);
    var maxPos = _yVals[0].length - 1;
    int position = _curXPos;
    if (position > 0) {
      _drawItems(canvas, position - 1, size, -1, paintOffset);
    }

    for (int i = 0; i < _barVisibleCount ~/ 2 + 3; i++) {
      if (position > maxPos) {
        break;
      }
      _drawItems(canvas, position, size, i, paintOffset);
      position++;
    }
  }

  void _drawItems(
      Canvas canvas, int position, Size size, int index, double paintOffset) {
    for (int i = 0; i < _yVals.length; i++) {
      double y = _yVals[i][position] * _dataHeight / _deltaY;

      double pos = -paintOffset +
          _dataLeft +
          index * _stepSpace * (_yVals.length + 1) +
          i * _stepSpace;
      double left = pos;
      double right = left + _stepSpace;
      _drawSingleRect(
          canvas, i, Rect.fromLTRB(left, _zeroYPos - y, right, _zeroYPos));
    }
  }

  void _drawSingleRect(Canvas canvas, int index, Rect rect) {
    Paint paint = _drawPaints[index % _drawPaints.length];
    canvas.drawRect(rect, paint);
  }

  @override
  void firstDraw(Size size) {
    super.firstDraw(size);
    _curXPos = _xPosOffset ~/ ((_yVals.length + 1) * _stepSpace);
    _xTotalSize = _xVals.length > 0
        ? _yVals[0].length * _stepSpace * (_yVals.length + 1)
        : size.width;
    double doubleCount = _dataWidth / _stepSpace;
    _barVisibleCount = doubleCount.toInt();
  }
}

class LineChartPainter extends BarLineChartBasePainter {
  double _lineWidth = 0.8;

  LineChartPainter(
      {double lineWidth = 0.8,
      double xPosOffset = 0,
      double stepSpace = 15,
      double gridWidth = 0.3,
      int yLineSizes = 10,
      bool drawGrid = true,
      Color gridColor = const Color.fromARGB(90, 33, 33, 33),
      Color xLegendColor = const Color(0xFF000000),
      double xLegendFontSize = 9,
      Color yLegendColor = const Color(0xFF000000),
      double yLegendFontSize = 9,
      Color outLineColor = const Color(0xFF000000),
      double outLineWidth = 0.5,
      Color gridBackgroundColor = const Color.fromARGB(255, 240, 240, 240),
      List<String> legendNames,
      double paddingLeft = 30,
      double paddingTop = 20,
      double paddingRight = 30,
      double paddingBottom = 40,
      List<List<String>> xVals,
      List<List<double>> yVals,
      List<Color> drawColors = null,
      String description = "Description",
      bool drawAdditional = true,
      bool drawValues = true,
      Color backgroundColor = const Color(0xFFFFFFFF),
      Color descriptionColor = const Color(0xFF000000),
      double descriptionFontSize = 12,
      Color infoColor = const Color.fromARGB(255, 247, 189, 51),
      double infoFontSize = 12,
      Color valueColor = const Color.fromARGB(255, 186, 89, 248),
      double valueFontSize = 9})
      : _lineWidth = lineWidth,
        super(
            xPosOffset: xPosOffset,
            stepSpace: stepSpace,
            gridWidth: gridWidth,
            drawGrid: drawGrid,
            yLineSizes: yLineSizes,
            gridColor: gridColor,
            xLegendColor: xLegendColor,
            xLegendFontSize: xLegendFontSize,
            yLegendColor: yLegendColor,
            yLegendFontSize: yLegendFontSize,
            outLineColor: outLineColor,
            outLineWidth: outLineWidth,
            gridBackgroundColor: gridBackgroundColor,
            legendNames: legendNames,
            paddingLeft: paddingLeft,
            paddingTop: paddingTop,
            paddingRight: paddingRight,
            paddingBottom: paddingBottom,
            xVals: xVals,
            yVals: yVals,
            drawColors: drawColors,
            description: description,
            drawAdditional: drawAdditional,
            drawValues: drawValues,
            backgroundColor: backgroundColor,
            descriptionColor: descriptionColor,
            descriptionFontSize: descriptionFontSize,
            infoColor: infoColor,
            infoFontSize: infoFontSize,
            valueColor: valueColor,
            valueFontSize: valueFontSize);

  @override
  void drawValues(Canvas canvas, Size size) {
    for (int j = 0; j < _yVals.length; j++) {
      var position = _curXPos;
      var maxPos = _yVals[j].length - 1;
      if (position > 0) {
        double y = _yVals[j][position - 1] * _dataHeight / _deltaY;
        double pos = -_xPaintOffset + _dataLeft + (-1) * _stepSpace * 2;
        _valuePainter.text = TextSpan(
            text: _formatValue.format(_yVals[j][position - 1]),
            style: _valueTextStyle);
        _valuePainter.layout();
        _valuePainter.paint(
            canvas,
            Offset(pos,
                y < 0 ? _zeroYPos - y : _zeroYPos - y - _valuePainter.height));
      }

      for (int i = 0; i < _maxVisibleCount ~/ 2 + 3; i++) {
        if (position > maxPos) {
          break;
        }
        double y = _yVals[j][position] * _dataHeight / _deltaY;
        _valuePainter.text = TextSpan(
            text: _formatValue.format(_yVals[j][position]),
            style: _valueTextStyle);
        _valuePainter.layout();
        var pos = -_xPaintOffset + _dataLeft + i * _stepSpace * 2;
        pos = _drawChartFirst ? pos : pos - _stepSpace;

        _valuePainter.paint(
            canvas,
            Offset(pos,
                y < 0 ? _zeroYPos - y : _zeroYPos - y - _valuePainter.height));
        position++;
      }
    }
  }

  @override
  void drawData(Canvas canvas, Size size) {
    var path = Path();
    for (int j = 0; j < _yVals.length; j++) {
      var isHeaderSet = false;
      path.reset();
      int position = _curXPos;
      var maxPos = _yVals[j].length - 1;
      if (position > 0) {
        double y = _yVals[j][position - 1] * _dataHeight / _deltaY;
        double pos = -_xPaintOffset + _dataLeft + (-1) * _stepSpace * 2;
        double left = _drawChartFirst ? pos : pos - _stepSpace;
        double top = _zeroYPos - y;
        if (!isHeaderSet) {
          path.moveTo(left + _stepSpace / 2, top);
          isHeaderSet = true;
        } else {
          path.lineTo(left + _stepSpace / 2, top);
        }
      }

      for (int i = 0; i < _maxVisibleCount ~/ 2 + 3; i++) {
        if (position > maxPos) {
          break;
        }
        double y = _yVals[j][position] * _dataHeight / _deltaY;
        double pos = -_xPaintOffset + _dataLeft + i * _stepSpace * 2;
        double left = _drawChartFirst ? pos : pos - _stepSpace;
        double top = _zeroYPos - y;
        if (!isHeaderSet) {
          path.moveTo(left + _stepSpace / 2, top);
          isHeaderSet = true;
        } else {
          path.lineTo(left + _stepSpace / 2, top);
        }
        position++;
      }
      canvas.drawPath(path, _drawPaints[j]);
    }
  }

  @override
  void prepare() {
    super.prepare();
    // prepare the paints
    _drawPaints = List<Paint>(_yVals.length);
    for (int i = 0; i < _drawPaints.length; i++) {
      _drawPaints[i] = Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.stroke
        ..strokeWidth = _lineWidth
        ..color = _drawColors[i];
    }
  }
}

class PieChartPainter extends ChartPainter {
  NumberFormat _formatValue;

  PieChartPainter(
      {List<String> pieXVals,
      List<double> pieYVals,
      double paddingLeft = 30,
      double paddingTop = 20,
      double paddingRight = 30,
      double paddingBottom = 40,
      List<Color> drawColors = null,
      String description = "Description",
      bool drawAdditional = true,
      bool drawValues = true,
      Color backgroundColor = const Color(0xFFFFFFFF),
      Color descriptionColor = const Color(0xFF000000),
      double descriptionFontSize = 12,
      Color infoColor = const Color.fromARGB(255, 247, 189, 51),
      double infoFontSize = 12,
      Color valueColor = const Color.fromARGB(255, 0, 0, 0),
      double valueFontSize = 9})
      : super(
            paddingLeft: paddingLeft,
            paddingTop: paddingTop,
            paddingRight: paddingRight,
            paddingBottom: paddingBottom,
            xVals: List()..add(pieXVals),
            yVals: List()..add(pieYVals),
            drawColors: drawColors,
            description: description,
            drawAdditional: drawAdditional,
            drawValues: drawValues,
            backgroundColor: backgroundColor,
            descriptionColor: descriptionColor,
            descriptionFontSize: descriptionFontSize,
            infoColor: infoColor,
            infoFontSize: infoFontSize,
            valueColor: valueColor,
            valueFontSize: valueFontSize) {
    if (pieXVals == null ||
        pieXVals.length == 0 ||
        pieYVals == null ||
        pieYVals.length == 0) {
      _dataNotSet = true;
      return;
    }

    _dataNotSet = false;

    prepare();
  }

  @override
  void drawAdditional(Canvas canvas, Size size) {}

  @override
  void drawData(Canvas canvas, Size size) {
    double startAngle = 0.0;
    double len = (_dataWidth - _dataHeight).abs() / 2;
    Rect rect = _dataWidth > _dataHeight
        ? Rect.fromLTRB(
            _dataLeft + len, _dataTop, _dataRight - len, _dataBottom)
        : Rect.fromLTRB(
            _dataLeft, _dataTop + len, _dataRight, _dataBottom - len);
    for (int i = 0; i < _yVals[0].length; i++) {
      double sweepAngle = _yVals[0][i] / _total * 2 * pi;
      canvas.drawArc(rect, startAngle, sweepAngle, true, _drawPaints[i]);
      startAngle += sweepAngle;
    }

    canvas.drawCircle(
        Offset(_dataLeft + _dataWidth / 2, _dataTop + _dataHeight / 2),
        len,
        _drawBackgroundPaint);
  }

  @override
  void drawValues(Canvas canvas, Size size) {
    double startAngle = 0.0;
    double radius =
        _dataHeight < _dataWidth ? _dataHeight / 4 * 1.5 : _dataWidth / 4 * 1.5;
    double x = (_dataLeft + _dataWidth / 2);
    double y = (_dataTop + _dataHeight / 2);
    for (int i = 0; i < _yVals[0].length; i++) {
      double sweepAngle = _yVals[0][i] / _total * 2 * pi;
      _valuePainter.text = TextSpan(
          text: "${_xVals[0][i]}:${_formatValue.format(_yVals[0][i])}%",
          style: _valueTextStyle);
      _valuePainter.layout();

      double px = x +
          radius * cos(startAngle + sweepAngle / 2) -
          _valuePainter.width / 2;
      double py = y +
          radius * sin(startAngle + sweepAngle / 2) -
          _valuePainter.height / 2;

      _valuePainter.paint(canvas, Offset(px, py));

      startAngle += sweepAngle;
    }
  }

  double _total;

  @override
  void firstDraw(Size size) {
    _dataLeft = _paddingLeft;
    _dataTop = _paddingTop;
    _dataRight = size.width - _paddingRight;
    _dataBottom = size.height - _paddingBottom;

    _dataWidth = size.width - _paddingLeft - _paddingRight;
    _dataHeight = size.height - _paddingTop - _paddingBottom;

    _total = 0.0;
    for (int i = 0; i < _yVals[0].length; i++) {
      _total += _yVals[0][i];
    }
  }

  @override
  void prepare() {
    _formatValue = new NumberFormat("###,###,###,##0.00");
    _drawPaints = List<Paint>(_yVals[0].length);
    for (int i = 0; i < _drawPaints.length; i++) {
      _drawPaints[i] = Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.fill
        ..color = _drawColors[i];
    }
  }

  void _drawDescription(Canvas canvas, Size size) {
    _descPainter.text = TextSpan(text: _description, style: _descTextStyle);
    _descPainter.layout();
    _descPainter.paint(
        canvas,
        Offset(size.width - _descPainter.width,
            size.height - _descPainter.height));
  }

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);

    if (_dataNotSet) return;
    drawData(canvas, size);
    drawValues(canvas, size);
    drawAdditional(canvas, size);
    _drawDescription(canvas, size);
  }
}
