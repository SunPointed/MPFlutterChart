import 'package:intl/intl.dart';
import 'package:mp_flutter_chart/chart/mp/core/value_formatter/value_formatter.dart';

class DefaultValueFormatter extends ValueFormatter {
  /**
   * DecimalFormat for formatting
   */
  NumberFormat mFormat;

  int mDecimalDigits;

  /**
   * Constructor that specifies to how many digits the value should be
   * formatted.
   *
   * @param digits
   */
  DefaultValueFormatter(int digits) {
    setup(digits);
  }

  /**
   * Sets up the formatter with a given number of decimal digits.
   *
   * @param digits
   */
  void setup(int digits) {
    this.mDecimalDigits = digits;

    if (digits < 1) {
      digits = 1;
    }

    StringBuffer b = StringBuffer();
    b.write(".");
    for (int i = 0; i < digits; i++) {
      b.write("0");
    }
    mFormat = NumberFormat("###,###,###,##0" + b.toString());
  }

  @override
  String getFormattedValue1(double value) {
    // put more logic here ...
    // avoid memory allocations here (for performance reasons)

    return mFormat.format(value);
  }

  @override
  String toString() {
    return mFormat.toString();
  }

  /**
   * Returns the number of decimal digits this formatter uses.
   *
   * @return
   */
  int getDecimalDigits() {
    return mDecimalDigits;
  }
}