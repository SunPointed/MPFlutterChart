import 'dart:ui';

import 'package:mp_flutter_chart/chart/mp/core/axis/x_axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/common_interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/chart_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/pie_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/legend/legend.dart';
import 'package:mp_flutter_chart/chart/mp/core/marker/bar_chart_marker.dart';
import 'package:mp_flutter_chart/chart/mp/core/marker/i_marker.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/data_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/legend_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/painter/painter.dart';
import 'package:mp_flutter_chart/chart/mp/painter/pie_chart_painter.dart';

import 'chart.dart';

class PieChart extends PieRadarChart {
  bool drawEntryLabels;
  bool drawHole;
  bool drawSlicesUnderHole;
  bool usePercentValues;
  bool drawRoundedSlices;
  String centerText;
  double holeRadiusPercent; // = 50
  double transparentCircleRadiusPercent; //= 55
  bool drawCenterText; // = true
  double centerTextRadiusPercent; // = 100.0
  double maxAngle; // = 360
  double minAngleForSlices; // = 0

  PieChart(PieData data,
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
      bool drawEntryLabels = true,
      bool drawHole = true,
      bool drawSlicesUnderHole = false,
      bool usePercentValues = false,
      bool drawRoundedSlices = false,
      String centerText = "",
      double holeRadiusPercent = 50,
      double transparentCircleRadiusPercent = 55,
      bool drawCenterText = true,
      double centerTextRadiusPercent = 100.0,
      double maxAngle = 360,
      double minAngleForSlices = 0})
      : drawCenterText = drawCenterText,
        drawEntryLabels = drawEntryLabels,
        drawHole = drawHole,
        drawSlicesUnderHole = drawSlicesUnderHole,
        usePercentValues = usePercentValues,
        drawRoundedSlices = drawRoundedSlices,
        holeRadiusPercent = holeRadiusPercent,
        transparentCircleRadiusPercent = transparentCircleRadiusPercent,
        centerTextRadiusPercent = centerTextRadiusPercent,
        centerText = centerText,
        maxAngle = maxAngle,
        minAngleForSlices = minAngleForSlices,
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
            minOffset: minOffset);

  @override
  IMarker initMarker() => BarChartMarker();

  @override
  ChartState<ChartPainter<ChartData<IDataSet<Entry>>>, Chart>
      createChartState() {
    return PieChartState();
  }

  PieChartPainter get painter => super.painter;
}

class PieChartState extends PieRadarChartState<PieChartPainter, PieChart> {
  @override
  void initialPainter() {
    painter = PieChartPainter(
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
      widget.drawEntryLabels,
      widget.drawHole,
      widget.drawSlicesUnderHole,
      widget.usePercentValues,
      widget.drawRoundedSlices,
      widget.centerText,
      widget.holeRadiusPercent,
      widget.transparentCircleRadiusPercent,
      widget.drawCenterText,
      widget.centerTextRadiusPercent,
      widget.maxAngle,
      widget.minAngleForSlices,
    );
    if (painter.getData() != null &&
        painter.getData().dataSets != null &&
        painter.getData().dataSets.length > 0)
      painter.highlightValue6(lastHighlighted, false);
  }
}
