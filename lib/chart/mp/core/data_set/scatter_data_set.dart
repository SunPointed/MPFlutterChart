import 'dart:ui';

import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_scatter_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/base_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/line_scatter_candle_radar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/scatter_shape.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/chevron_down_shape_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/chevron_up_shape_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/circle_shape_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/cross_shape_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/i_shape_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/square_shape_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/triangle_shape_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/x_shape_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/util.dart';

class ScatterDataSet extends LineScatterCandleRadarDataSet<Entry>
    implements IScatterDataSet {
  /**
   * the size the scattershape will have, in density pixels
   */
  double mShapeSize = 15;

  /**
   * Renderer responsible for rendering this DataSet, default: square
   */
  IShapeRenderer mShapeRenderer = SquareShapeRenderer();

  /**
   * The radius of the hole in the shape (applies to Square, Circle and Triangle)
   * - default: 0.0
   */
  double mScatterShapeHoleRadius = 0;

  /**
   * Color for the hole in the shape.
   * Setting to `ColorUtils.COLOR_NONE` will behave as transparent.
   * - default: ColorUtils.COLOR_NONE
   */
  Color mScatterShapeHoleColor = ColorUtils.COLOR_NONE;

  ScatterDataSet(List<Entry> yVals, String label) : super(yVals, label);

  @override
  DataSet<Entry> copy1() {
    List<Entry> entries = List<Entry>();
    for (int i = 0; i < mValues.length; i++) {
      entries.add(mValues[i].copy());
    }
    ScatterDataSet copied = ScatterDataSet(entries, getLabel());
    copy(copied);
    return copied;
  }

  @override
  void copy(BaseDataSet baseDataSet) {
    super.copy(baseDataSet);
    if (baseDataSet is ScatterDataSet) {
      var scatterDataSet = baseDataSet;
      scatterDataSet.mShapeSize = mShapeSize;
      scatterDataSet.mShapeRenderer = mShapeRenderer;
      scatterDataSet.mScatterShapeHoleRadius = mScatterShapeHoleRadius;
      scatterDataSet.mScatterShapeHoleColor = mScatterShapeHoleColor;
    }
  }

  /**
   * Sets the size in density pixels the drawn scattershape will have. This
   * only applies for non custom shapes.
   *
   * @param size
   */
  void setScatterShapeSize(double size) {
    mShapeSize = size;
  }

  @override
  double getScatterShapeSize() {
    return mShapeSize;
  }

  /**
   * Sets the ScatterShape this DataSet should be drawn with. This will search for an available IShapeRenderer and set this
   * renderer for the DataSet.
   *
   * @param shape
   */
  void setScatterShape(ScatterShape shape) {
    mShapeRenderer = getRendererForShape(shape);
  }

  /**
   * Sets a  IShapeRenderer responsible for drawing this DataSet.
   * This can also be used to set a custom IShapeRenderer aside from the default ones.
   *
   * @param shapeRenderer
   */
  void setShapeRenderer(IShapeRenderer shapeRenderer) {
    mShapeRenderer = shapeRenderer;
  }

  @override
  IShapeRenderer getShapeRenderer() {
    return mShapeRenderer;
  }

  /**
   * Sets the radius of the hole in the shape (applies to Square, Circle and Triangle)
   * Set this to <= 0 to remove holes.
   *
   * @param holeRadius
   */
  void setScatterShapeHoleRadius(double holeRadius) {
    mScatterShapeHoleRadius = holeRadius;
  }

  @override
  double getScatterShapeHoleRadius() {
    return mScatterShapeHoleRadius;
  }

  /**
   * Sets the color for the hole in the shape.
   *
   * @param holeColor
   */
  void setScatterShapeHoleColor(Color holeColor) {
    mScatterShapeHoleColor = holeColor;
  }

  @override
  Color getScatterShapeHoleColor() {
    return mScatterShapeHoleColor;
  }

  static IShapeRenderer getRendererForShape(ScatterShape shape) {
    switch (shape) {
      case ScatterShape.SQUARE:
        return SquareShapeRenderer();
      case ScatterShape.CIRCLE:
        return CircleShapeRenderer();
      case ScatterShape.TRIANGLE:
        return TriangleShapeRenderer();
      case ScatterShape.CROSS:
        return CrossShapeRenderer();
      case ScatterShape.X:
        return XShapeRenderer();
      case ScatterShape.CHEVRON_UP:
        return ChevronUpShapeRenderer();
      case ScatterShape.CHEVRON_DOWN:
        return ChevronDownShapeRenderer();
    }

    return null;
  }
}
