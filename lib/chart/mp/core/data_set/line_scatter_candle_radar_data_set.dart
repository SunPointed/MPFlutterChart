import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_line_scatter_candle_radar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/bar_line_scatter_candle_bubble_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/base_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/util.dart';

abstract class LineScatterCandleRadarDataSet<T extends Entry>
    extends BarLineScatterCandleBubbleDataSet<T>
    implements ILineScatterCandleRadarDataSet<T> {
  bool mDrawVerticalHighlightIndicator = true;
  bool mDrawHorizontalHighlightIndicator = true;

  /** the width of the highlight indicator lines */
  double mHighlightLineWidth = 0.5;

  /** the path effect for dashed highlight-lines */
//   DashPathEffect mHighlightDashPathEffect = null;

  LineScatterCandleRadarDataSet(List<T> yVals, String label)
      : super(yVals, label) {
    mHighlightLineWidth = Utils.convertDpToPixel(0.5);
  }

  /**
   * Enables / disables the horizontal highlight-indicator. If disabled, the indicator is not drawn.
   * @param enabled
   */
  void setDrawHorizontalHighlightIndicator(bool enabled) {
    this.mDrawHorizontalHighlightIndicator = enabled;
  }

  /**
   * Enables / disables the vertical highlight-indicator. If disabled, the indicator is not drawn.
   * @param enabled
   */
  void setDrawVerticalHighlightIndicator(bool enabled) {
    this.mDrawVerticalHighlightIndicator = enabled;
  }

  /**
   * Enables / disables both vertical and horizontal highlight-indicators.
   * @param enabled
   */
  void setDrawHighlightIndicators(bool enabled) {
    setDrawVerticalHighlightIndicator(enabled);
    setDrawHorizontalHighlightIndicator(enabled);
  }

  @override
  bool isVerticalHighlightIndicatorEnabled() {
    return mDrawVerticalHighlightIndicator;
  }

  @override
  bool isHorizontalHighlightIndicatorEnabled() {
    return mDrawHorizontalHighlightIndicator;
  }

  /**
   * Sets the width of the highlight line in dp.
   * @param width
   */
  void setHighlightLineWidth(double width) {
    mHighlightLineWidth = Utils.convertDpToPixel(width);
  }

  @override
  double getHighlightLineWidth() {
    return mHighlightLineWidth;
  }

  /**
   * Enables the highlight-line to be drawn in dashed mode, e.g. like this "- - - - - -"
   *
   * @param lineLength the length of the line pieces
   * @param spaceLength the length of space inbetween the line-pieces
   * @param phase offset, in degrees (normally, use 0)
   */
//   void enableDashedHighlightLine(double lineLength, double spaceLength, double phase) {
//    mHighlightDashPathEffect =  DashPathEffect( double[] {
//    lineLength, spaceLength
//    }, phase);
//  }

  /**
   * Disables the highlight-line to be drawn in dashed mode.
   */
//   void disableDashedHighlightLine() {
//    mHighlightDashPathEffect = null;
//  }

  /**
   * Returns true if the dashed-line effect is enabled for highlight lines, false if not.
   * Default: disabled
   *
   * @return
   */
//   bool isDashedHighlightLineEnabled() {
//    return mHighlightDashPathEffect == null ? false : true;
//  }

//  @override
//   DashPathEffect getDashPathEffectHighlight() {
//    return mHighlightDashPathEffect;
//  }

  void copy(BaseDataSet baseDataSet) {
    super.copy(baseDataSet);
    if (baseDataSet is LineScatterCandleRadarDataSet) {
      var lineScatterCandleRadarDataSet = baseDataSet;
      lineScatterCandleRadarDataSet.mDrawHorizontalHighlightIndicator =
          mDrawHorizontalHighlightIndicator;
      lineScatterCandleRadarDataSet.mDrawVerticalHighlightIndicator =
          mDrawVerticalHighlightIndicator;
      lineScatterCandleRadarDataSet.mHighlightLineWidth = mHighlightLineWidth;
//    lineScatterCandleRadarDataSet.mHighlightDashPathEffect = mHighlightDashPathEffect;
    }
  }
}
