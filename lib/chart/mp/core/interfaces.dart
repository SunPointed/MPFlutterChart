import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/data.dart';
import 'package:mp_flutter_chart/chart/mp/core/format.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/mode.dart';
import 'package:mp_flutter_chart/chart/mp/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/core/transformer.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';

mixin ChartInterface {
  /**
   * Returns the minimum x value of the chart, regardless of zoom or translation.
   *
   * @return
   */
  double getXChartMin();

  /**
   * Returns the maximum x value of the chart, regardless of zoom or translation.
   *
   * @return
   */
  double getXChartMax();

  double getXRange();

  /**
   * Returns the minimum y value of the chart, regardless of zoom or translation.
   *
   * @return
   */
  double getYChartMin();

  /**
   * Returns the maximum y value of the chart, regardless of zoom or translation.
   *
   * @return
   */
  double getYChartMax();

  /**
   * Returns the maximum distance in scren dp a touch can be away from an entry to cause it to get highlighted.
   *
   * @return
   */
  double getMaxHighlightDistance();

  MPPointF getCenterOfView(Size size);

  MPPointF getCenterOffsets();

  Rect getContentRect();

  ValueFormatter getDefaultValueFormatter();

  ChartData getData();

  int getMaxVisibleCount();
}

mixin IHighlighter {
  Highlight getHighlight(double x, double y);
}

abstract class IMarker {
  /**
   * @return The desired (general) offset you wish the IMarker to have on the x- and y-axis.
   *         By returning x: -(width / 2) you will center the IMarker horizontally.
   *         By returning y: -(height / 2) you will center the IMarker vertically.
   */
  MPPointF getOffset();

  /**
   * @return The offset for drawing at the specific `point`. This allows conditional adjusting of the Marker position.
   *         If you have no adjustments to make, return getOffset().
   *
   * @param posX This is the X position at which the marker wants to be drawn.
   *             You can adjust the offset conditionally based on this argument.
   * @param posY This is the X position at which the marker wants to be drawn.
   *             You can adjust the offset conditionally based on this argument.
   */
  MPPointF getOffsetForDrawingAtPoint(double posX, double posY);

  /**
   * This method enables a specified custom IMarker to update it's content every time the IMarker is redrawn.
   *
   * @param e         The Entry the IMarker belongs to. This can also be any subclass of Entry, like BarEntry or
   *                  CandleEntry, simply cast it at runtime.
   * @param highlight The highlight object contains information about the highlighted value such as it's dataset-index, the
   *                  selected range or stack-index (only stacked bar entries).
   */
  void refreshContent(Entry e, Highlight highlight);

  /**
   * Draws the IMarker on the given position on the screen with the given Canvas object.
   *
   * @param canvas
   * @param posX
   * @param posY
   */
  void draw(Canvas canvas, double posX, double posY);
}

mixin IBarLineScatterCandleBubbleDataSet<T extends Entry> on IDataSet<T> {
  /**
   * Returns the color that is used for drawing the highlight indicators.
   *
   * @return
   */
  Color getHighLightColor();
}

mixin ILineScatterCandleRadarDataSet<T extends Entry>
    on IBarLineScatterCandleBubbleDataSet<T> {
  /**
   * Returns true if vertical highlight indicator lines are enabled (drawn)
   * @return
   */
  bool isVerticalHighlightIndicatorEnabled();

  /**
   * Returns true if vertical highlight indicator lines are enabled (drawn)
   * @return
   */
  bool isHorizontalHighlightIndicatorEnabled();

  /**
   * Returns the line-width in which highlight lines are to be drawn.
   * @return
   */
  double getHighlightLineWidth();

/**
 * Returns the DashPathEffect that is used for highlighting.
 * @return
 */
//  DashPathEffect getDashPathEffectHighlight();
}

mixin IScatterDataSet on ILineScatterCandleRadarDataSet<Entry> {
  /**
   * Returns the currently set scatter shape size
   *
   * @return
   */
  double getScatterShapeSize();

  /**
   * Returns radius of the hole in the shape
   *
   * @return
   */
  double getScatterShapeHoleRadius();

  /**
   * Returns the color for the hole in the shape
   *
   * @return
   */
  int getScatterShapeHoleColor();

  /**
   * Returns the IShapeRenderer responsible for rendering this DataSet.
   *
   * @return
   */
  IShapeRenderer getShapeRenderer();
}

mixin IBubbleDataSet on IBarLineScatterCandleBubbleDataSet<BubbleEntry> {
  /**
   * Sets the width of the circle that surrounds the bubble when highlighted,
   * in dp.
   *
   * @param width
   */
  void setHighlightCircleWidth(double width);

  double getMaxSize();

  bool isNormalizeSizeEnabled();

  /**
   * Returns the width of the highlight-circle that surrounds the bubble
   * @return
   */
  double getHighlightCircleWidth();
}

mixin ILineRadarDataSet<T extends Entry> on ILineScatterCandleRadarDataSet<T> {
  /**
   * Returns the color that is used for filling the line surface area.
   *
   * @return
   */
  Color getFillColor();

  /**
   * Returns the drawable used for filling the area below the line.
   *
   * @return
   */
//  Drawable getFillDrawable();

  /**
   * Returns the alpha value that is used for filling the line surface,
   * default: 85
   *
   * @return
   */
  int getFillAlpha();

  /**
   * Returns the stroke-width of the drawn line
   *
   * @return
   */
  double getLineWidth();

  /**
   * Returns true if filled drawing is enabled, false if not
   *
   * @return
   */
  bool isDrawFilledEnabled();

  /**
   * Set to true if the DataSet should be drawn filled (surface), and not just
   * as a line, disabling this will give great performance boost. Please note that this method
   * uses the canvas.clipPath(...) method for drawing the filled area.
   * For devices with API level < 18 (Android 4.3), hardware acceleration of the chart should
   * be turned off. Default: false
   *
   * @param enabled
   */
  void setDrawFilled(bool enabled);
}

mixin ILineDataSet on ILineRadarDataSet<Entry> {
  /**
   * Returns the drawing mode for this line dataset
   *
   * @return
   */
  Mode getMode();

  /**
   * Returns the intensity of the cubic lines (the effect intensity).
   * Max = 1f = very cubic, Min = 0.05f = low cubic effect, Default: 0.2f
   *
   * @return
   */
  double getCubicIntensity();

  bool isDrawCubicEnabled();

  bool isDrawSteppedEnabled();

  /**
   * Returns the size of the drawn circles.
   */
  double getCircleRadius();

  /**
   * Returns the hole radius of the drawn circles.
   */
  double getCircleHoleRadius();

  /**
   * Returns the color at the given index of the DataSet's circle-color array.
   * Performs a IndexOutOfBounds check by modulus.
   *
   * @param index
   * @return
   */
  Color getCircleColor(int index);

  /**
   * Returns the number of colors in this DataSet's circle-color array.
   *
   * @return
   */
  int getCircleColorCount();

  /**
   * Returns true if drawing circles for this DataSet is enabled, false if not
   *
   * @return
   */
  bool isDrawCirclesEnabled();

  /**
   * Returns the color of the inner circle (the circle-hole).
   *
   * @return
   */
  Color getCircleHoleColor();

  /**
   * Returns true if drawing the circle-holes is enabled, false if not.
   *
   * @return
   */
  bool isDrawCircleHoleEnabled();

  /**
   * Returns the DashPathEffect that is used for drawing the lines.
   *
   * @return
   */
//  DashPathEffect getDashPathEffect();

  /**
   * Returns true if the dashed-line effect is enabled, false if not.
   * If the DashPathEffect object is null, also return false here.
   *
   * @return
   */
  bool isDashedLineEnabled();

  /**
   * Returns the IFillFormatter that is set for this DataSet.
   *
   * @return
   */
  IFillFormatter getFillFormatter();
}

mixin ICandleDataSet on ILineScatterCandleRadarDataSet<CandleEntry>{
  /**
   * Returns the space that is left out on the left and right side of each
   * candle.
   *
   * @return
   */
  double getBarSpace();

  /**
   * Returns whether the candle bars should show?
   * When false, only "ticks" will show
   *
   * - default: true
   *
   * @return
   */
  bool getShowCandleBar();

  /**
   * Returns the width of the candle-shadow-line in pixels.
   *
   * @return
   */
  double getShadowWidth();

  /**
   * Returns shadow color for all entries
   *
   * @return
   */
  int getShadowColor();

  /**
   * Returns the neutral color (for open == close)
   *
   * @return
   */
  int getNeutralColor();

  /**
   * Returns the increasing color (for open < close).
   *
   * @return
   */
  int getIncreasingColor();

  /**
   * Returns the decreasing color (for open > close).
   *
   * @return
   */
  int getDecreasingColor();

  /**
   * Returns paint style when open < close
   *
   * @return
   */
  TextStyle getIncreasingPaintStyle();

  /**
   * Returns paint style when open > close
   *
   * @return
   */
  TextStyle getDecreasingPaintStyle();

  /**
   * Is the shadow color same as the candle color?
   *
   * @return
   */
  bool getShadowColorSameAsCandle();
}

mixin BarLineScatterCandleBubbleDataProvider on ChartInterface {
  Transformer getTransformer(AxisDependency axis);

  bool isInverted(AxisDependency axis);

  double getLowestVisibleX();

  double getHighestVisibleX();

  BarLineScatterCandleBubbleData getData();
}

mixin LineDataProvider on BarLineScatterCandleBubbleDataProvider {
  LineData getLineData();
  YAxis getAxis(AxisDependency dependency);
}

mixin IShapeRenderer {
  /**
   * Renders the provided ScatterDataSet with a shape.
   *
   * @param c               Canvas object for drawing the shape
   * @param dataSet         The DataSet to be drawn
   * @param viewPortHandler Contains information about the current state of the view
   * @param posX            Position to draw the shape at
   * @param posY            Position to draw the shape at
   * @param renderPaint     Paint object used for styling and drawing
   */
  void renderShape(
      Canvas c,
      IScatterDataSet dataSet,
      ViewPortHandler viewPortHandler,
      double posX,
      double posY,
      Paint renderPaint);
}

mixin IFillFormatter {
  double getFillLinePosition(
      ILineDataSet dataSet, LineDataProvider dataProvider);
}

abstract class OnDrawListener{
  /**
   * Called whenever an entry is added with the finger. Note this is also called for entries that are generated by the
   * library, when the touch gesture is too fast and skips points.
   *
   * @param entry
   *            the last drawn entry
   */
  void onEntryAdded(Entry entry);

  /**
   * Called whenever an entry is moved by the user after beeing highlighted
   *
   * @param entry
   */
  void onEntryMoved(Entry entry);

  /**
   * Called when drawing finger is lifted and the draw is finished.
   *
   * @param dataSet
   *            the last drawn DataSet
   */
  void onDrawFinished(DataSet<Entry> dataSet);
}
