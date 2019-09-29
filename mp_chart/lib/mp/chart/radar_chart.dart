import 'package:flutter/painting.dart';
import 'package:mp_chart/mp/chart/pie_radar_chart.dart';
import 'package:mp_chart/mp/core/axis/y_axis.dart';
import 'package:mp_chart/mp/core/common_interfaces.dart';
import 'package:mp_chart/mp/core/data/radar_data.dart';
import 'package:mp_chart/mp/core/description.dart';
import 'package:mp_chart/mp/core/enums/axis_dependency.dart';
import 'package:mp_chart/mp/core/functions.dart';
import 'package:mp_chart/mp/core/marker/i_marker.dart';
import 'package:mp_chart/mp/core/marker/radar_chart_marker.dart';
import 'package:mp_chart/mp/painter/radar_chart_painter.dart';

class RadarChart extends PieRadarChart<RadarChartPainter> {
  double webLineWidth;
  double innerWebLineWidth;
  Color webColor; // = Color.fromARGB(255, 122, 122, 122)
  Color webColorInner; // = Color.fromARGB(255, 122, 122, 122)
  int webAlpha;
  bool drawWeb;
  int skipWebLineCount;
  YAxis yAxis;
  Color backgroundColor;

  YAxisSettingFunction _yAxisSettingFunction;

  RadarChart(RadarData data,
      {IMarker marker,
      Description description,
      YAxisSettingFunction yAxisSettingFunction,
      XAxisSettingFunction xAxisSettingFunction,
      LegendSettingFunction legendSettingFunction,
      DataRendererSettingFunction rendererSettingFunction,
      OnChartValueSelectedListener selectionListener,
      double rotationAngle = 270,
      double rawRotationAngle = 270,
      bool rotateEnabled = true,
      double minOffset = 30.0,
      double maxHighlightDistance = 100.0,
      bool highLightPerTapEnabled = true,
      double extraTopOffset = 0.0,
      double extraRightOffset = 0.0,
      double extraBottomOffset = 0.0,
      double extraLeftOffset = 0.0,
      String noDataText = "No chart data available.",
      bool drawMarkers = true,
      double descTextSize = 12,
      double infoTextSize = 12,
      Color descTextColor,
      Color infoTextColor,
      Color backgroundColor,
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
        _yAxisSettingFunction = yAxisSettingFunction,
        backgroundColor = backgroundColor,
        super(data,
            marker: marker,
            noDataText: noDataText,
            xAxisSettingFunction: xAxisSettingFunction,
            legendSettingFunction: legendSettingFunction,
            rendererSettingFunction: rendererSettingFunction,
            description: description,
            selectionListener: selectionListener,
            maxHighlightDistance: maxHighlightDistance,
            highLightPerTapEnabled: highLightPerTapEnabled,
            extraTopOffset: extraTopOffset,
            extraRightOffset: extraRightOffset,
            extraBottomOffset: extraBottomOffset,
            extraLeftOffset: extraLeftOffset,
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
  void doneBeforePainterInit() {
    super.doneBeforePainterInit();
    this.webColor ??= Color.fromARGB(255, 122, 122, 122);
    this.webColorInner ??= Color.fromARGB(255, 122, 122, 122);
    this.yAxis = YAxis(position: AxisDependency.LEFT);
    if (_yAxisSettingFunction != null) {
      _yAxisSettingFunction(yAxis, this);
    }
  }

  @override
  IMarker initMarker() => RadarChartMarker();

  @override
  RadarChartState createChartState() {
    return RadarChartState();
  }

  RadarChartPainter get painter => super.painter;

  @override
  void initialPainter() {
    painter = RadarChartPainter(
        data,
        animator,
        viewPortHandler,
        maxHighlightDistance,
        highLightPerTapEnabled,
        extraLeftOffset,
        extraTopOffset,
        extraRightOffset,
        extraBottomOffset,
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
        rotationAngle,
        rawRotationAngle,
        rotateEnabled,
        minOffset,
        webLineWidth,
        innerWebLineWidth,
        webColor,
        webColorInner,
        webAlpha,
        drawWeb,
        skipWebLineCount,
        yAxis,
        backgroundColor);
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
