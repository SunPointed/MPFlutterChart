import 'package:intl/intl.dart';
import 'package:mp_flutter_chart/chart/mp/core/value_formatter/value_formatter.dart';

class DefaultAxisValueFormatter extends ValueFormatter {
  /// decimalformat for formatting
  NumberFormat mFormat;

  /// the number of decimal digits this formatter uses
  int digits;

  /// Constructor that specifies to how many digits the value should be
  /// formatted.
  ///
  /// @param digits
  DefaultAxisValueFormatter(int digits) {
    this.digits = digits;

    StringBuffer b = StringBuffer();
    for (int i = 0; i < digits; i++) {
      if (i == 0) b.write(".");
      b.write("0");
    }

    mFormat = NumberFormat("###,###,###,##0" + b.toString());
  }

  @override
  String getFormattedValue1(double value) {
    // avoid memory allocations here (for performance)
    return mFormat.format(value);
  }

  /// Returns the number of decimal digits this formatter uses or -1, if unspecified.
  ///
  /// @return
  int getDecimalDigits() {
    return digits;
  }
}
