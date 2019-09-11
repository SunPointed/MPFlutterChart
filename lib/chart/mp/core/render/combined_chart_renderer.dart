import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/core/animator.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/chart_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/combined_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/bar_chart_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/bubble_chart_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/candle_stick_chart_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/data_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/line_chart_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/scatter_chart_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/painter/combined_chart_painter.dart';
import 'package:mp_flutter_chart/chart/mp/painter/painter.dart';

class CombinedChartRenderer extends DataRenderer {
  /// all rederers for the different kinds of data this combined-renderer can draw
  List<DataRenderer> mRenderers = List<DataRenderer>();

  ChartPainter mChart;

  CombinedChartRenderer(CombinedChartPainter chart, ChartAnimator animator,
      ViewPortHandler viewPortHandler)
      : super(animator, viewPortHandler) {
    mChart = chart;
    createRenderers();
  }

  /// Creates the renderers needed for this combined-renderer in the required order. Also takes the DrawOrder into
  /// consideration.
  void createRenderers() {
    mRenderers.clear();

    CombinedChartPainter chart = (mChart as CombinedChartPainter);
    if (chart == null) return;

    List<DrawOrder> orders = chart.getDrawOrder();

    for (DrawOrder order in orders) {
      switch (order) {
        case DrawOrder.BAR:
          if (chart.getBarData() != null)
            mRenderers
                .add(BarChartRenderer(chart, mAnimator, mViewPortHandler));
          break;
        case DrawOrder.BUBBLE:
          if (chart.getBubbleData() != null)
            mRenderers
                .add(BubbleChartRenderer(chart, mAnimator, mViewPortHandler));
          break;
        case DrawOrder.LINE:
          if (chart.getLineData() != null)
            mRenderers
                .add(LineChartRenderer(chart, mAnimator, mViewPortHandler));
          break;
        case DrawOrder.CANDLE:
          if (chart.getCandleData() != null)
            mRenderers.add(
                CandleStickChartRenderer(chart, mAnimator, mViewPortHandler));
          break;
        case DrawOrder.SCATTER:
          if (chart.getScatterData() != null)
            mRenderers
                .add(ScatterChartRenderer(chart, mAnimator, mViewPortHandler));
          break;
      }
    }
  }

  @override
  void initBuffers() {
    for (DataRenderer renderer in mRenderers) renderer.initBuffers();
  }

  @override
  void drawData(Canvas c) {
    for (DataRenderer renderer in mRenderers) renderer.drawData(c);
  }

  @override
  void drawValue(Canvas c, String valueText, double x, double y, Color color) {}

  @override
  void drawValues(Canvas c) {
    for (DataRenderer renderer in mRenderers) renderer.drawValues(c);
  }

  @override
  void drawExtras(Canvas c) {
    for (DataRenderer renderer in mRenderers) renderer.drawExtras(c);
  }

  List<Highlight> mHighlightBuffer = List<Highlight>();

  @override
  void drawHighlighted(Canvas c, List<Highlight> indices) {
    ChartPainter chart = mChart;
    if (chart == null) return;

    for (DataRenderer renderer in mRenderers) {
      ChartData data;

      if (renderer is BarChartRenderer)
        data = renderer.mChart.getBarData();
      else if (renderer is LineChartRenderer)
        data = renderer.mChart.getLineData();
      else if (renderer is CandleStickChartRenderer)
        data = renderer.mChart.getCandleData();
      else if (renderer is ScatterChartRenderer)
        data = renderer.mChart.getScatterData();
      else if (renderer is BubbleChartRenderer)
        data = renderer.mChart.getBubbleData();

      int dataIndex = data == null
          ? -1
          : (chart.getData() as CombinedData).getAllData().indexOf(data);

      mHighlightBuffer.clear();

      for (Highlight h in indices) {
        if (h.getDataIndex() == dataIndex || h.getDataIndex() == -1)
          mHighlightBuffer.add(h);
      }

      renderer.drawHighlighted(c, mHighlightBuffer);
    }
  }

  /// Returns the sub-renderer object at the specified index.
  ///
  /// @param index
  /// @return
  DataRenderer getSubRenderer(int index) {
    if (index >= mRenderers.length || index < 0)
      return null;
    else
      return mRenderers[index];
  }

  /// Returns all sub-renderers.
  ///
  /// @return
  List<DataRenderer> getSubRenderers() {
    return mRenderers;
  }

  void setSubRenderers(List<DataRenderer> renderers) {
    this.mRenderers = renderers;
  }
}
