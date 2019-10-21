import 'package:mp_chart/mp/chart/bar_line_scatter_candle_bubble_chart.dart';
import 'package:mp_chart/mp/controller/bar_chart_controller.dart';
import 'package:mp_chart/mp/painter/bar_chart_painter.dart';

class BarChart extends BarLineScatterCandleBubbleChart<BarChartPainter,
    BarChartController> {
  BarChart(BarChartController controller) : super(controller);

  @override
  BarLineScatterCandleBubbleState<BarChart> createChartState() {
    return BarLineScatterCandleBubbleState<BarChart>();
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
        controller.backgroundPaint,
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
        controller.highlightFullBarEnabled,
        controller.drawValueAboveBar,
        controller.drawBarShadow,
        controller.fitBars);
  }

  BarChartPainter get painter => super.painter;
}
