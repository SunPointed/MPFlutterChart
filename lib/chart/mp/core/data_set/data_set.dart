import 'package:mp_flutter_chart/chart/mp/core/data_set/base_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/rounding.dart';

abstract class DataSet<T extends Entry> extends BaseDataSet<T> {
  /// the entries that this DataSet represents / holds together
  List<T> mValues = null;

  /// maximum y-value in the value array
  double mYMax = -double.maxFinite;

  /// minimum y-value in the value array
  double mYMin = double.maxFinite;

  /// maximum x-value in the value array
  double mXMax = -double.maxFinite;

  /// minimum x-value in the value array
  double mXMin = double.maxFinite;

  /// Creates a  DataSet object with the given values (entries) it represents. Also, a
  /// label that describes the DataSet can be specified. The label can also be
  /// used to retrieve the DataSet from a ChartData object.
  ///
  /// @param values
  /// @param label
  DataSet(List<T> values, String label) : super.withLabel(label) {
    this.mValues = values;

    if (mValues == null) mValues = List<T>();

    calcMinMax();
  }

  @override
  void calcMinMax() {
    if (mValues == null || mValues.isEmpty) return;

    mYMax = -double.maxFinite;
    mYMin = double.maxFinite;
    mXMax = -double.maxFinite;
    mXMin = double.maxFinite;

    for (T e in mValues) {
      calcMinMax1(e);
    }
  }

  @override
  void calcMinMaxY(double fromX, double toX) {
    if (mValues == null || mValues.isEmpty) return;

    mYMax = -double.maxFinite;
    mYMin = double.maxFinite;

    int indexFrom = getEntryIndex1(fromX, double.nan, Rounding.DOWN);
    int indexTo = getEntryIndex1(toX, double.nan, Rounding.UP);

    for (int i = indexFrom; i <= indexTo; i++) {
      // only recalculate y
      calcMinMaxY1(mValues[i]);
    }
  }

  /// Updates the min and max x and y value of this DataSet based on the given Entry.
  ///
  /// @param e
  void calcMinMax1(T e) {
    if (e == null) return;

    calcMinMaxX1(e);

    calcMinMaxY1(e);
  }

  void calcMinMaxX1(T e) {
    if (e.x < mXMin) mXMin = e.x;

    if (e.x > mXMax) mXMax = e.x;
  }

  void calcMinMaxY1(T e) {
    if (e.y < mYMin) mYMin = e.y;

    if (e.y > mYMax) mYMax = e.y;
  }

  @override
  int getEntryCount() {
    return mValues.length;
  }

  /// Returns the array of entries that this DataSet represents.
  ///
  /// @return
  List<T> getValues() {
    return mValues;
  }

  /// Sets the array of entries that this DataSet represents, and calls notifyDataSetChanged()
  ///
  /// @return
  void setValues(List<T> values) {
    mValues = values;
    notifyDataSetChanged();
  }

  /// Provides an exact copy of the DataSet this method is used on.
  ///
  /// @return
  DataSet<T> copy1();

  ///
  /// @param dataSet
  void copy2(DataSet dataSet) {
    super.copy(dataSet);
  }

  @override
  String toString() {
    StringBuffer buffer = StringBuffer();
    buffer.write(toSimpleString());
    for (int i = 0; i < mValues.length; i++) {
      buffer.write(mValues[i].toString() + " ");
    }
    return buffer.toString();
  }

  /// Returns a simple string representation of the DataSet with the type and
  /// the number of Entries.
  ///
  /// @return
  String toSimpleString() {
    StringBuffer buffer = StringBuffer();
    buffer.write("DataSet, label: " +
        (getLabel() == null ? "" : getLabel()) +
        ", entries:${mValues.length}\n");
    return buffer.toString();
  }

  @override
  double getYMin() {
    return mYMin;
  }

  @override
  double getYMax() {
    return mYMax;
  }

  @override
  double getXMin() {
    return mXMin;
  }

  @override
  double getXMax() {
    return mXMax;
  }

  @override
  void addEntryOrdered(T e) {
    if (e == null) return;

    if (mValues == null) {
      mValues = List<T>();
    }

    calcMinMax1(e);

    if (mValues.length > 0 && mValues[mValues.length - 1].x > e.x) {
      int closestIndex = getEntryIndex1(e.x, e.y, Rounding.UP);
      mValues.insert(closestIndex, e);
    } else {
      mValues.add(e);
    }
  }

  @override
  void clear() {
    mValues.clear();
    notifyDataSetChanged();
  }

  @override
  bool addEntry(T e) {
    if (e == null) return false;

    List<T> values = getValues();
    if (values == null) {
      values = List<T>();
    }

    calcMinMax1(e);

    // add the entry
    values.add(e);
    return true;
  }

  @override
  bool removeEntry1(T e) {
    if (e == null) return false;

    if (mValues == null) return false;

    // remove the entry
    bool removed = mValues.remove(e);

    if (removed) {
      calcMinMax();
    }

    return removed;
  }

  @override
  int getEntryIndex2(Entry e) {
    return mValues.indexOf(e);
  }

  @override
  T getEntryForXValue1(double xValue, double closestToY, Rounding rounding) {
    int index = getEntryIndex1(xValue, closestToY, rounding);
    if (index > -1) return mValues[index];
    return null;
  }

  @override
  T getEntryForXValue2(double xValue, double closestToY) {
    return getEntryForXValue1(xValue, closestToY, Rounding.CLOSEST);
  }

  @override
  T getEntryForIndex(int index) {
    return mValues[index];
  }

  @override
  int getEntryIndex1(double xValue, double closestToY, Rounding rounding) {
    if (mValues == null || mValues.isEmpty) return -1;

    int low = 0;
    int high = mValues.length - 1;
    int closest = high;

    while (low < high) {
      int m = (low + high) ~/ 2;

      final double d1 = mValues[m].x - xValue,
          d2 = mValues[m + 1].x - xValue,
          ad1 = d1.abs(),
          ad2 = d2.abs();

      if (ad2 < ad1) {
        // [m + 1] is closer to xValue
        // Search in an higher place
        low = m + 1;
      } else if (ad1 < ad2) {
        // [m] is closer to xValue
        // Search in a lower place
        high = m;
      } else {
        // We have multiple sequential x-value with same distance

        if (d1 >= 0.0) {
          // Search in a lower place
          high = m;
        } else if (d1 < 0.0) {
          // Search in an higher place
          low = m + 1;
        }
      }

      closest = high;
    }

    if (closest != -1) {
      double closestXValue = mValues[closest].x;
      if (rounding == Rounding.UP) {
        // If rounding up, and found x-value is lower than specified x, and we can go upper...
        if (closestXValue < xValue && closest < mValues.length - 1) {
          ++closest;
        }
      } else if (rounding == Rounding.DOWN) {
        // If rounding down, and found x-value is upper than specified x, and we can go lower...
        if (closestXValue > xValue && closest > 0) {
          --closest;
        }
      }

      // Search by closest to y-value
      if (!(closestToY.isNaN)) {
        while (closest > 0 && mValues[closest - 1].x == closestXValue)
          closest -= 1;

        double closestYValue = mValues[closest].y;
        int closestYIndex = closest;

        while (true) {
          closest += 1;
          if (closest >= mValues.length) break;

          final Entry value = mValues[closest];

          if (value.x != closestXValue) break;

          if ((value.y - closestToY).abs() <
              (closestYValue - closestToY).abs()) {
            closestYValue = closestToY;
            closestYIndex = closest;
          }
        }

        closest = closestYIndex;
      }
    }

    return closest;
  }

  @override
  List<T> getEntriesForXValue(double xValue) {
    List<T> entries = List<T>();

    int low = 0;
    int high = mValues.length - 1;

    while (low <= high) {
      int m = (high + low) ~/ 2;
      T entry = mValues[m];

      // if we have a match
      if (xValue == entry.x) {
        while (m > 0 && mValues[m - 1].x == xValue) m--;

        high = mValues.length;

        // loop over all "equal" entries
        for (; m < high; m++) {
          entry = mValues[m];
          if (entry.x == xValue) {
            entries.add(entry);
          } else {
            break;
          }
        }

        break;
      } else {
        if (xValue > entry.x)
          low = m + 1;
        else
          high = m - 1;
      }
    }

    return entries;
  }
}
