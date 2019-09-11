import 'dart:ui';

import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_candle_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/base_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/line_scatter_candle_radar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/candle_entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';

class CandleDataSet extends LineScatterCandleRadarDataSet<CandleEntry>
    implements ICandleDataSet {
  /// the width of the shadow of the candle
  double mShadowWidth = 3;

  /// should the candle bars show?
  /// when false, only "ticks" will show
  /// <p/>
  /// - default: true
  bool mShowCandleBar = true;

  /// the space between the candle entries, default 0.1f (10%)
  double mBarSpace = 0.1;

  /// use candle color for the shadow
  bool mShadowColorSameAsCandle = false;

  /// paint style when open < close
  /// increasing candlesticks are traditionally hollow
  PaintingStyle mIncreasingPaintStyle = PaintingStyle.stroke;

  /// paint style when open > close
  /// descreasing candlesticks are traditionally filled
  PaintingStyle mDecreasingPaintStyle = PaintingStyle.fill;

  /// color for open == close
  Color mNeutralColor = ColorUtils.COLOR_SKIP;

  /// color for open < close
  Color mIncreasingColor = ColorUtils.COLOR_SKIP;

  /// color for open > close
  Color mDecreasingColor = ColorUtils.COLOR_SKIP;

  /// shadow line color, set -1 for backward compatibility and uses default
  /// color
  Color mShadowColor = ColorUtils.COLOR_SKIP;

  CandleDataSet(List<CandleEntry> yVals, String label) : super(yVals, label);

  @override
  DataSet<CandleEntry> copy1() {
    List<CandleEntry> entries = List<CandleEntry>();
    for (int i = 0; i < mValues.length; i++) {
      entries.add(mValues[i].copy());
    }
    CandleDataSet copied = CandleDataSet(entries, getLabel());
    copy(copied);
    return copied;
  }

  void copy(BaseDataSet baseDataSet) {
    super.copy(baseDataSet);
    if (baseDataSet is CandleDataSet) {
      var candleDataSet = baseDataSet;
      candleDataSet.mShadowWidth = mShadowWidth;
      candleDataSet.mShowCandleBar = mShowCandleBar;
      candleDataSet.mBarSpace = mBarSpace;
      candleDataSet.mShadowColorSameAsCandle = mShadowColorSameAsCandle;
      candleDataSet.mHighLightColor = mHighLightColor;
      candleDataSet.mIncreasingPaintStyle = mIncreasingPaintStyle;
      candleDataSet.mDecreasingPaintStyle = mDecreasingPaintStyle;
      candleDataSet.mNeutralColor = mNeutralColor;
      candleDataSet.mIncreasingColor = mIncreasingColor;
      candleDataSet.mDecreasingColor = mDecreasingColor;
      candleDataSet.mShadowColor = mShadowColor;
    }
  }

  @override
  void calcMinMax1(CandleEntry e) {
    if (e.getLow() < mYMin) mYMin = e.getLow();

    if (e.getHigh() > mYMax) mYMax = e.getHigh();

    calcMinMaxX1(e);
  }

  @override
  void calcMinMaxY1(CandleEntry e) {
    if (e.getHigh() < mYMin) mYMin = e.getHigh();

    if (e.getHigh() > mYMax) mYMax = e.getHigh();

    if (e.getLow() < mYMin) mYMin = e.getLow();

    if (e.getLow() > mYMax) mYMax = e.getLow();
  }

  /// Sets the space that is left out on the left and right side of each
  /// candle, default 0.1f (10%), max 0.45f, min 0f
  ///
  /// @param space
  void setBarSpace(double space) {
    if (space < 0) space = 0;
    if (space > 0.45) space = 0.45;

    mBarSpace = space;
  }

  @override
  double getBarSpace() {
    return mBarSpace;
  }

  /// Sets the width of the candle-shadow-line in pixels. Default 3f.
  ///
  /// @param width
  void setShadowWidth(double width) {
    mShadowWidth = Utils.convertDpToPixel(width);
  }

  @override
  double getShadowWidth() {
    return mShadowWidth;
  }

  /// Sets whether the candle bars should show?
  ///
  /// @param showCandleBar
  void setShowCandleBar(bool showCandleBar) {
    mShowCandleBar = showCandleBar;
  }

  @override
  bool getShowCandleBar() {
    return mShowCandleBar;
  }

  // TODO
  /**
   * It is necessary to implement ColorsList class that will encapsulate
   * colors list functionality, because It's wrong to copy paste setColor,
   * addColor, ... resetColors for each time when we want to add a coloring
   * options for one of objects
   *
   * @author Mesrop
   */

  /** BELOW THIS COLOR HANDLING */

  /// Sets the one and ONLY color that should be used for this DataSet when
  /// open == close.
  ///
  /// @param color
  void setNeutralColor(Color color) {
    mNeutralColor = color;
  }

  @override
  Color getNeutralColor() {
    return mNeutralColor;
  }

  /// Sets the one and ONLY color that should be used for this DataSet when
  /// open <= close.
  ///
  /// @param color
  void setIncreasingColor(Color color) {
    mIncreasingColor = color;
  }

  @override
  Color getIncreasingColor() {
    return mIncreasingColor;
  }

  /// Sets the one and ONLY color that should be used for this DataSet when
  /// open > close.
  ///
  /// @param color
  void setDecreasingColor(Color color) {
    mDecreasingColor = color;
  }

  @override
  Color getDecreasingColor() {
    return mDecreasingColor;
  }

  @override
  PaintingStyle getIncreasingPaintStyle() {
    return mIncreasingPaintStyle;
  }

  /// Sets paint style when open < close
  ///
  /// @param paintStyle
  void setIncreasingPaintStyle(PaintingStyle paintStyle) {
    this.mIncreasingPaintStyle = paintStyle;
  }

  @override
  PaintingStyle getDecreasingPaintStyle() {
    return mDecreasingPaintStyle;
  }

  /// Sets paint style when open > close
  ///
  /// @param decreasingPaintStyle
  void setDecreasingPaintStyle(PaintingStyle decreasingPaintStyle) {
    this.mDecreasingPaintStyle = decreasingPaintStyle;
  }

  @override
  Color getShadowColor() {
    return mShadowColor;
  }

  /// Sets shadow color for all entries
  ///
  /// @param shadowColor
  void setShadowColor(Color shadowColor) {
    this.mShadowColor = shadowColor;
  }

  @override
  bool getShadowColorSameAsCandle() {
    return mShadowColorSameAsCandle;
  }

  /// Sets shadow color to be the same color as the candle color
  ///
  /// @param shadowColorSameAsCandle
  void setShadowColorSameAsCandle(bool shadowColorSameAsCandle) {
    this.mShadowColorSameAsCandle = shadowColorSameAsCandle;
  }
}
