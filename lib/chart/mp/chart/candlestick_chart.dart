import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:mp_flutter_chart/chart/mp/chart/chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis/x_axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis/y_axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/common_interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/candle_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/chart_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/legend/legend.dart';
import 'package:mp_flutter_chart/chart/mp/core/marker/i_marker.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/data_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/legend_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/x_axis_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/y_axis_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/transformer/transformer.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/painter/candlestick_chart_painter.dart';
import 'package:mp_flutter_chart/chart/mp/painter/painter.dart';

class CandlestickChart extends BarLineScatterCandleBubbleChart {
  CandlestickChart(CandleData data,
      {IMarker marker,
      Description description,
      ViewPortHandler viewPortHandler,
      XAxis xAxis,
      Legend legend,
      LegendRenderer legendRenderer,
      DataRenderer renderer,
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
      OnDrawListener drawListener,
      YAxis axisLeft,
      YAxis axisRight,
      YAxisRenderer axisRendererLeft,
      YAxisRenderer axisRendererRight,
      Transformer leftAxisTransformer,
      Transformer rightAxisTransformer,
      XAxisRenderer xAxisRenderer,
      Matrix4 zoomMatrixBuffer})
      : super(data,
            marker: marker,
            description: description,
            viewPortHandler: viewPortHandler,
            xAxis: xAxis,
            legend: legend,
            legendRenderer: legendRenderer,
            renderer: renderer,
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
  ChartState<ChartPainter<ChartData<IDataSet<Entry>>>, Chart>
      createChartState() {
    return CandlestickChartState();
  }
}

class CandlestickChartState extends BarLineScatterCandleBubbleState<
    CandlestickChartPainter, CandlestickChart> {
  @override
  void initialPainter() {
    painter = CandlestickChartPainter(
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
        widget.maxVisibleCount,
        widget.autoScaleMinMaxEnabled,
        widget.pinchZoomEnabled,
        widget.doubleTapToZoomEnabled,
        widget.highlightPerDragEnabled,
        widget.dragXEnabled,
        widget.dragYEnabled,
        widget.scaleXEnabled,
        widget.scaleYEnabled,
        widget.gridBackgroundPaint,
        widget.borderPaint,
        widget.drawGridBackground,
        widget.drawBorders,
        widget.clipValuesToContent,
        widget.minOffset,
        widget.keepPositionOnRotation,
        widget.drawListener,
        widget.axisLeft,
        widget.axisRight,
        widget.axisRendererLeft,
        widget.axisRendererRight,
        widget.leftAxisTransformer,
        widget.rightAxisTransformer,
        widget.xAxisRenderer,
        widget.zoomMatrixBuffer,
        widget.customViewPortEnabled,
        widget.minXRange,
        widget.maxXRange,
        widget.minimumScaleX,
        widget.minimumScaleY);
    if (painter.getData() != null &&
        painter.getData().getDataSets() != null &&
        painter.getData().getDataSets().length > 0)
      painter.highlightValue6(lastHighlighted, false);
  }
}
