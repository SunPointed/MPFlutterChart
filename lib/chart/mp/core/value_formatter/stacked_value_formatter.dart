import 'package:intl/intl.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/bar_entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/value_formatter/value_formatter.dart';

class StackedValueFormatter extends ValueFormatter {
  /**
   * if true, all stack values of the stacked bar entry are drawn, else only top
   */
  bool mDrawWholeStack;

  /**
   * a string that should be appended behind the value
   */
  String mSuffix;

  NumberFormat mFormat;

  /**
   * Constructor.
   *
   * @param drawWholeStack if true, all stack values of the stacked bar entry are drawn, else only top
   * @param suffix         a string that should be appended behind the value
   * @param decimals       the number of decimal digits to use
   */
  StackedValueFormatter(bool drawWholeStack, String suffix, int decimals) {
    this.mDrawWholeStack = drawWholeStack;
    this.mSuffix = suffix;

    StringBuffer b = new StringBuffer();
    for (int i = 0; i < decimals; i++) {
      if (i == 0) b.write(".");
      b.write("0");
    }

    this.mFormat = NumberFormat("###,###,###,##0" + b.toString());
  }

  @override
  String getBarStackedLabel(double value, BarEntry entry) {
    if (!mDrawWholeStack) {
      List<double> vals = entry.getYVals();

      if (vals != null) {
        // find out if we are on top of the stack
        if (vals[vals.length - 1] == value) {
          // return the "sum" across all stack values
          return mFormat.format(entry.y) + mSuffix;
        } else {
          return ""; // return empty
        }
      }
    }
    // return the "proposed" value
    return mFormat.format(value) + mSuffix;
  }
}
