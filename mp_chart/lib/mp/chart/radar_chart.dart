import 'package:flutter/painting.dart';
import 'package:mp_chart/mp/chart/pie_radar_chart.dart';
import 'package:mp_chart/mp/controller/radar_chart_controller.dart';
import 'package:mp_chart/mp/painter/radar_chart_painter.dart';

class RadarChart
    extends PieRadarChart<RadarChartPainter, RadarChartController> {
  RadarChart(RadarChartController controller) : super(controller);

  @override
  void doneBeforePainterInit() {
    super.doneBeforePainterInit();
    controller.webColor ??= Color.fromARGB(255, 122, 122, 122);
    controller.webColorInner ??= Color.fromARGB(255, 122, 122, 122);
    controller.yAxis = controller.initYAxis();
    if (controller.yAxisSettingFunction != null) {
      controller.yAxisSettingFunction(controller.yAxis, this);
    }
  }

  @override
  RadarChartState createChartState() {
    return RadarChartState();
  }

  RadarChartPainter get painter => super.painter;

  @override
  void initialPainter() {
    painter = RadarChartPainter(
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
        controller.webLineWidth,
        controller.innerWebLineWidth,
        controller.webColor,
        controller.webColorInner,
        controller.webAlpha,
        controller.drawWeb,
        controller.skipWebLineCount,
        controller.yAxis,
        controller.backgroundColor);
  }
}

class RadarChartState extends PieRadarChartState<RadarChart> {
  @override
  void updatePainter() {
    if (widget.painter.getData() != null &&
        widget.painter.getData().dataSets != null &&
        widget.painter.getData().dataSets.length > 0)
      widget.painter.highlightValue6(lastHighlighted, false);
  }
}
