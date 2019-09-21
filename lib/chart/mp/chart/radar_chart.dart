import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis/x_axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis/y_axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/common_interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/chart_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/radar_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/axis_dependency.dart';
import 'package:mp_flutter_chart/chart/mp/core/legend/legend.dart';
import 'package:mp_flutter_chart/chart/mp/core/marker/i_marker.dart';
import 'package:mp_flutter_chart/chart/mp/core/marker/radar_chart_marker.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/data_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/legend_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/painter/painter.dart';
import 'package:mp_flutter_chart/chart/mp/painter/radar_chart_painter.dart';

import 'chart.dart';

class RadarChart extends PieRadarChart {
  double webLineWidth;
  double innerWebLineWidth;
  Color webColor; // = Color.fromARGB(255, 122, 122, 122)
  Color webColorInner; // = Color.fromARGB(255, 122, 122, 122)
  int webAlpha;
  bool drawWeb;
  int skipWebLineCount;
  YAxis yAxis;

  RadarChart(RadarData data,
      {IMarker marker,
      Description description,
      ViewPortHandler viewPortHandler,
      XAxis xAxis,
      Legend legend,
      LegendRenderer legendRenderer,
      DataRenderer renderer,
      OnChartValueSelectedListener selectionListener,
      double rotationAngle = 270,
      double rawRotationAngle = 270,
      bool rotateEnabled = true,
      double minOffset = 30.0,
      double maxHighlightDistance = 0.0,
      bool highLightPerTapEnabled = true,
      bool dragDecelerationEnabled = true,
      double dragDecelerationFrictionCoef = 0.9,
      double extraTopOffset = 0.0,
      double extraRightOffset = 0.0,
      double extraBottomOffset = 0.0,
      double extraLeftOffset = 0.0,
      String noDataText = "No chart data available.",
      bool touchEnabled = true,
      bool drawMarkers = true,
      double descTextSize = 12,
      double infoTextSize = 12,
      Color descTextColor,
      Color infoTextColor,
      double webLineWidth = 1.5,
      double innerWebLineWidth = 0.75,
      Color webColor,
      Color webColorInner,
      int webAlpha = 150,
      bool drawWeb = true,
      int skipWebLineCount = 0,
      YAxis yAxis})
      : webLineWidth = webLineWidth,
        innerWebLineWidth = innerWebLineWidth,
        webAlpha = webAlpha,
        drawWeb = drawWeb,
        skipWebLineCount = skipWebLineCount,
        webColorInner = webColorInner,
        webColor = webColor,
        super(data,
            marker: marker,
            description: description,
            viewPortHandler: viewPortHandler,
            xAxis: xAxis,
            legend: legend,
            legendRenderer: legendRenderer,
            selectionListener: selectionListener,
            maxHighlightDistance: maxHighlightDistance,
            highLightPerTapEnabled: highLightPerTapEnabled,
            dragDecelerationEnabled: dragDecelerationEnabled,
            dragDecelerationFrictionCoef: dragDecelerationFrictionCoef,
            extraTopOffset: extraTopOffset,
            extraRightOffset: extraRightOffset,
            extraBottomOffset: extraBottomOffset,
            extraLeftOffset: extraLeftOffset,
            noDataText: noDataText,
            touchEnabled: touchEnabled,
            drawMarkers: drawMarkers,
            descTextSize: descTextSize,
            infoTextSize: infoTextSize,
            descTextColor: descTextColor,
            infoTextColor: infoTextColor,
            rotationAngle: rotationAngle,
            rawRotationAngle: rawRotationAngle,
            rotateEnabled: rotateEnabled,
            minOffset: minOffset) {
    this.webColor ??= Color.fromARGB(255, 122, 122, 122);
    this.webColorInner ??= Color.fromARGB(255, 122, 122, 122);
    this.yAxis ??= YAxis(position: AxisDependency.LEFT);
  }

  @override
  IMarker initMarker() => RadarChartMarker();

  @override
  ChartState<ChartPainter<ChartData<IDataSet<Entry>>>, Chart>
      createChartState() {
    return RadarChartState();
  }

  RadarChartPainter get painter => super.painter;
}

class RadarChartState
    extends PieRadarChartState<RadarChartPainter, RadarChart> {
  @override
  void initialPainter() {
    painter = RadarChartPainter(
        widget.data,
        animator,
        widget.viewPortHandler,
        widget.maxHighlightDistance,
        widget.highLightPerTapEnabled,
        widget.dragDecelerationEnabled,
        widget.dragDecelerationFrictionCoef,
        widget.extraLeftOffset,
        widget.extraTopOffset,
        widget.extraRightOffset,
        widget.extraBottomOffset,
        widget.noDataText,
        widget.touchEnabled,
        widget.marker,
        widget.description,
        widget.drawMarkers,
        widget.infoPaint,
        widget.descPaint,
        widget.xAxis,
        widget.legend,
        widget.legendRenderer,
        widget.selectionListener,
        widget.rotationAngle,
        widget.rawRotationAngle,
        widget.rotateEnabled,
        widget.minOffset,
        widget.webLineWidth,
        widget.innerWebLineWidth,
        widget.webColor,
        widget.webColorInner,
        widget.webAlpha,
        widget.drawWeb,
        widget.skipWebLineCount,
        widget.yAxis);
    if (painter.getData() != null &&
        painter.getData().dataSets != null &&
        painter.getData().dataSets.length > 0)
      painter.highlightValue6(lastHighlighted, false);
  }
}
