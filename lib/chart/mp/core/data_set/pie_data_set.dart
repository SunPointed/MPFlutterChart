import 'dart:ui';

import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_pie_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/base_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/pie_entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/value_position.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';

class PieDataSet extends DataSet<PieEntry> implements IPieDataSet {
  /// the space in pixels between the chart-slices, default 0f
  double mSliceSpace = 0;
  bool mAutomaticallyDisableSliceSpacing = false;

  /// indicates the selection distance of a pie slice
  double mShift = 18;

  ValuePosition mXValuePosition = ValuePosition.INSIDE_SLICE;
  ValuePosition mYValuePosition = ValuePosition.INSIDE_SLICE;
  bool mUsingSliceColorAsValueLineColor = false;
  Color mValueLineColor = Color(0xff000000);
  double mValueLineWidth = 1.0;
  double mValueLinePart1OffsetPercentage = 75.0;
  double mValueLinePart1Length = 0.3;
  double mValueLinePart2Length = 0.4;
  bool mValueLineVariableLength = true;

  PieDataSet(List<PieEntry> yVals, String label) : super(yVals, label);

  @override
  DataSet<PieEntry> copy1() {
    List<PieEntry> entries = List();
    for (int i = 0; i < mValues.length; i++) {
      entries.add(mValues[i].copy());
    }
    PieDataSet copied = PieDataSet(entries, getLabel());
    copy(copied);
    return copied;
  }

  void copy(BaseDataSet baseDataSet) {
    super.copy(baseDataSet);
  }

  @override
  void calcMinMax1(PieEntry e) {
    if (e == null) return;
    calcMinMaxY1(e);
  }

  /// Sets the space that is left out between the piechart-slices in dp.
  /// Default: 0 --> no space, maximum 20f
  ///
  /// @param spaceDp
  void setSliceSpace(double spaceDp) {
    if (spaceDp > 20) spaceDp = 20;
    if (spaceDp < 0) spaceDp = 0;

    mSliceSpace = Utils.convertDpToPixel(spaceDp);
  }

  @override
  double getSliceSpace() {
    return mSliceSpace;
  }

  /// When enabled, slice spacing will be 0.0 when the smallest value is going to be
  /// smaller than the slice spacing itself.
  ///
  /// @param autoDisable
  void setAutomaticallyDisableSliceSpacing(bool autoDisable) {
    mAutomaticallyDisableSliceSpacing = autoDisable;
  }

  /// When enabled, slice spacing will be 0.0 when the smallest value is going to be
  /// smaller than the slice spacing itself.
  ///
  /// @return
  @override
  bool isAutomaticallyDisableSliceSpacingEnabled() {
    return mAutomaticallyDisableSliceSpacing;
  }

  /// sets the distance the highlighted piechart-slice of this DataSet is
  /// "shifted" away from the center of the chart, default 12f
  ///
  /// @param shift
  void setSelectionShift(double shift) {
    mShift = Utils.convertDpToPixel(shift);
  }

  @override
  double getSelectionShift() {
    return mShift;
  }

  @override
  ValuePosition getXValuePosition() {
    return mXValuePosition;
  }

  void setXValuePosition(ValuePosition xValuePosition) {
    this.mXValuePosition = xValuePosition;
  }

  @override
  ValuePosition getYValuePosition() {
    return mYValuePosition;
  }

  void setYValuePosition(ValuePosition yValuePosition) {
    this.mYValuePosition = yValuePosition;
  }

  /// When valuePosition is OutsideSlice, use slice colors as line color if true
  @override
  bool isUsingSliceColorAsValueLineColor() {
    return mUsingSliceColorAsValueLineColor;
  }

  void setUsingSliceColorAsValueLineColor(
      bool usingSliceColorAsValueLineColor) {
    this.mUsingSliceColorAsValueLineColor = usingSliceColorAsValueLineColor;
  }

  /// When valuePosition is OutsideSlice, indicates line color
  @override
  Color getValueLineColor() {
    return mValueLineColor;
  }

  void setValueLineColor(Color valueLineColor) {
    this.mValueLineColor = valueLineColor;
  }

  /// When valuePosition is OutsideSlice, indicates line width
  @override
  double getValueLineWidth() {
    return mValueLineWidth;
  }

  void setValueLineWidth(double valueLineWidth) {
    this.mValueLineWidth = valueLineWidth;
  }

  /// When valuePosition is OutsideSlice, indicates offset as percentage out of the slice size
  @override
  double getValueLinePart1OffsetPercentage() {
    return mValueLinePart1OffsetPercentage;
  }

  void setValueLinePart1OffsetPercentage(
      double valueLinePart1OffsetPercentage) {
    this.mValueLinePart1OffsetPercentage = valueLinePart1OffsetPercentage;
  }

  /// When valuePosition is OutsideSlice, indicates length of first half of the line
  @override
  double getValueLinePart1Length() {
    return mValueLinePart1Length;
  }

  void setValueLinePart1Length(double valueLinePart1Length) {
    this.mValueLinePart1Length = valueLinePart1Length;
  }

  /// When valuePosition is OutsideSlice, indicates length of second half of the line
  @override
  double getValueLinePart2Length() {
    return mValueLinePart2Length;
  }

  void setValueLinePart2Length(double valueLinePart2Length) {
    this.mValueLinePart2Length = valueLinePart2Length;
  }

  /// When valuePosition is OutsideSlice, this allows variable line length
  @override
  bool isValueLineVariableLength() {
    return mValueLineVariableLength;
  }

  void setValueLineVariableLength(bool valueLineVariableLength) {
    this.mValueLineVariableLength = valueLineVariableLength;
  }
}
