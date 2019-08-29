import 'dart:math' as math;

import 'package:mp_flutter_chart/chart/mp/core/animator.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_bar_line_scatter_candle_bubble_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_provider/bar_line_scatter_candle_bubble_data_provider.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/rounding.dart';

class XBounds {
  /**
   * minimum visible entry index
   */
  int min;

  /**
   * maximum visible entry index
   */
  int max;

  /**
   * range of visible entry indices
   */
  int range;

  ChartAnimator animator;

  XBounds(this.animator);

  /**
   * Calculates the minimum and maximum x values as well as the range between them.
   *
   * @param chart
   * @param dataSet
   */
  void set(BarLineScatterCandleBubbleDataProvider chart,
      IBarLineScatterCandleBubbleDataSet dataSet) {
    double phaseX = math.max(0.0, math.min(1.0, animator.getPhaseX()));
    ;

    double low = chart.getLowestVisibleX();
    double high = chart.getHighestVisibleX();
    Entry entryFrom =
        dataSet.getEntryForXValue1(low, double.nan, Rounding.DOWN);
    Entry entryTo = dataSet.getEntryForXValue1(high, double.nan, Rounding.UP);

    min = entryFrom == null ? 0 : dataSet.getEntryIndex2(entryFrom);
    max = entryTo == null ? 0 : dataSet.getEntryIndex2(entryTo);

    if (min > max) {
      var t = min;
      min = max;
      max = t;
    }

    range = ((max - min) * phaseX).toInt();
  }
}
