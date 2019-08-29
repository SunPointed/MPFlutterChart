import 'package:intl/intl.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis/axis_base.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis/x_axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/value_formatter/value_formatter.dart';

class MyValueFormatter extends ValueFormatter {
  NumberFormat mFormat;
  String suffix;

  MyValueFormatter(String suffix) {
    mFormat = NumberFormat("###,###,###,##0.0");
    this.suffix = suffix;
  }

  @override
  String getFormattedValue1(double value) {
    return mFormat.format(value) + suffix;
  }

  @override
  String getAxisLabel(double value, AxisBase axis) {
    if (axis is XAxis) {
      return mFormat.format(value);
    } else if (value > 0) {
      return mFormat.format(value) + suffix;
    } else {
      return mFormat.format(value);
    }
  }
}