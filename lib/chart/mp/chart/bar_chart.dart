import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/chart/bar_line_scatter_candle_bubble_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis/y_axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/common_interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/bar_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/functions.dart';
import 'package:mp_flutter_chart/chart/mp/core/marker/bar_chart_marker.dart';
import 'package:mp_flutter_chart/chart/mp/core/marker/i_marker.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/x_axis_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/y_axis_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/transformer/transformer.dart';
import 'package:mp_flutter_chart/chart/mp/painter/bar_chart_painter.dart';

class BarChart extends BarLineScatterCandleBubbleChart<BarChartPainter> {
  bool highlightFullBarEnabled;
  bool drawValueAboveBar;
  bool drawBarShadow;
  bool fitBars;

  BarChart(BarData data,
      {IMarker marker,
      Description description,
      AxisLeftSettingFunction axisLeftSettingFunction,
      AxisRightSettingFunction axisRightSettingFunction,
      XAxisSettingFunction xAxisSettingFunction,
      LegendSettingFunction legendSettingFunction,
      DataRendererSettingFunction rendererSettingFunction,
      OnChartValueSelectedListener selectionListener,
      Color backgroundColor,
      Color borderColor,
      double borderStrokeWidth = 1.0,
      int maxVisibleCount = 100,
      bool autoScaleMinMaxEnabled = true,
      bool pinchZoomEnabled = true,
      bool doubleTapToZoomEnabled = true,
      bool highlightPerDragEnabled = true,
      bool dragXEnabled = true,
      bool dragYEnabled = true,
      bool scaleXEnabled = true,
      bool scaleYEnabled = true,
      bool drawGridBackground = false,
      bool drawBorders = false,
      bool clipValuesToContent = false,
      double minOffset = 30,
      bool keepPositionOnRotation = false,
      bool customViewPortEnabled = false,
      double minXRange = 1.0,
      double maxXRange = 1.0,
      double minimumScaleX = 1.0,
      double minimumScaleY = 1.0,
      double maxHighlightDistance = 100.0,
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
      OnDrawListener drawListener,
      YAxis axisLeft,
      YAxis axisRight,
      YAxisRenderer axisRendererLeft,
      YAxisRenderer axisRendererRight,
      Transformer leftAxisTransformer,
      Transformer rightAxisTransformer,
      XAxisRenderer xAxisRenderer,
      Matrix4 zoomMatrixBuffer,
      bool highlightFullBarEnabled = true,
      bool drawValueAboveBar = false,
      bool drawBarShadow = false,
      bool fitBars = true})
      : highlightFullBarEnabled = highlightFullBarEnabled,
        drawValueAboveBar = drawValueAboveBar,
        drawBarShadow = drawBarShadow,
        fitBars = fitBars,
        super(data,
            backgroundColor: backgroundColor,
            marker: marker,
            description: description,
            axisLeftSettingFunction: axisLeftSettingFunction,
            axisRightSettingFunction: axisRightSettingFunction,
            xAxisSettingFunction: xAxisSettingFunction,
            legendSettingFunction: legendSettingFunction,
            rendererSettingFunction: rendererSettingFunction,
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
            maxVisibleCount: maxVisibleCount,
            autoScaleMinMaxEnabled: autoScaleMinMaxEnabled,
            pinchZoomEnabled: pinchZoomEnabled,
            doubleTapToZoomEnabled: doubleTapToZoomEnabled,
            highlightPerDragEnabled: highlightPerDragEnabled,
            dragXEnabled: dragXEnabled,
            dragYEnabled: dragYEnabled,
            scaleXEnabled: scaleXEnabled,
            scaleYEnabled: scaleYEnabled,
            drawGridBackground: drawGridBackground,
            drawBorders: drawBorders,
            clipValuesToContent: clipValuesToContent,
            minOffset: minOffset,
            keepPositionOnRotation: keepPositionOnRotation,
            drawListener: drawListener,
            axisLeft: axisLeft,
            axisRight: axisRight,
            axisRendererLeft: axisRendererLeft,
            axisRendererRight: axisRendererRight,
            leftAxisTransformer: leftAxisTransformer,
            rightAxisTransformer: rightAxisTransformer,
            xAxisRenderer: xAxisRenderer,
            customViewPortEnabled: customViewPortEnabled,
            zoomMatrixBuffer: zoomMatrixBuffer,
            minXRange: minXRange,
            maxXRange: maxXRange,
            minimumScaleX: minimumScaleX,
            minimumScaleY: minimumScaleY);

  @override
  BarChartState createChartState() {
    return BarChartState();
  }

  @override
  IMarker initMarker() => BarChartMarker();

  void groupBars(double fromX, double groupSpace, double barSpace) {
    if (data == null) {
      throw Exception(
          "You need to set data for the chart before grouping bars.");
    } else {
      (data as BarData).groupBars(fromX, groupSpace, barSpace);
    }
  }

  @override
  void initialPainter() {
    painter = BarChartPainter(
        data,
        animator,
        viewPortHandler,
        maxHighlightDistance,
        highLightPerTapEnabled,
        dragDecelerationEnabled,
        dragDecelerationFrictionCoef,
        extraLeftOffset,
        extraTopOffset,
        extraRightOffset,
        extraBottomOffset,
        noDataText,
        touchEnabled,
        marker,
        description,
        drawMarkers,
        infoPaint,
        descPaint,
        xAxis,
        legend,
        legendRenderer,
        rendererSettingFunction,
        selectionListener,
        maxVisibleCount,
        autoScaleMinMaxEnabled,
        pinchZoomEnabled,
        doubleTapToZoomEnabled,
        highlightPerDragEnabled,
        dragXEnabled,
        dragYEnabled,
        scaleXEnabled,
        scaleYEnabled,
        gridBackgroundPaint,
        borderPaint,
        drawGridBackground,
        drawBorders,
        clipValuesToContent,
        minOffset,
        keepPositionOnRotation,
        drawListener,
        axisLeft,
        axisRight,
        axisRendererLeft,
        axisRendererRight,
        leftAxisTransformer,
        rightAxisTransformer,
        xAxisRenderer,
        zoomMatrixBuffer,
        customViewPortEnabled,
        minXRange,
        maxXRange,
        minimumScaleX,
        minimumScaleY,
        highlightFullBarEnabled,
        drawValueAboveBar,
        drawBarShadow,
        fitBars);
  }

  BarChartPainter get painter => super.painter;
}

class BarChartState<T extends BarChart>
    extends BarLineScatterCandleBubbleState<T> {
  @override
  void updatePainter() {
    if (widget.painter.getData() != null &&
        widget.painter.getData().dataSets != null &&
        widget.painter.getData().dataSets.length > 0)
      widget.painter.highlightValue6(lastHighlighted, false);
  }
}
