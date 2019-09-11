import 'package:mp_flutter_chart/chart/mp/core/enums/axis_dependency.dart';

class Highlight {
  /// the x-value of the highlighted value
  double mX = double.nan;

  /// the y-value of the highlighted value
  double mY = double.nan;

  /// the x-pixel of the highlight
  double mXPx;

  /// the y-pixel of the highlight
  double mYPx;

  /// the index of the data object - in case it refers to more than one
  int mDataIndex = -1;

  ///
  /// the index of the datase
  /// t the highlighted value is in
  int mDataSetIndex;

  /// index which value of a stacked bar entry is highlighted, default -1
  int mStackIndex = -1;

  /// the axis the highlighted value belongs to
  AxisDependency axis;

  /// the x-position (pixels) on which this highlight object was last drawn
  double mDrawX;

  /// the y-position (pixels) on which this highlight object was last drawn
  double mDrawY;

  Highlight(
      {double x = double.nan,
      double y = double.nan,
      double xPx = 0,
      double yPx = 0,
      int dataSetIndex = 0,
      int stackIndex = -1,
      AxisDependency axis = null}) {
    this.mX = x;
    this.mY = y;
    this.mXPx = xPx;
    this.mYPx = yPx;
    this.mDataSetIndex = dataSetIndex;
    this.axis = axis;
    this.mStackIndex = stackIndex;
  }

  /// returns the x-value of the highlighted value
  ///
  /// @return
  double getX() {
    return mX;
  }

  /// returns the y-value of the highlighted value
  ///
  /// @return
  double getY() {
    return mY;
  }

  /// returns the x-position of the highlight in pixels
  double getXPx() {
    return mXPx;
  }

  /// returns the y-position of the highlight in pixels
  double getYPx() {
    return mYPx;
  }

  /// the index of the data object - in case it refers to more than one
  ///
  /// @return
  int getDataIndex() {
    return mDataIndex;
  }

  void setDataIndex(int mDataIndex) {
    this.mDataIndex = mDataIndex;
  }

  /// returns the index of the DataSet the highlighted value is in
  ///
  /// @return
  int getDataSetIndex() {
    return mDataSetIndex;
  }

  /// Only needed if a stacked-barchart entry was highlighted. References the
  /// selected value within the stacked-entry.
  ///
  /// @return
  int getStackIndex() {
    return mStackIndex;
  }

  bool isStacked() {
    return mStackIndex >= 0;
  }

  /// Returns the axis the highlighted value belongs to.
  ///
  /// @return
  AxisDependency getAxis() {
    return axis;
  }

  /// Sets the x- and y-position (pixels) where this highlight was last drawn.
  ///
  /// @param x
  /// @param y
  void setDraw(double x, double y) {
    this.mDrawX = x;
    this.mDrawY = y;
  }

  /// Returns the x-position in pixels where this highlight object was last drawn.
  ///
  /// @return
  double getDrawX() {
    return mDrawX;
  }

  /// Returns the y-position in pixels where this highlight object was last drawn.
  ///
  /// @return
  double getDrawY() {
    return mDrawY;
  }

  /// Returns true if this highlight object is equal to the other (compares
  /// xIndex and dataSetIndex)
  ///
  /// @param h
  /// @return
  bool equalTo(Highlight h) {
    if (h == null)
      return false;
    else {
      if (this.mDataSetIndex == h.mDataSetIndex &&
          this.mX == h.mX &&
          this.mStackIndex == h.mStackIndex &&
          this.mDataIndex == h.mDataIndex)
        return true;
      else
        return false;
    }
  }

  @override
  String toString() {
    return "Highlight, x: $mX, y: $mY, dataSetIndex: $mDataSetIndex, stackIndex (only stacked barentry): $mStackIndex";
  }
}
