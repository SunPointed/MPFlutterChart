import 'package:mp_chart/mp/chart/bar_chart.dart';
import 'package:mp_chart/mp/controller/horizontal_bar_chart_controller.dart';
import 'package:mp_chart/mp/painter/horizontal_bar_chart_painter.dart';

class HorizontalBarChart extends BarChart {
  HorizontalBarChart(HorizontalBarChartController controller)
      : super(controller);

  @override
  HorizontalBarChartState createChartState() {
    return HorizontalBarChartState();
  }

  HorizontalBarChartPainter get painter => super.painter;

  @override
  void initialPainter() {
    painter = HorizontalBarChartPainter(
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
}

class HorizontalBarChartState extends BarChartState<HorizontalBarChart> {
  @override
  void updatePainter() {
    if (widget.painter.getData() != null &&
        widget.painter.getData().dataSets != null &&
        widget.painter.getData().dataSets.length > 0)
      widget.painter.highlightValue6(lastHighlighted, false);
  }
}
