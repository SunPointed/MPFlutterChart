import 'package:mp_chart/mp/chart/bar_line_scatter_candle_bubble_chart.dart';
import 'package:mp_chart/mp/controller/bubble_chart_controller.dart';
import 'package:mp_chart/mp/painter/bubble_chart_painter.dart';

class BubbleChart extends BarLineScatterCandleBubbleChart<BubbleChartPainter,
    BubbleChartController> {
  BubbleChart(BubbleChartController controller) : super(controller);

  @override
  BubbleChartState createChartState() {
    return BubbleChartState();
  }

  BubbleChartPainter get painter => super.painter;

  @override
  void initialPainter() {
    painter = BubbleChartPainter(
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
        controller.minimumScaleY);
  }
}

class BubbleChartState extends BarLineScatterCandleBubbleState<BubbleChart> {
  @override
  void updatePainter() {
    if (widget.painter.getData() != null &&
        widget.painter.getData().dataSets != null &&
        widget.painter.getData().dataSets.length > 0)
      widget.painter.highlightValue6(lastHighlighted, false);
  }
}
