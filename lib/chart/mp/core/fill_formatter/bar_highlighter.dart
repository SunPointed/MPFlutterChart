import 'dart:math';

import 'package:mp_flutter_chart/chart/mp/core/data/bar_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/bar_line_scatter_candle_bubble_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_bar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_provider/bar_data_provider.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/bar_entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/chart_hightlighter.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/core/range.dart';

class BarHighlighter extends ChartHighlighter<BarDataProvider> {
  BarHighlighter(BarDataProvider chart) : super(chart);

  @override
  Highlight getHighlight(double x, double y) {
    Highlight high = super.getHighlight(x, y);

    if (high == null) {
      return null;
    }

    MPPointD pos = getValsForTouch(x, y);

    BarData barData = mChart.getBarData();

    IBarDataSet set = barData.getDataSetByIndex(high.getDataSetIndex());
    if (set.isStacked()) {
      return getStackedHighlight(high, set, pos.x, pos.y);
    }

    MPPointD.recycleInstance2(pos);

    return high;
  }

  /**
   * This method creates the Highlight object that also indicates which value of a stacked BarEntry has been
   * selected.
   *
   * @param high the Highlight to work with looking for stacked values
   * @param set
   * @param xVal
   * @param yVal
   * @return
   */
  Highlight getStackedHighlight(
      Highlight high, IBarDataSet set, double xVal, double yVal) {
    BarEntry entry = set.getEntryForXValue2(xVal, yVal);

    if (entry == null) return null;

    // not stacked
    if (entry.getYVals() == null) {
      return high;
    } else {
      List<Range> ranges = entry.getRanges();

      if (ranges.length > 0) {
        int stackIndex = getClosestStackIndex(ranges, yVal);

        MPPointD pixels = mChart
            .getTransformer(set.getAxisDependency())
            .getPixelForValues(high.getX(), ranges[stackIndex].to);

        Highlight stackedHigh = Highlight(
            x: entry.x,
            y: entry.y,
            xPx: pixels.x,
            yPx: pixels.y,
            dataSetIndex: high.getDataSetIndex(),
            stackIndex: stackIndex,
            axis: high.getAxis());

        MPPointD.recycleInstance2(pixels);

        return stackedHigh;
      }
    }
    return null;
  }

  /**
   * Returns the index of the closest value inside the values array / ranges (stacked barchart) to the value
   * given as
   * a parameter.
   *
   * @param ranges
   * @param value
   * @return
   */
  int getClosestStackIndex(List<Range> ranges, double value) {
    if (ranges == null || ranges.length == 0) return 0;
    int stackIndex = 0;
    for (Range range in ranges) {
      if (range.contains(value))
        return stackIndex;
      else
        stackIndex++;
    }
    int length = max(ranges.length - 1, 0);
    return (value > ranges[length].to) ? length : 0;
  }

  @override
  double getDistance(double x1, double y1, double x2, double y2) {
    return (x1 - x2).abs();
  }

  @override
  BarLineScatterCandleBubbleData getData() {
    return mChart.getBarData();
  }
}
