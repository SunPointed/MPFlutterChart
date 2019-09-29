import 'package:flutter/cupertino.dart';
import 'package:mp_chart/mp/chart/chart.dart';
import 'package:mp_chart/mp/core/animator.dart';
import 'package:mp_chart/mp/core/axis/x_axis.dart';
import 'package:mp_chart/mp/core/common_interfaces.dart';
import 'package:mp_chart/mp/core/data/chart_data.dart';
import 'package:mp_chart/mp/core/description.dart';
import 'package:mp_chart/mp/core/functions.dart';
import 'package:mp_chart/mp/core/legend/legend.dart';
import 'package:mp_chart/mp/core/marker/i_marker.dart';
import 'package:mp_chart/mp/core/render/legend_renderer.dart';
import 'package:mp_chart/mp/core/utils/color_utils.dart';
import 'package:mp_chart/mp/core/utils/painter_utils.dart';
import 'package:mp_chart/mp/core/utils/utils.dart';
import 'package:mp_chart/mp/core/view_port.dart';

abstract class Controller {
  Chart _chart;

  ////// needed
  ChartData data;
  IMarker marker;
  Description description;
  ViewPortHandler viewPortHandler;
  XAxis xAxis;
  Legend legend;
  LegendRenderer legendRenderer;
  OnChartValueSelectedListener selectionListener;

  ////// option
  double maxHighlightDistance;
  bool highLightPerTapEnabled;
  double extraTopOffset, extraRightOffset, extraBottomOffset, extraLeftOffset;
  bool drawMarkers;

  ////// split child property
  TextPainter descPaint;
  TextPainter infoPaint;

  XAxisSettingFunction xAxisSettingFunction;
  LegendSettingFunction legendSettingFunction;
  DataRendererSettingFunction rendererSettingFunction;

  Controller(this.data,
      {this.marker,
      this.description,
      this.viewPortHandler,
      this.xAxis,
      this.legend,
      this.legendRenderer,
      this.selectionListener,
      this.maxHighlightDistance = 100.0,
      this.highLightPerTapEnabled = true,
      this.extraTopOffset = 0.0,
      this.extraRightOffset = 0.0,
      this.extraBottomOffset = 0.0,
      this.extraLeftOffset = 0.0,
      this.drawMarkers = true,
      double descTextSize = 12,
      double infoTextSize = 12,
      Color descTextColor,
      Color infoTextColor,
      this.descPaint,
      this.infoPaint,
      String noDataText = "No chart data available.",
      this.xAxisSettingFunction,
      this.legendSettingFunction,
      this.rendererSettingFunction}) {
    if (descTextColor == null) {
      descTextColor = ColorUtils.BLACK;
    }
    descPaint = PainterUtils.create(null, null, descTextColor, descTextSize,
        fontFamily: description?.typeface?.fontFamily,
        fontWeight: description?.typeface?.fontWeight);
    if (infoTextColor == null) {
      infoTextColor = ColorUtils.BLACK;
    }
    infoPaint =
        PainterUtils.create(null, noDataText, infoTextColor, infoTextSize);

    if (maxHighlightDistance == 0.0) {
      maxHighlightDistance = Utils.convertDpToPixel(500);
    }

    this.viewPortHandler ??= initViewPortHandler();
    this.marker ??= initMarker();
    this.description ??= initDescription();
    this.selectionListener ??= initSelectionListener();
  }

  IMarker initMarker() => null;

  Description initDescription() => Description();

  ViewPortHandler initViewPortHandler() => ViewPortHandler();

  XAxis initXAxis() => XAxis();

  Legend initLegend() => Legend();

  LegendRenderer initLegendRenderer() =>
      LegendRenderer(viewPortHandler, legend);

  OnChartValueSelectedListener initSelectionListener() => null;

  void attachChart(Chart chart) {
    _chart = chart;
  }

  ChartState getState() {
    return _chart?.state;
  }

  ChartAnimator getAnimator() {
    return _chart?.animator;
  }
}
