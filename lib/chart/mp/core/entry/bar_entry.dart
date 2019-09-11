import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'dart:ui' as ui;

import 'package:mp_flutter_chart/chart/mp/core/range.dart';

class BarEntry extends Entry {
  /// the values the stacked barchart holds
  List<double> mYVals;

  /// the ranges for the individual stack values - automatically calculated
  List<Range> mRanges;

  /// the sum of all negative values this entry (if stacked) contains
  double mNegativeSum;

  /// the sum of all positive values this entry (if stacked) contains
  double mPositiveSum;

  BarEntry({double x, double y, ui.Image icon, Object data})
      : super(x: x, y: y, icon: icon, data: data);

  BarEntry.fromListYVals(
      {double x, List<double> vals, ui.Image icon, Object data})
      : super(x: x, y: calcSum(vals), icon: icon, data: data) {
    this.mYVals = vals;
    calcPosNegSum();
    calcRanges();
  }

  BarEntry copy() {
    BarEntry copied = BarEntry(x: x, y: y, data: mData);
    copied.setVals(mYVals);
    return copied;
  }

  /// Returns the stacked values this BarEntry represents, or null, if only a single value is represented (then, use
  /// getY()).
  ///
  /// @return
  List<double> getYVals() {
    return mYVals;
  }

  /// Set the array of values this BarEntry should represent.
  ///
  /// @param vals
  void setVals(List<double> vals) {
    y = calcSum(vals);
    mYVals = vals;
    calcPosNegSum();
    calcRanges();
  }

  /// Returns the ranges of the individual stack-entries. Will return null if this entry is not stacked.
  ///
  /// @return
  List<Range> getRanges() {
    return mRanges;
  }

  /// Returns true if this BarEntry is stacked (has a values array), false if not.
  ///
  /// @return
  bool isStacked() {
    return mYVals != null;
  }

  double getSumBelow(int stackIndex) {
    if (mYVals == null) return 0;

    double remainder = 0.0;
    int index = mYVals.length - 1;
    while (index > stackIndex && index >= 0) {
      remainder += mYVals[index];
      index--;
    }

    return remainder;
  }

  /// Reuturns the sum of all positive values this entry (if stacked) contains.
  ///
  /// @return
  double getPositiveSum() {
    return mPositiveSum;
  }

  /// Returns the sum of all negative values this entry (if stacked) contains. (this is a positive number)
  ///
  /// @return
  double getNegativeSum() {
    return mNegativeSum;
  }

  void calcPosNegSum() {
    if (mYVals == null) {
      mNegativeSum = 0;
      mPositiveSum = 0;
      return;
    }

    double sumNeg = 0.0;
    double sumPos = 0.0;

    for (double f in mYVals) {
      if (f <= 0.0)
        sumNeg += f.abs();
      else
        sumPos += f;
    }

    mNegativeSum = sumNeg;
    mPositiveSum = sumPos;
  }

  /// Calculates the sum across all values of the given stack.
  ///
  /// @param vals
  /// @return
  static double calcSum(List<double> vals) {
    if (vals == null) return 0.0;
    double sum = 0.0;
    for (double f in vals) sum += f;
    return sum;
  }

  void calcRanges() {
    List<double> values = getYVals();

    if (values == null || values.length == 0) return;

    mRanges = List(values.length);

    double negRemain = -getNegativeSum();
    double posRemain = 0.0;

    for (int i = 0; i < mRanges.length; i++) {
      double value = values[i];

      if (value < 0) {
        mRanges[i] = Range(negRemain, negRemain - value);
        negRemain -= value;
      } else {
        mRanges[i] = Range(posRemain, posRemain + value);
        posRemain += value;
      }
    }
  }
}