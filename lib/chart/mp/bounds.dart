import 'package:mp_flutter_chart/chart/mp/core/data.dart';
import 'package:mp_flutter_chart/chart/mp/core/interfaces.dart';

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

  /**
   * Calculates the minimum and maximum x values as well as the range between them.
   *
   * @param chart
   * @param dataSet
   */
  void set(BarLineScatterCandleBubbleDataProvider chart,
      IBarLineScatterCandleBubbleDataSet dataSet) {
    double phaseX = 1;

    double low = chart.getLowestVisibleX();
    double high = chart.getHighestVisibleX();
    Entry entryFrom =
        dataSet.getEntryForXValue1(low, double.nan, Rounding.DOWN);
    Entry entryTo = dataSet.getEntryForXValue1(high, double.nan, Rounding.UP);

    min = entryFrom == null ? 0 : dataSet.getEntryIndex2(entryFrom);
    max = entryTo == null ? 0 : dataSet.getEntryIndex2(entryTo);

    if(min > max){
      var t = min;
      min = max;
      max = t;
    }

    range = ((max - min) * phaseX).toInt();
  }
}
