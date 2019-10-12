import 'package:mp_chart/mp/chart/bar_line_scatter_candle_bubble_chart.dart';
import 'package:mp_chart/mp/controller/bar_chart_controller.dart';
import 'package:mp_chart/mp/core/data/bar_data.dart';
import 'package:mp_chart/mp/painter/bar_chart_painter.dart';

class BarChart extends BarLineScatterCandleBubbleChart<BarChartPainter,
    BarChartController> {
  BarChart(BarChartController controller) : super(controller);

  @override
  BarChartState createChartState() {
    return BarChartState();
  }

  void groupBars(double fromX, double groupSpace, double barSpace) {
    if (controller.data == null) {
      throw Exception(
          "You need to set data for the chart before grouping bars.");
    } else {
      (controller.data as BarData).groupBars(fromX, groupSpace, barSpace);
    }
  }

  @override
  void initialPainter() {
    painter = BarChartPainter(
        controller.data,
        animator,
        controller.viewPortHandler,
        controller.maxHighlightDistance,
        controller.highLightPerTapEnabled,
        controller.extraLeftOffset,
        controller.extraTopOffset,
        controller.extraRightOffset,
        controller.extraBottomOffset,
        controller.marker,
        controller.description,
        controller.drawMarkers,
        controller.infoPaint,
        controller.descPaint,
        controller.xAxis,
        controller.legend,
        controller.legendRenderer,
        controller.rendererSettingFunction,
        controller.selectionListener,
        controller.maxVisibleCount,
        controller.autoScaleMinMaxEnabled,
        controller.pinchZoomEnabled,
        controller.doubleTapToZoomEnabled,
        controller.highlightPerDragEnabled,
        controller.dragXEnabled,
        controller.dragYEnabled,
        controller.scaleXEnabled,
        controller.scaleYEnabled,
        controller.gridBackgroundPaint,
        controller.backgroundColor,
        controller.borderPaint,
        controller.drawGridBackground,
        controller.drawBorders,
        controller.clipValuesToContent,
        controller.minOffset,
        controller.keepPositionOnRotation,
        controller.drawListener,
        controller.axisLeft,
        controller.axisRight,
        controller.axisRendererLeft,
        controller.axisRendererRight,
        controller.leftAxisTransformer,
        controller.rightAxisTransformer,
        controller.xAxisRenderer,
        controller.zoomMatrixBuffer,
        controller.customViewPortEnabled,
        controller.minXRange,
        controller.maxXRange,
        controller.minimumScaleX,
        controller.minimumScaleY,
        controller.highlightFullBarEnabled,
        controller.drawValueAboveBar,
        controller.drawBarShadow,
        controller.fitBars);
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
