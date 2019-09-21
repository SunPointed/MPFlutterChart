import 'package:intl/intl.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/pie_entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/value_formatter/value_formatter.dart';
import 'package:mp_flutter_chart/chart/mp/painter/pie_chart_painter.dart';

class PercentFormatter extends ValueFormatter {
  NumberFormat _format;
  PieChartPainter _painter;
  bool _percentSignSeparated;

  PercentFormatter() {
    _format = NumberFormat("###,###,##0.0");
    _percentSignSeparated = true;
  }

  setPieChartPainter(PieChartPainter painter) {
    _painter = painter;
  }

  @override
  String getFormattedValue1(double value) {
    return _format.format(value) + (_percentSignSeparated ? " %" : "%");
  }

  @override
  String getPieLabel(double value, PieEntry pieEntry) {
    if (_painter != null && _painter.isUsePercentValuesEnabled()) {
      // Converted to percent
      return getFormattedValue1(value);
    } else {
      // raw value, skip percent sign
      return _format.format(value);
    }
  }
}
