import 'dart:math';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:mp_chart/mp/core/bounds.dart';
import 'package:mp_chart/mp/core/animator.dart';
import 'package:mp_chart/mp/core/data/filled_line_data.dart';
import 'package:mp_chart/mp/core/data_provider/filled_line_data_provider.dart';
import 'package:mp_chart/mp/core/data_set/filled_line_data_set.dart';
import 'package:mp_chart/mp/core/entry/entry.dart';
import 'package:mp_chart/mp/core/transformer/transformer.dart';
import 'package:mp_chart/mp/core/view_port.dart';


import 'line_chart_renderer.dart';

class FilledLineChartRenderer extends LineChartRenderer {
  FilledLineDataProvider _provider;

  Path _cubicPath = Path();
  Path _cubicFillPath = Path();

  FilledLineChartRenderer(FilledLineDataProvider chart, Animator animator,
      ViewPortHandler viewPortHandler)
      : super(chart, animator, viewPortHandler) {
    _provider = chart;
  }

  FilledLineDataProvider get provider => _provider;

  @override
  void initBuffers() {}

  @override
  void drawData(Canvas c) {
    FilledLineData filledLineData = getFilledData();

    for (FilledLineDataSet set in filledLineData.dataSets) {
      if (set.isVisible()) drawFilledDataSet(c, set);
    }
  }

  void drawFilledDataSet(Canvas c, FilledLineDataSet dataSet) {
    if (dataSet.getEntryCount() < 1) return;
    renderPaint..strokeWidth = dataSet.getLineWidth();
    drawFilledCubicBezier(c, dataSet);
  }

  void drawFilledCubicBezier(Canvas canvas, FilledLineDataSet dataSet) {
    double phaseY = animator.getPhaseY();

    Transformer trans = _provider.getTransformer(dataSet.getAxisDependency());

    xBounds.set(_provider, dataSet);

    double intensity = dataSet.getCubicIntensity();

    List<double> list = List();
    List<double> backList = List();

    if (xBounds.range >= 1) {
      fillDataPoints(dataSet.highLevelEntries, list, intensity, phaseY);
      fillDataPoints(dataSet.lowLevelEntries, backList, intensity, phaseY);
    }

    if (list.length <= 0) {
      return;
    }

    renderPaint
      ..color = dataSet.getColor1()
      ..style = PaintingStyle.stroke;

    trans.pointValuesToPixel(list);
    trans.pointValuesToPixel(backList);

    _cubicPath.reset();
    _cubicFillPath.reset();

    _cubicPath.moveTo(list[0], list[1]);
    _cubicFillPath.moveTo(list[0], list[1]);
    backList = backList.reversed.toList();

    for(int i = 0; i < list.length; i += 2) {
      _cubicPath.lineTo(list[i], list[i+1]);
      _cubicFillPath.lineTo(list[i], list[i+1]);
    }

    for(int i = 0; i < backList.length; i += 2) {
      _cubicPath.lineTo(backList[i+1], backList[i]);
      _cubicFillPath.lineTo(backList[i+1], backList[i]);
    }



    drawFilledCubicFill(canvas, dataSet, _cubicFillPath, trans, xBounds);


    if (dataSet.getDashPathEffect() != null) {
      _cubicPath = dataSet.getDashPathEffect().convert2DashPath(_cubicPath);
    }
    canvas.drawPath(_cubicPath, renderPaint);
  }


  void fillDataPoints(List<Entry> entries, List<double> points, double intensity, double phaseY) {
    double prevDx = 0;
    double prevDy = 0;
    double curDx = 0;
    double curDy = 0;

    final int firstIndex = xBounds.min + 1;

    Entry prevPrev;
    Entry prev = entries[max(firstIndex - 2, 0)];
    Entry cur = entries[max(firstIndex - 1, 0)];
    Entry next = cur;
    int nextIndex = -1;

    if (cur == null) return;

    points.add(cur.x);
    points.add(cur.y * phaseY);

    for (int j = xBounds.min + 1; j <= xBounds.range + xBounds.min; j++) {
      prevPrev = prev;
      prev = cur;
      cur = nextIndex == j ? next : entries[j];

      nextIndex = j + 1 < entries.length ? j + 1 : j;
      next = entries[nextIndex];

      prevDx = (cur.x - prevPrev.x) * intensity;
      prevDy = (cur.y - prevPrev.y) * intensity;
      curDx = (next.x - prev.x) * intensity;
      curDy = (next.y - prev.y) * intensity;

      points.add(prev.x + prevDx);
      points.add((prev.y + prevDy) * phaseY);
      points.add(cur.x - curDx);
      points.add((cur.y - curDy) * phaseY);
      points.add(cur.x);
      points.add(cur.y * phaseY);
    }
  }

  void drawFilledCubicFill(Canvas c, FilledLineDataSet dataSet, Path spline,
      Transformer trans, XBounds bounds) {
    spline.close();


    if (dataSet.isGradientEnabled()) {
      drawFilledPath3(c, spline, dataSet.getGradientColor1().startColor.value,
          dataSet.getGradientColor1().endColor.value, dataSet.getFillAlpha());
    } else {

      drawFilledPath2(
          c, spline, dataSet.getFillColor().value, dataSet.getFillAlpha());
    }
  }


  FilledLineData getFilledData() {
    return _provider.getFilledLineData();
  }

  @override
  void drawExtras(Canvas c) {}

  @override
  void drawValues(Canvas c) {}
}
