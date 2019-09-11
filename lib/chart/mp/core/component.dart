import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';

abstract class ComponentBase {
  /// flag that indicates if this axis / legend is enabled or not
  bool mEnabled = true;

  /// the offset in pixels this component has on the x-axis
  double mXOffset = 5;

  /// the offset in pixels this component has on the Y-axis
  double mYOffset = 5;

  /// the typeface used for the labels
  TextStyle mTypeface = null;

  /// the text size of the labels
  double mTextSize = Utils.convertDpToPixel(10);

  /// the text color to use for the labels
  Color mTextColor = Color(0xFF000000);

  /// Returns the used offset on the x-axis for drawing the axis or legend
  /// labels. This offset is applied before and after the label.
  ///
  /// @return
  double getXOffset() {
    return mXOffset;
  }

  /// Sets the used x-axis offset for the labels on this axis.
  ///
  /// @param xOffset

  void setXOffset(double xOffset) {
    mXOffset = Utils.convertDpToPixel(xOffset);
  }

  /// Returns the used offset on the x-axis for drawing the axis labels. This
  /// offset is applied before and after the label.
  ///
  /// @return
  double getYOffset() {
    return mYOffset;
  }

  /// Sets the used y-axis offset for the labels on this axis. For the legend,
  /// higher offset means the legend as a whole will be placed further away
  /// from the top.
  ///
  /// @param yOffset

  void setYOffset(double yOffset) {
    mYOffset = Utils.convertDpToPixel(yOffset);
  }

  /// returns the Typeface used for the labels, returns null if none is set
  ///
  /// @return
  TextStyle getTypeface() {
    return mTypeface;
  }

  /// sets a specific Typeface for the labels
  ///
  /// @param tf

  void setTypeface(TextStyle tf) {
    mTypeface = tf;
  }

  /// sets the size of the label text in density pixels min = 6f, max = 24f, default
  /// 10f
  ///
  /// @param size the text size, in DP

  void setTextSize(double size) {
    if (size > 24) size = 24;
    if (size < 6) size = 6;

    mTextSize = Utils.convertDpToPixel(size);
  }

  /// returns the text size that is currently set for the labels, in pixels
  ///
  /// @return
  double getTextSize() {
    return mTextSize;
  }

  /// Sets the text color to use for the labels. Make sure to use
  /// getResources().getColor(...) when using a color from the resources.
  ///
  /// @param color
  void setTextColor(Color color) {
    mTextColor = color;
  }

  /// Returns the text color that is set for the labels.
  ///
  /// @return
   Color getTextColor() {
    return mTextColor;
  }

  /// Set this to true if this component should be enabled (should be drawn),
  /// false if not. If disabled, nothing of this component will be drawn.
  /// Default: true
  ///
  /// @param enabled
   void setEnabled(bool enabled) {
    mEnabled = enabled;
  }

  /// Returns true if this comonent is enabled (should be drawn), false if not.
  ///
  /// @return
   bool isEnabled() {
    return mEnabled;
  }
}
