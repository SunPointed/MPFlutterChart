import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/core/animator.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis/x_axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/common_interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/chart_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_horizontal_alignment.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_orientation.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_vertical_alignment.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/i_highlighter.dart';
import 'package:mp_flutter_chart/chart/mp/core/legend/legend.dart';
import 'package:mp_flutter_chart/chart/mp/core/marker/i_marker.dart';
import 'package:mp_flutter_chart/chart/mp/core/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/data_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/legend_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/painter/painter.dart';

import 'radar_chart_painter.dart';

abstract class PieRadarChartPainter<T extends ChartData<IDataSet<Entry>>>
    extends ChartPainter<T> {
  /// holds the normalized version of the current rotation angle of the chart
  final double _rotationAngle; //270

  /// holds the raw version of the current rotation angle of the chart
  final double _rawRotationAngle; //270

  /// flag that indicates if rotation is enabled or not
  final bool _rotateEnabled; //true

  /// Sets the minimum offset (padding) around the chart, defaults to 0.f
  final double _minOffset; //0.0

  PieRadarChartPainter(
      T data,
      ChartAnimator animator,
      ViewPortHandler viewPortHandler,
      double maxHighlightDistance,
      bool highLightPerTapEnabled,
      bool dragDecelerationEnabled,
      double dragDecelerationFrictionCoef,
      double extraLeftOffset,
      double extraTopOffset,
      double extraRightOffset,
      double extraBottomOffset,
      String noDataText,
      bool touchEnabled,
      IMarker marker,
      Description desc,
      bool drawMarkers,
      TextPainter infoPainter,
      TextPainter descPainter,
      IHighlighter highlighter,
      XAxis xAxis,
      Legend legend,
      LegendRenderer legendRenderer,
      DataRenderer renderer,
      OnChartValueSelectedListener selectedListener,
      double rotationAngle,
      double rawRotationAngle,
      bool rotateEnabled,
      double minOffset,)
      : _rotationAngle = rotationAngle,
        _rawRotationAngle = rawRotationAngle,
        _rotateEnabled = rotateEnabled,
        _minOffset = minOffset,
        super(
            data,
            animator,
            viewPortHandler,
            maxHighlightDistance,
            highLightPerTapEnabled,
            dragDecelerationEnabled,
            dragDecelerationFrictionCoef,
            extraLeftOffset,
            extraTopOffset,
            extraRightOffset,
            extraBottomOffset,
            noDataText,
            touchEnabled,
            marker,
            desc,
            drawMarkers,
            infoPainter,
            descPainter,
            highlighter,
            xAxis,
            legend,
            legendRenderer,
            renderer,
            selectedListener);

//  @override todo
//   void init() {
//    super.init();
//
//    mChartTouchListener = new PieRadarChartTouchListener(this);
//  }

  @override
  void calcMinMax() {
    //xAxis.mAxisRange = mData.getXVals().size() - 1;
  }

  @override
  int getMaxVisibleCount() {
    return getData().getEntryCount();
  }

  @override
  void calculateOffsets() {
    if (legend != null) legendRenderer.computeLegend(getData());
    renderer?.initBuffers();
    calcMinMax();

    double legendLeft = 0, legendRight = 0, legendBottom = 0, legendTop = 0;

    if (legend != null &&
        legend.isEnabled() &&
        !legend.isDrawInsideEnabled()) {
      double fullLegendWidth = min(legend.mNeededWidth,
          viewPortHandler.getChartWidth() * legend.getMaxSizePercent());

      switch (legend.getOrientation()) {
        case LegendOrientation.VERTICAL:
          {
            double xLegendOffset = 0.0;

            if (legend.getHorizontalAlignment() ==
                    LegendHorizontalAlignment.LEFT ||
                legend.getHorizontalAlignment() ==
                    LegendHorizontalAlignment.RIGHT) {
              if (legend.getVerticalAlignment() ==
                  LegendVerticalAlignment.CENTER) {
                // this is the space between the legend and the chart
                final double spacing = Utils.convertDpToPixel(13);

                xLegendOffset = fullLegendWidth + spacing;
              } else {
                // this is the space between the legend and the chart
                double spacing = Utils.convertDpToPixel(8);

                double legendWidth = fullLegendWidth + spacing;
                double legendHeight =
                    legend.mNeededHeight + legend.mTextHeightMax;

                var center = getCenter(size);

                double bottomX = legend.getHorizontalAlignment() ==
                        LegendHorizontalAlignment.RIGHT
                    ? size.width - legendWidth + 15.0
                    : legendWidth - 15.0;
                double bottomY = legendHeight + 15.0;
                double distLegend = distanceToCenter(bottomX, bottomY);

                MPPointF reference = getPosition1(
                    center, getRadius(), getAngleForPoint(bottomX, bottomY));

                double distReference =
                    distanceToCenter(reference.x, reference.y);
                double minOffset = Utils.convertDpToPixel(5);

                if (bottomY >= center.y &&
                    size.height - legendWidth > size.width) {
                  xLegendOffset = legendWidth;
                } else if (distLegend < distReference) {
                  double diff = distReference - distLegend;
                  xLegendOffset = minOffset + diff;
                } else {
                  xLegendOffset = legendWidth;
                }

                MPPointF.recycleInstance(center);
                MPPointF.recycleInstance(reference);
              }
            }

            switch (legend.getHorizontalAlignment()) {
              case LegendHorizontalAlignment.LEFT:
                legendLeft = xLegendOffset;
                break;

              case LegendHorizontalAlignment.RIGHT:
                legendRight = xLegendOffset;
                break;

              case LegendHorizontalAlignment.CENTER:
                switch (legend.getVerticalAlignment()) {
                  case LegendVerticalAlignment.TOP:
                    legendTop = min(
                        legend.mNeededHeight,
                        viewPortHandler.getChartHeight() *
                            legend.getMaxSizePercent());
                    break;
                  case LegendVerticalAlignment.BOTTOM:
                    legendBottom = min(
                        legend.mNeededHeight,
                        viewPortHandler.getChartHeight() *
                            legend.getMaxSizePercent());
                    break;
                  default:
                    break;
                }
                break;
            }
          }
          break;

        case LegendOrientation.HORIZONTAL:
          double yLegendOffset = 0.0;

          if (legend.getVerticalAlignment() == LegendVerticalAlignment.TOP ||
              legend.getVerticalAlignment() ==
                  LegendVerticalAlignment.BOTTOM) {
            // It's possible that we do not need this offset anymore as it
            //   is available through the extraOffsets, but changing it can mean
            //   changing default visibility for existing apps.
            double yOffset = getRequiredLegendOffset();

            yLegendOffset = min(
                legend.mNeededHeight + yOffset,
                viewPortHandler.getChartHeight() *
                    legend.getMaxSizePercent());

            switch (legend.getVerticalAlignment()) {
              case LegendVerticalAlignment.TOP:
                legendTop = yLegendOffset;
                break;
              case LegendVerticalAlignment.BOTTOM:
                legendBottom = yLegendOffset;
                break;
              default:
                break;
            }
          }
          break;
      }

      legendLeft += getRequiredBaseOffset();
      legendRight += getRequiredBaseOffset();
      legendTop += getRequiredBaseOffset();
      legendBottom += getRequiredBaseOffset();
    }

    double minOffset = Utils.convertDpToPixel(_minOffset);

    if (this is RadarChartPainter) {
      XAxis x = this.xAxis;

      if (x.isEnabled() && x.isDrawLabelsEnabled()) {
        minOffset = max(minOffset, x.mLabelRotatedWidth.toDouble());
      }
    }

    legendTop += extraTopOffset;
    legendRight += extraRightOffset;
    legendBottom += extraBottomOffset;
    legendLeft += extraLeftOffset;

    double offsetLeft = max(minOffset, legendLeft);
    double offsetTop = max(minOffset, legendTop);
    double offsetRight = max(minOffset, legendRight);
    double offsetBottom =
        max(minOffset, max(getRequiredBaseOffset(), legendBottom));

    viewPortHandler.restrainViewPort(
        offsetLeft, offsetTop, offsetRight, offsetBottom);
  }

  /// returns the angle relative to the chart center for the given point on the
  /// chart in degrees. The angle is always between 0 and 360°, 0° is NORTH,
  /// 90° is EAST, ...
  ///
  /// @param x
  /// @param y
  /// @return
  double getAngleForPoint(double x, double y) {
    MPPointF c = getCenterOffsets();

    double tx = x - c.x, ty = y - c.y;
    double length = sqrt(tx * tx + ty * ty);
    double r = acos(ty / length);

    double angle = r * 180.0 / pi;

    if (x > c.x) angle = 360 - angle;

    // add 90° because chart starts EAST
    angle = angle + 90;

    // neutralize overflow
    if (angle > 360) angle = angle - 360;

    MPPointF.recycleInstance(c);

    return angle;
  }

  /// Returns a recyclable MPPointF instance.
  /// Calculates the position around a center point, depending on the distance
  /// from the center, and the angle of the position around the center.
  ///
  /// @param center
  /// @param dist
  /// @param angle  in degrees, converted to radians internally
  /// @return
  MPPointF getPosition1(MPPointF center, double dist, double angle) {
    MPPointF p = MPPointF.getInstance1(0, 0);
    getPosition2(center, dist, angle, p);
    return p;
  }

  void getPosition2(
      MPPointF center, double dist, double angle, MPPointF outputPoint) {
    outputPoint.x = (center.x + dist * cos(angle / 180.0 * pi));
    outputPoint.y = (center.y + dist * sin(angle / 180.0 * pi));
  }

  /// Returns the distance of a certain point on the chart to the center of the
  /// chart.
  ///
  /// @param x
  /// @param y
  /// @return
  double distanceToCenter(double x, double y) {
    MPPointF c = getCenterOffsets();

    double dist = 0;

    double xDist = 0;
    double yDist = 0;

    if (x > c.x) {
      xDist = x - c.x;
    } else {
      xDist = c.x - x;
    }

    if (y > c.y) {
      yDist = y - c.y;
    } else {
      yDist = c.y - y;
    }

    // pythagoras
    dist = sqrt(pow(xDist, 2.0) + pow(yDist, 2.0));

    MPPointF.recycleInstance(c);

    return dist;
  }

  /// Returns the xIndex for the given angle around the center of the chart.
  /// Returns -1 if not found / outofbounds.
  ///
  /// @param angle
  /// @return
  int getIndexForAngle(double angle);

//  /// Set an offset for the rotation of the RadarChart in degrees. Default 270f
//  /// --> top (NORTH)
//  ///
//  /// @param angle
//  void setRotationAngle(double angle) {
//    _rawRotationAngle = angle;
//    _rotationAngle = Utils.getNormalizedAngle(_rawRotationAngle);
//  }

  /// gets the raw version of the current rotation angle of the pie chart the
  /// returned value could be any value, negative or positive, outside of the
  /// 360 degrees. this is used when working with rotation direction, mainly by
  /// gestures and animations.
  ///
  /// @return
  double getRawRotationAngle() {
    return _rawRotationAngle;
  }

  /// gets a normalized version of the current rotation angle of the pie chart,
  /// which will always be between 0.0 < 360.0
  ///
  /// @return
  double getRotationAngle() {
    return _rotationAngle;
  }

  /// Returns true if rotation of the chart by touch is enabled, false if not.
  ///
  /// @return
  bool isRotationEnabled() {
    return _rotateEnabled;
  }

  /// Gets the minimum offset (padding) around the chart, defaults to 0.f
  double getMinOffset() {
    return _minOffset;
  }

  /// returns the diameter of the pie- or radar-chart
  ///
  /// @return
  double getDiameter() {
    Rect content = Rect.fromLTRB(
        viewPortHandler.getContentRect().left + extraLeftOffset,
        viewPortHandler.getContentRect().top + extraTopOffset,
        viewPortHandler.getContentRect().right - extraRightOffset,
        viewPortHandler.getContentRect().bottom - extraBottomOffset);
    return min(content.width, content.height);
  }

  /// Returns the radius of the chart in pixels.
  ///
  /// @return
  double getRadius();

  /// Returns the required offset for the chart legend.
  ///
  /// @return
  double getRequiredLegendOffset();

  /// Returns the base offset needed for the chart without calculating the
  /// legend size.
  ///
  /// @return
  double getRequiredBaseOffset();

  @override
  double getYChartMax() {
    return 0;
  }

  @override
  double getYChartMin() {
    return 0;
  }
}
