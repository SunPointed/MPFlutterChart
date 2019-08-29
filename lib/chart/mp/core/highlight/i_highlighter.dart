import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';

mixin IHighlighter {
  Highlight getHighlight(double x, double y);
}