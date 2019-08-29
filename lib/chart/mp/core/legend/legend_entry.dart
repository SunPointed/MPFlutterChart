import 'dart:ui';

import 'package:mp_flutter_chart/chart/mp/core/enums/legend_form.dart';
import 'package:mp_flutter_chart/chart/mp/core/util.dart';

class LegendEntry {
  LegendEntry.empty();

  LegendEntry(
      String label,
      LegendForm form,
      double formSize,
      double formLineWidth,
//      DashPathEffect formLineDashEffect,
      Color formColor) {
    this.label = label;
    this.form = form;
    this.formSize = formSize;
    this.formLineWidth = formLineWidth;
//    this.formLineDashEffect = formLineDashEffect;
    this.formColor = formColor;
  }

  /**
   * The legend entry text.
   * A `null` label will start a group.
   */
  String label;

  /**
   * The form to draw for this entry.
   *
   * `NONE` will avoid drawing a form, and any related space.
   * `EMPTY` will avoid drawing a form, but keep its space.
   * `DEFAULT` will use the Legend's default.
   */
  LegendForm form = LegendForm.DEFAULT;

  /**
   * Form size will be considered except for when .None is used
   *
   * Set as NaN to use the legend's default
   */
  double formSize = double.nan;

  /**
   * Line width used for shapes that consist of lines.
   *
   * Set as NaN to use the legend's default
   */
  double formLineWidth = double.nan;

  /**
   * Line dash path effect used for shapes that consist of lines.
   *
   * Set to null to use the legend's default
   */
//   DashPathEffect formLineDashEffect = null;

  /**
   * The color for drawing the form
   */
  Color formColor = ColorUtils.COLOR_NONE;
}
