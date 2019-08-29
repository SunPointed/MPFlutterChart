import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'dart:ui' as ui;

class CandleEntry extends Entry {
  /** shadow-high value */
  double mShadowHigh = 0;

  /** shadow-low value */
  double mShadowLow = 0;

  /** close value */
  double mClose = 0;

  /** open value */
  double mOpen = 0;

  CandleEntry(
      {double x,
      double shadowH,
      double shadowL,
      double open,
      double close,
      ui.Image icon,
      Object data})
      : super(x: x, y: (shadowH + shadowL) / 2, icon: icon, data: data) {
    this.mShadowHigh = shadowH;
    this.mShadowLow = shadowL;
    this.mOpen = open;
    this.mClose = close;
  }

  /**
   * Returns the overall range (difference) between shadow-high and
   * shadow-low.
   *
   * @return
   */
  double getShadowRange() {
    return (mShadowHigh - mShadowLow).abs();
  }

  /**
   * Returns the body size (difference between open and close).
   *
   * @return
   */
  double getBodyRange() {
    return (mOpen - mClose).abs();
  }

  CandleEntry copy() {
    CandleEntry c = CandleEntry(
        x: x,
        shadowH: mShadowHigh,
        shadowL: mShadowLow,
        open: mOpen,
        close: mClose,
        data: mData);
    return c;
  }

  /**
   * Returns the upper shadows highest value.
   *
   * @return
   */
  double getHigh() {
    return mShadowHigh;
  }

  void setHigh(double mShadowHigh) {
    this.mShadowHigh = mShadowHigh;
  }

  /**
   * Returns the lower shadows lowest value.
   *
   * @return
   */
  double getLow() {
    return mShadowLow;
  }

  void setLow(double mShadowLow) {
    this.mShadowLow = mShadowLow;
  }

  /**
   * Returns the bodys close value.
   *
   * @return
   */
  double getClose() {
    return mClose;
  }

  void setClose(double mClose) {
    this.mClose = mClose;
  }

  /**
   * Returns the bodys open value.
   *
   * @return
   */
  double getOpen() {
    return mOpen;
  }

  void setOpen(double mOpen) {
    this.mOpen = mOpen;
  }
}
