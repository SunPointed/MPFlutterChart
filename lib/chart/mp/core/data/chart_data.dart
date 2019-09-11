import 'dart:ui' as ui;

import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/axis_dependency.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/dart_adapter_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/value_formatter/value_formatter.dart';

class ChartData<T extends IDataSet<Entry>> {
  /// maximum y-value in the value array across all axes
  double mYMax = -double.infinity;

  /// the minimum y-value in the value array across all axes
  double mYMin = double.infinity;

  /// maximum x-value in the value array
  double mXMax = -double.infinity;

  /// minimum x-value in the value array
  double mXMin = double.infinity;

  double mLeftAxisMax = -double.infinity;

  double mLeftAxisMin = double.infinity;

  double mRightAxisMax = -double.infinity;

  double mRightAxisMin = double.infinity;

  /// array that holds all DataSets the ChartData object represents
  List<T> mDataSets;

  /// Default constructor.
  ChartData() {
    mDataSets = List<T>();
  }

  /// Constructor taking single or multiple DataSet objects.
  ///
  /// @param dataSets
  ChartData.fromList(List<T> dataSets) {
    mDataSets = dataSets;
    notifyDataChanged();
  }

  /// Call this method to let the ChartData know that the underlying data has
  /// changed. Calling this performs all necessary recalculations needed when
  /// the contained data has changed.
  void notifyDataChanged() {
    calcMinMax1();
  }

  /// Calc minimum and maximum y-values over all DataSets.
  /// Tell DataSets to recalculate their min and max y-values, this is only needed for autoScaleMinMax.
  ///
  /// @param fromX the x-value to start the calculation from
  /// @param toX   the x-value to which the calculation should be performed
  void calcMinMaxY(double fromX, double toX) {
    for (T set in mDataSets) {
      set.calcMinMaxY(fromX, toX);
    }

    // apply the  data
    calcMinMax1();
  }

  /// Calc minimum and maximum values (both x and y) over all DataSets.
  void calcMinMax1() {
    if (mDataSets == null) return;

    mYMax = -double.infinity;
    mYMin = double.infinity;
    mXMax = -double.infinity;
    mXMin = double.infinity;

    for (T set in mDataSets) {
      calcMinMax3(set);
    }

    mLeftAxisMax = -double.infinity;
    mLeftAxisMin = double.infinity;
    mRightAxisMax = -double.infinity;
    mRightAxisMin = double.infinity;

    // left axis
    T firstLeft = getFirstLeft(mDataSets);

    if (firstLeft != null) {
      mLeftAxisMax = firstLeft.getYMax();
      mLeftAxisMin = firstLeft.getYMin();

      for (T dataSet in mDataSets) {
        if (dataSet.getAxisDependency() == AxisDependency.LEFT) {
          if (dataSet.getYMin() < mLeftAxisMin)
            mLeftAxisMin = dataSet.getYMin();

          if (dataSet.getYMax() > mLeftAxisMax)
            mLeftAxisMax = dataSet.getYMax();
        }
      }
    }

    // right axis
    T firstRight = getFirstRight(mDataSets);

    if (firstRight != null) {
      mRightAxisMax = firstRight.getYMax();
      mRightAxisMin = firstRight.getYMin();

      for (T dataSet in mDataSets) {
        if (dataSet.getAxisDependency() == AxisDependency.RIGHT) {
          if (dataSet.getYMin() < mRightAxisMin)
            mRightAxisMin = dataSet.getYMin();

          if (dataSet.getYMax() > mRightAxisMax)
            mRightAxisMax = dataSet.getYMax();
        }
      }
    }
  }

  /** ONLY GETTERS AND SETTERS BELOW THIS */

  /// returns the number of LineDataSets this object contains
  ///
  /// @return
  int getDataSetCount() {
    if (mDataSets == null) return 0;
    return mDataSets.length;
  }

  /// Returns the smallest y-value the data object contains.
  ///
  /// @return
  double getYMin1() {
    return mYMin;
  }

  /// Returns the minimum y-value for the specified axis.
  ///
  /// @param axis
  /// @return
  double getYMin2(AxisDependency axis) {
    if (axis == AxisDependency.LEFT) {
      if (mLeftAxisMin.isInfinite) {
        return mRightAxisMin;
      } else
        return mLeftAxisMin;
    } else {
      if (mRightAxisMin.isInfinite) {
        return mLeftAxisMin;
      } else
        return mRightAxisMin;
    }
  }

  /// Returns the greatest y-value the data object contains.
  ///
  /// @return
  double getYMax1() {
    return mYMax;
  }

  /// Returns the maximum y-value for the specified axis.
  ///
  /// @param axis
  /// @return
  double getYMax2(AxisDependency axis) {
    if (axis == AxisDependency.LEFT) {
      if (mLeftAxisMax == -double.infinity) {
        return mRightAxisMax;
      } else
        return mLeftAxisMax;
    } else {
      if (mRightAxisMax == -double.infinity) {
        return mLeftAxisMax;
      } else
        return mRightAxisMax;
    }
  }

  /// Returns the minimum x-value this data object contains.
  ///
  /// @return
  double getXMin() {
    return mXMin;
  }

  double getXMax() {
    return mXMax;
  }

  /// Returns all DataSet objects this ChartData object holds.
  ///
  /// @return
  List<T> getDataSets() {
    return mDataSets;
  }

  /// Retrieve the index of a DataSet with a specific label from the ChartData.
  /// Search can be case sensitive or not. IMPORTANT: This method does
  /// calculations at runtime, do not over-use in performance critical
  /// situations.
  ///
  /// @param dataSets   the DataSet array to search
  /// @param label
  /// @param ignorecase if true, the search is not case-sensitive
  /// @return
  int getDataSetIndexByLabel(List<T> dataSets, String label, bool ignorecase) {
    if (ignorecase) {
      for (int i = 0; i < dataSets.length; i++)
        if (DartAdapterUtils.equalsIgnoreCase(label, dataSets[i].getLabel()))
          return i;
    } else {
      for (int i = 0; i < dataSets.length; i++)
        if (label == dataSets[i].getLabel()) return i;
    }

    return -1;
  }

  /// Returns the labels of all DataSets as a string array.
  ///
  /// @return
  List<String> getDataSetLabels() {
    List<String> types = List(mDataSets.length);

    for (int i = 0; i < mDataSets.length; i++) {
      types[i] = mDataSets[i].getLabel();
    }

    return types;
  }

  /// Get the Entry for a corresponding highlight object
  ///
  /// @param highlight
  /// @return the entry that is highlighted
  Entry getEntryForHighlight(Highlight highlight) {
    if (highlight.getDataSetIndex() >= mDataSets.length)
      return null;
    else {
      return mDataSets[highlight.getDataSetIndex()]
          .getEntryForXValue2(highlight.getX(), highlight.getY());
    }
  }

  /// Returns the DataSet object with the given label. Search can be case
  /// sensitive or not. IMPORTANT: This method does calculations at runtime.
  /// Use with care in performance critical situations.
  ///
  /// @param label
  /// @param ignorecase
  /// @return
  T getDataSetByLabel(String label, bool ignorecase) {
    int index = getDataSetIndexByLabel(mDataSets, label, ignorecase);

    if (index < 0 || index >= mDataSets.length)
      return null;
    else
      return mDataSets[index];
  }

  T getDataSetByIndex(int index) {
    if (mDataSets == null || index < 0 || index >= mDataSets.length)
      return null;

    return mDataSets[index];
  }

  /// Adds a DataSet dynamically.
  ///
  /// @param d
  void addDataSet(T d) {
    if (d == null) return;

    calcMinMax3(d);

    mDataSets.add(d);
  }

  /// Removes the given DataSet from this data object. Also recalculates all
  /// minimum and maximum values. Returns true if a DataSet was removed, false
  /// if no DataSet could be removed.
  ///
  /// @param d
  bool removeDataSet1(T d) {
    if (d == null) return false;

    bool removed = mDataSets.remove(d);

    // if a DataSet was removed
    if (removed) {
      calcMinMax1();
    }

    return removed;
  }

  /// Removes the DataSet at the given index in the DataSet array from the data
  /// object. Also recalculates all minimum and maximum values. Returns true if
  /// a DataSet was removed, false if no DataSet could be removed.
  ///
  /// @param index
  bool removeDataSet2(int index) {
    if (index >= mDataSets.length || index < 0) return false;

    T set = mDataSets[index];
    return removeDataSet1(set);
  }

  /// Adds an Entry to the DataSet at the specified index.
  /// Entries are added to the end of the list.
  ///
  /// @param e
  /// @param dataSetIndex
  void addEntry(Entry e, int dataSetIndex) {
    if (mDataSets.length > dataSetIndex && dataSetIndex >= 0) {
      IDataSet set = mDataSets[dataSetIndex];
      // add the entry to the dataset
      if (!set.addEntry(e)) return;

      calcMinMax2(e, set.getAxisDependency());
    }
  }

  /// Adjusts the current minimum and maximum values based on the provided Entry object.
  ///
  /// @param e
  /// @param axis
  void calcMinMax2(Entry e, AxisDependency axis) {
    if (mYMax < e.y) mYMax = e.y;
    if (mYMin > e.y) mYMin = e.y;

    if (mXMax < e.x) mXMax = e.x;
    if (mXMin > e.x) mXMin = e.x;

    if (axis == AxisDependency.LEFT) {
      if (mLeftAxisMax < e.y) mLeftAxisMax = e.y;
      if (mLeftAxisMin > e.y) mLeftAxisMin = e.y;
    } else {
      if (mRightAxisMax < e.y) mRightAxisMax = e.y;
      if (mRightAxisMin > e.y) mRightAxisMin = e.y;
    }
  }

  /// Adjusts the minimum and maximum values based on the given DataSet.
  ///
  /// @param d
  void calcMinMax3(T d) {
    if (mYMax < d.getYMax()) mYMax = d.getYMax();
    if (mYMin > d.getYMin()) mYMin = d.getYMin();

    if (mXMax < d.getXMax()) mXMax = d.getXMax();
    if (mXMin > d.getXMin()) mXMin = d.getXMin();

    if (d.getAxisDependency() == AxisDependency.LEFT) {
      if (mLeftAxisMax < d.getYMax()) mLeftAxisMax = d.getYMax();
      if (mLeftAxisMin > d.getYMin()) mLeftAxisMin = d.getYMin();
    } else {
      if (mRightAxisMax < d.getYMax()) mRightAxisMax = d.getYMax();
      if (mRightAxisMin > d.getYMin()) mRightAxisMin = d.getYMin();
    }
  }

  /// Removes the given Entry object from the DataSet at the specified index.
  ///
  /// @param e
  /// @param dataSetIndex
  bool removeEntry1(Entry e, int dataSetIndex) {
    // entry null, outofbounds
    if (e == null || dataSetIndex >= mDataSets.length) return false;

    IDataSet set = mDataSets[dataSetIndex];

    if (set != null) {
      // remove the entry from the dataset
      bool removed = set.removeEntry1(e);

      if (removed) {
        calcMinMax1();
      }

      return removed;
    } else
      return false;
  }

  /// Removes the Entry object closest to the given DataSet at the
  /// specified index. Returns true if an Entry was removed, false if no Entry
  /// was found that meets the specified requirements.
  ///
  /// @param xValue
  /// @param dataSetIndex
  /// @return
  bool removeEntry2(double xValue, int dataSetIndex) {
    if (dataSetIndex >= mDataSets.length) return false;

    IDataSet dataSet = mDataSets[dataSetIndex];
    Entry e = dataSet.getEntryForXValue2(xValue, double.nan);

    if (e == null) return false;

    return removeEntry1(e, dataSetIndex);
  }

  /// Returns the DataSet that contains the provided Entry, or null, if no
  /// DataSet contains this Entry.
  ///
  /// @param e
  /// @return
  T getDataSetForEntry(Entry e) {
    if (e == null) return null;

    for (int i = 0; i < mDataSets.length; i++) {
      T set = mDataSets[i];

      for (int j = 0; j < set.getEntryCount(); j++) {
        if (e == set.getEntryForXValue2(e.x, e.y)) return set;
      }
    }

    return null;
  }

  /// Returns all colors used across all DataSet objects this object
  /// represents.
  ///
  /// @return
  List<ui.Color> getColors() {
    if (mDataSets == null) return null;

    int clrcnt = 0;

    for (int i = 0; i < mDataSets.length; i++) {
      clrcnt += mDataSets[i].getColors().length;
    }

    List<ui.Color> colors = List(clrcnt);
    int cnt = 0;

    for (int i = 0; i < mDataSets.length; i++) {
      List<ui.Color> clrs = mDataSets[i].getColors();

      for (ui.Color clr in clrs) {
        colors[cnt] = clr;
        cnt++;
      }
    }

    return colors;
  }

  /// Returns the index of the provided DataSet in the DataSet array of this data object, or -1 if it does not exist.
  ///
  /// @param dataSet
  /// @return
  int getIndexOfDataSet(T dataSet) {
    return mDataSets.indexOf(dataSet);
  }

  /// Returns the first DataSet from the datasets-array that has it's dependency on the left axis.
  /// Returns null if no DataSet with left dependency could be found.
  ///
  /// @return
  T getFirstLeft(List<T> sets) {
    for (T dataSet in sets) {
      if (dataSet.getAxisDependency() == AxisDependency.LEFT) return dataSet;
    }
    return null;
  }

  /// Returns the first DataSet from the datasets-array that has it's dependency on the right axis.
  /// Returns null if no DataSet with right dependency could be found.
  ///
  /// @return
  T getFirstRight(List<T> sets) {
    for (T dataSet in sets) {
      if (dataSet.getAxisDependency() == AxisDependency.RIGHT) return dataSet;
    }
    return null;
  }

  /// Sets a custom IValueFormatter for all DataSets this data object contains.
  ///
  /// @param f
  void setValueFormatter(ValueFormatter f) {
    if (f == null)
      return;
    else {
      for (IDataSet set in mDataSets) {
        set.setValueFormatter(f);
      }
    }
  }

  /// Sets the color of the value-text (color in which the value-labels are
  /// drawn) for all DataSets this data object contains.
  ///
  /// @param color
  void setValueTextColor(ui.Color color) {
    for (IDataSet set in mDataSets) {
      set.setValueTextColor(color);
    }
  }

  /// Sets the same list of value-colors for all DataSets this
  /// data object contains.
  ///
  /// @param colors
  void setValueTextColors(List<ui.Color> colors) {
    for (IDataSet set in mDataSets) {
      set.setValueTextColors(colors);
    }
  }

  /// Sets the Typeface for all value-labels for all DataSets this data object
  /// contains.
  ///
  /// @param tf
  void setValueTypeface(ui.TextStyle tf) {
    for (IDataSet set in mDataSets) {
      set.setValueTypeface(tf);
    }
  }

  /// Sets the size (in dp) of the value-text for all DataSets this data object
  /// contains.
  ///
  /// @param size
  void setValueTextSize(double size) {
    for (IDataSet set in mDataSets) {
      set.setValueTextSize(size);
    }
  }

  /// Enables / disables drawing values (value-text) for all DataSets this data
  /// object contains.
  ///
  /// @param enabled
  void setDrawValues(bool enabled) {
    for (IDataSet set in mDataSets) {
      set.setDrawValues(enabled);
    }
  }

  /// Enables / disables highlighting values for all DataSets this data object
  /// contains. If set to true, this means that values can
  /// be highlighted programmatically or by touch gesture.
  void setHighlightEnabled(bool enabled) {
    for (IDataSet set in mDataSets) {
      set.setHighlightEnabled(enabled);
    }
  }

  /// Returns true if highlighting of all underlying values is enabled, false
  /// if not.
  ///
  /// @return
  bool isHighlightEnabled() {
    for (IDataSet set in mDataSets) {
      if (!set.isHighlightEnabled()) return false;
    }
    return true;
  }

  /// Clears this data object from all DataSets and removes all Entries. Don't
  /// forget to invalidate the chart after this.
  void clearValues() {
    if (mDataSets != null) {
      mDataSets.clear();
    }
    notifyDataChanged();
  }

  /// Checks if this data object contains the specified DataSet. Returns true
  /// if so, false if not.
  ///
  /// @param dataSet
  /// @return
  bool contains(T dataSet) {
    for (T set in mDataSets) {
      if (set == dataSet) return true;
    }
    return false;
  }

  /// Returns the total entry count across all DataSet objects this data object contains.
  ///
  /// @return
  int getEntryCount() {
    int count = 0;
    for (T set in mDataSets) {
      count += set.getEntryCount();
    }
    return count;
  }

  /// Returns the DataSet object with the maximum number of entries or null if there are no DataSets.
  ///
  /// @return
  T getMaxEntryCountSet() {
    if (mDataSets == null || mDataSets.isEmpty) return null;
    T max = mDataSets[0];
    for (T set in mDataSets) {
      if (set.getEntryCount() > max.getEntryCount()) max = set;
    }
    return max;
  }
}
