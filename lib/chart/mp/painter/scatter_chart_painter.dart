import 'package:flutter/cupertino.dart';
import 'package:mp_flutter_chart/chart/mp/core/animator.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis/x_axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis/y_axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/common_interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/scatter_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_provider/scatter_data_provider.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/legend/legend.dart';
import 'package:mp_flutter_chart/chart/mp/core/marker/i_marker.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/legend_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/scatter_chart_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/x_axis_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/y_axis_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/transformer/transformer.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/painter/bar_line_chart_painter.dart';

class ScatterChartPainter extends BarLineChartBasePainter<ScatterData>
    implements ScatterDataProvider {
  ScatterChartPainter(
    ScatterData data,
    ChartAnimator animator,
    ViewPortHandler viewPortHandler,
    double maxHighlightDistance,
    bool highLightPerTapEnabled,
    bool dragDecelerationEnabled,
    double dragDecelerationFrictionCoef,
    double extraLeftOffset,
    double extraTopOffset,
    double extraRightOffset,
    double extraBottomOffset,
    String noDataText,
    bool touchEnabled,
    IMarker marker,
    Description desc,
    bool drawMarkers,
    TextPainter infoPainter,
    TextPainter descPainter,
    XAxis xAxis,
    Legend legend,
    LegendRenderer legendRenderer,
    OnChartValueSelectedListener selectedListener,
    int maxVisibleCount,
    bool autoScaleMinMaxEnabled,
    bool pinchZoomEnabled,
    bool doubleTapToZoomEnabled,
    bool highlightPerDragEnabled,
    bool dragXEnabled,
    bool dragYEnabled,
    bool scaleXEnabled,
    bool scaleYEnabled,
    Paint gridBackgroundPaint,
    Paint borderPaint,
    bool drawGridBackground,
    bool drawBorders,
    bool clipValuesToContent,
    double minOffset,
    bool keepPositionOnRotation,
    OnDrawListener drawListener,
    YAxis axisLeft,
    YAxis axisRight,
    YAxisRenderer axisRendererLeft,
    YAxisRenderer axisRendererRight,
    Transformer leftAxisTransformer,
    Transformer rightAxisTransformer,
    XAxisRenderer xAxisRenderer,
    Matrix4 zoomMatrixBuffer,
    bool customViewPortEnabled,
    double minXRange,
    double maxXRange,
    double minimumScaleX,
    double minimumScaleY,
  ) : super(
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
            desc,
            drawMarkers,
            infoPainter,
            descPainter,
            xAxis,
            legend,
            legendRenderer,
            selectedListener,
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
            minimumScaleY);

  @override
  void initDefaultWithData() {
    renderer = ScatterChartRenderer(this, animator, viewPortHandler);
    super.initDefaultWithData();
    xAxis.setSpaceMin(0.5);
    xAxis.setSpaceMax(0.5);
  }

  @override
  ScatterData getScatterData() {
    return getData();
  }
}
