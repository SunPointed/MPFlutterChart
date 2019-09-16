import 'package:flutter/painting.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/chart_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/i_highlighter.dart';
import 'package:mp_flutter_chart/chart/mp/core/marker/i_marker.dart';
import 'package:mp_flutter_chart/chart/mp/core/marker/radar_chart_marker.dart';
import 'package:mp_flutter_chart/chart/mp/painter/painter.dart';
import 'package:mp_flutter_chart/chart/mp/painter/radar_chart_painter.dart';

import 'chart.dart';

class RadarChart extends PieRadarChart {
  double webLineWidth;
  double innerWebLineWidth;
  int webAlpha;
  bool drawWeb;
  int skipWebLineCount;
  double rotationAngle;
  double rawRotationAngle;
  bool rotateEnabled;

  RadarChart(ChartData<IDataSet<Entry>> data,
      InitRadarChartPainterCallback initRadarChartPainterCallback,
      {double webLineWidth = 2.5,
      double innerWebLineWidth = 1.5,
      int webAlpha = 150,
      bool drawWeb = true,
      int skipWebLineCount = 0,
      double rotationAngle = 270,
      double rawRotationAngle = 270,
      bool rotateEnabled = true,
      double minOffset = 30,
      double maxHighlightDistance = 0.0,
      bool highLightPerTapEnabled = true,
      bool dragDecelerationEnabled = true,
      double dragDecelerationFrictionCoef = 0.9,
      double extraLeftOffset = 0.0,
      double extraTopOffset = 0.0,
      double extraRightOffset = 0.0,
      double extraBottomOffset = 0.0,
      String noDataText = "No chart data available.",
      bool touchEnabled = true,
      IMarker marker = null,
      Description desc = null,
      bool drawMarkers = true,
      TextPainter infoPainter = null,
      TextPainter descPainter = null,
      IHighlighter highlighter = null,
      bool unbind = false})
      : webLineWidth = webLineWidth,
        innerWebLineWidth = innerWebLineWidth,
        webAlpha = webAlpha,
        drawWeb = drawWeb,
        skipWebLineCount = skipWebLineCount,
        rotationAngle = rotationAngle,
        rawRotationAngle = rawRotationAngle,
        rotateEnabled = rotateEnabled,
        super(data, (p) {
          if (p is RadarChartPainter) {
            initRadarChartPainterCallback(p);
          }
        },
            maxHighlightDistance: maxHighlightDistance,
            highLightPerTapEnabled: highLightPerTapEnabled,
            dragDecelerationEnabled: dragDecelerationEnabled,
            dragDecelerationFrictionCoef: dragDecelerationFrictionCoef,
            extraLeftOffset: extraLeftOffset,
            extraTopOffset: extraTopOffset,
            extraRightOffset: extraRightOffset,
            extraBottomOffset: extraBottomOffset,
            touchEnabled: touchEnabled,
            noDataText: noDataText,
            marker: marker,
            desc: desc,
            drawMarkers: drawMarkers,
            infoPainter: infoPainter,
            descPainter: descPainter,
            highlighter: highlighter,
            unbind: unbind) {
    this.marker = RadarChartMarker();
  }

  @override
  ChartState<ChartPainter<ChartData<IDataSet<Entry>>>, Chart> createChartState() {
    return RadarChartState();
  }
}

class RadarChartState
    extends PieRadarChartState<RadarChartPainter, RadarChart> {
  @override
  void initialPainter() {
    painter = RadarChartPainter(widget.data,
        viewPortHandler: widget.viewPortHandler,
        animator: animator,
        webLineWidth: widget.webLineWidth,
        innerWebLineWidth: widget.innerWebLineWidth,
        webAlpha: widget.webAlpha,
        drawWeb: widget.drawWeb,
        skipWebLineCount: widget.skipWebLineCount,
        rotationAngle: widget.rotationAngle,
        rawRotationAngle: widget.rawRotationAngle,
        rotateEnabled: widget.rotateEnabled,
        minOffset: widget.minOffset,
        maxHighlightDistance: widget.maxHighlightDistance,
        highLightPerTapEnabled: widget.highLightPerTapEnabled,
        dragDecelerationEnabled: widget.dragDecelerationEnabled,
        dragDecelerationFrictionCoef: widget.dragDecelerationFrictionCoef,
        extraLeftOffset: widget.extraLeftOffset,
        extraTopOffset: widget.extraTopOffset,
        extraRightOffset: widget.extraRightOffset,
        extraBottomOffset: widget.extraBottomOffset,
        noDataText: widget.noDataText,
        touchEnabled: widget.touchEnabled,
        marker: widget.marker,
        desc: widget.desc,
        drawMarkers: widget.drawMarkers,
        infoPainter: widget.infoPainter,
        descPainter: widget.descPainter,
        highlighter: widget.highlighter,
        unbind: widget.unbind);
    painter.highlightValue6(lastHighlighted, false);
  }
}

typedef InitRadarChartPainterCallback = void Function(
    RadarChartPainter painter);
