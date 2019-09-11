import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/core/component.dart';
import 'package:mp_flutter_chart/chart/mp/core/adapter_android_mp.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/limite_label_postion.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';

class LimitLine extends ComponentBase {
  /// limit / maximum (the y-value or xIndex)
  double mLimit = 0;

  /// the width of the limit line
  double mLineWidth = 2;

  /// the color of the limit line
  Color mLineColor = Color.fromARGB(255, 237, 91, 91);

  /// the style of the label text
  PaintingStyle mTextStyle = PaintingStyle.fill;

  /// label string that is drawn next to the limit line
  String mLabel = "";

  /// the path effect of this LimitLine that makes dashed lines possible
  DashPathEffect mDashPathEffect = null;

  /// indicates the position of the LimitLine label
  LimitLabelPosition mLabelPosition = LimitLabelPosition.RIGHT_TOP;

  LimitLine(this.mLimit, [this.mLabel]);

  /// Returns the limit that is set for this line.
  ///
  /// @return
  double getLimit() {
    return mLimit;
  }

  /// set the line width of the chart (min = 0.2f, max = 12f); default 2f NOTE:
  /// thinner line == better performance, thicker line == worse performance
  ///
  /// @param width
  void setLineWidth(double width) {
    if (width < 0.2) width = 0.2;
    if (width > 12.0) width = 12.0;
    mLineWidth = Utils.convertDpToPixel(width);
  }

  /// returns the width of limit line
  ///
  /// @return
  double getLineWidth() {
    return mLineWidth;
  }

  /// Sets the linecolor for this LimitLine. Make sure to use
  /// getResources().getColor(...)
  ///
  /// @param color
  void setLineColor(Color color) {
    mLineColor = color;
  }

  /// Returns the color that is used for this LimitLine
  ///
  /// @return
  Color getLineColor() {
    return mLineColor;
  }

  /// Enables the line to be drawn in dashed mode, e.g. like this "- - - - - -"
  ///
  /// @param lineLength the length of the line pieces
  /// @param spaceLength the length of space inbetween the pieces
  /// @param phase offset, in degrees (normally, use 0)
  void enableDashedLine(double lineLength, double spaceLength, double phase) {
//    mDashPathEffect = new DashPathEffect(new float[] { todo
//    lineLength, spaceLength
//    }, phase);
  }

  /// Disables the line to be drawn in dashed mode.
  void disableDashedLine() {
    mDashPathEffect = null;
  }

  /// Returns true if the dashed-line effect is enabled, false if not. Default:
  /// disabled
  ///
  /// @return
  bool isDashedLineEnabled() {
    return mDashPathEffect == null ? false : true;
  }

  /// returns the DashPathEffect that is set for this LimitLine
  ///
  /// @return
  DashPathEffect getDashPathEffect() {
    return mDashPathEffect;
  }

  /// Sets the color of the value-text that is drawn next to the LimitLine.
  /// Default: Paint.Style.FILL_AND_STROKE
  ///
  /// @param style
  void setTextStyle(PaintingStyle style) {
    this.mTextStyle = style;
  }

  /// Returns the color of the value-text that is drawn next to the LimitLine.
  ///
  /// @return
  PaintingStyle getTextStyle() {
    return mTextStyle;
  }

  /// Sets the position of the LimitLine value label (either on the right or on
  /// the left edge of the chart). Not supported for RadarChart.
  ///
  /// @param pos
  void setLabelPosition(LimitLabelPosition pos) {
    mLabelPosition = pos;
  }

  /// Returns the position of the LimitLine label (value).
  ///
  /// @return
  LimitLabelPosition getLabelPosition() {
    return mLabelPosition;
  }

  /// Sets the label that is drawn next to the limit line. Provide "" if no
  /// label is required.
  ///
  /// @param label
  void setLabel(String label) {
    mLabel = label;
  }

  /// Returns the label that is drawn next to the limit line.
  ///
  /// @return
  String getLabel() {
    return mLabel;
  }
}
