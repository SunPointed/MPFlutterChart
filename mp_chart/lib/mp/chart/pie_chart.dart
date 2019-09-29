import 'package:mp_chart/mp/chart/pie_radar_chart.dart';
import 'package:mp_chart/mp/controller/pie_chart_controller.dart';
import 'package:mp_chart/mp/painter/pie_chart_painter.dart';

class PieChart extends PieRadarChart<PieChartPainter, PieChartController> {
  PieChart(PieChartController controller) : super(controller);

  @override
  PieChartState createChartState() {
    return PieChartState();
  }

  PieChartPainter get painter => super.painter;

  @override
  void initialPainter() {
    painter = PieChartPainter(
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
      controller.rotationAngle,
      controller.rawRotationAngle,
      controller.rotateEnabled,
      controller.minOffset,
      controller.drawEntryLabels,
      controller.drawHole,
      controller.drawSlicesUnderHole,
      controller.usePercentValues,
      controller.drawRoundedSlices,
      controller.centerText,
      controller.centerTextOffsetX,
      controller.centerTextOffsetY,
      controller.entryLabelTypeface,
      controller.centerTextTypeface,
      controller.holeRadiusPercent,
      controller.transparentCircleRadiusPercent,
      controller.drawCenterText,
      controller.centerTextRadiusPercent,
      controller.maxAngle,
      controller.minAngleForSlices,
      controller.backgroundColor,
    );
  }
}

class PieChartState extends PieRadarChartState<PieChart> {
  @override
  void updatePainter() {
    if (widget.painter.getData() != null &&
        widget.painter.getData().dataSets != null &&
        widget.painter.getData().dataSets.length > 0)
      widget.painter.highlightValue6(lastHighlighted, false);
  }
}
