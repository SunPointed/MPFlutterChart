import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/core/animator.dart';
import 'package:mp_flutter_chart/chart/mp/core/data.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/core/legend.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/painter/painter.dart';
import 'package:mp_flutter_chart/chart/mp/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/util.dart';

abstract class PieRadarChartPainter<T extends ChartData<IDataSet<Entry>>>
    extends ChartPainter<T> {
  /**
   * holds the normalized version of the current rotation angle of the chart
   */
  double mRotationAngle = 270;

  /**
   * holds the raw version of the current rotation angle of the chart
   */
  double mRawRotationAngle = 270;

  /**
   * flag that indicates if rotation is enabled or not
   */
  bool mRotateEnabled = true;

  /**
   * Sets the minimum offset (padding) around the chart, defaults to 0.f
   */
  double mMinOffset = 0.0;

  PieRadarChartPainter(T data,
      {double rotationAngle = 270,
      double rawRotationAngle = 270,
      bool rotateEnabled = true,
      double minOffset = 0.0,
      ViewPortHandler viewPortHandler = null,
      ChartAnimator animator = null,
      double maxHighlightDistance = 0.0,
      bool highLightPerTapEnabled = true,
      bool dragDecelerationEnabled = true,
      double dragDecelerationFrictionCoef = 0.9,
      double extraLeftOffset = 0.0,
      double extraTopOffset = 0.0,
      double extraRightOffset = 0.0,
      double extraBottomOffset = 0.0,
      String noDataText = "No chart data available.",
      bool touchEnabled = true,
      IMarker marker = null,
      Description desc = null,
      bool drawMarkers = true,
      TextPainter infoPainter = null,
      TextPainter descPainter = null,
      IHighlighter highlighter = null,
      bool unbind = false})
      : mRotationAngle = rotationAngle,
        mRawRotationAngle = rawRotationAngle,
        mRotateEnabled = rotateEnabled,
        mMinOffset = minOffset,
        super(data,
            viewPortHandler: viewPortHandler,
            animator: animator,
            maxHighlightDistance: maxHighlightDistance,
            highLightPerTapEnabled: highLightPerTapEnabled,
            dragDecelerationEnabled: dragDecelerationEnabled,
            dragDecelerationFrictionCoef: dragDecelerationFrictionCoef,
            extraLeftOffset: extraLeftOffset,
            extraTopOffset: extraTopOffset,
            extraRightOffset: extraRightOffset,
            extraBottomOffset: extraBottomOffset,
            noDataText: noDataText,
            touchEnabled: touchEnabled,
            marker: marker,
            desc: desc,
            drawMarkers: drawMarkers,
            infoPainter: infoPainter,
            descPainter: descPainter,
            highlighter: highlighter,
            unbind: unbind);

//  @override todo
//   void init() {
//    super.init();
//
//    mChartTouchListener = new PieRadarChartTouchListener(this);
//  }

  @override
  void calcMinMax() {
    //mXAxis.mAxisRange = mData.getXVals().size() - 1;
  }

  @override
  int getMaxVisibleCount() {
    return mData.getEntryCount();
  }

//  @override todo
//   boolean onTouchEvent(MotionEvent event) {
//    // use the pie- and radarchart listener own listener
//    if (mTouchEnabled && mChartTouchListener != null)
//      return mChartTouchListener.onTouch(this, event);
//    else
//      return super.onTouchEvent(event);
//  }

//  @override todo
//   void computeScroll() {
//
//    if (mChartTouchListener instanceof PieRadarChartTouchListener)
//      ((PieRadarChartTouchListener) mChartTouchListener).computeScroll();
//  }

//  @Override todo
//   void notifyDataSetChanged() {
//    if (mData == null)
//      return;
//
//    calcMinMax();
//
//    if (mLegend != null)
//      mLegendRenderer.computeLegend(mData);
//
//    calculateOffsets();
//  }

  @override
  void calculateOffsets() {
    if (mLegend != null) mLegendRenderer.computeLegend(mData);
    mRenderer?.initBuffers();
    calcMinMax();

      double legendLeft = 0, legendRight = 0, legendBottom = 0, legendTop = 0;

    if (mLegend != null &&
        mLegend.isEnabled() &&
        !mLegend.isDrawInsideEnabled()) {
      double fullLegendWidth = min(mLegend.mNeededWidth,
          mViewPortHandler.getChartWidth() * mLegend.getMaxSizePercent());

      switch (mLegend.getOrientation()) {
        case LegendOrientation.VERTICAL:
          {
            double xLegendOffset = 0.0;

            if (mLegend.getHorizontalAlignment() ==
                    LegendHorizontalAlignment.LEFT ||
                mLegend.getHorizontalAlignment() ==
                    LegendHorizontalAlignment.RIGHT) {
              if (mLegend.getVerticalAlignment() ==
                  LegendVerticalAlignment.CENTER) {
                // this is the space between the legend and the chart
                final double spacing = Utils.convertDpToPixel(13);

                xLegendOffset = fullLegendWidth + spacing;
              } else {
                // this is the space between the legend and the chart
                double spacing = Utils.convertDpToPixel(8);

                double legendWidth = fullLegendWidth + spacing;
                double legendHeight =
                    mLegend.mNeededHeight + mLegend.mTextHeightMax;

                MPPointF center = getCenter(mSize);

                double bottomX = mLegend.getHorizontalAlignment() ==
                        LegendHorizontalAlignment.RIGHT
                    ? mSize.width - legendWidth + 15.0
                    : legendWidth - 15.0;
                double bottomY = legendHeight + 15.0;
                double distLegend = distanceToCenter(bottomX, bottomY);

                MPPointF reference = getPosition1(
                    center, getRadius(), getAngleForPoint(bottomX, bottomY));

                double distReference =
                    distanceToCenter(reference.x, reference.y);
                double minOffset = Utils.convertDpToPixel(5);

                if (bottomY >= center.y &&
                    mSize.height - legendWidth > mSize.width) {
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

            switch (mLegend.getHorizontalAlignment()) {
              case LegendHorizontalAlignment.LEFT:
                legendLeft = xLegendOffset;
                break;

              case LegendHorizontalAlignment.RIGHT:
                legendRight = xLegendOffset;
                break;

              case LegendHorizontalAlignment.CENTER:
                switch (mLegend.getVerticalAlignment()) {
                  case LegendVerticalAlignment.TOP:
                    legendTop = min(
                        mLegend.mNeededHeight,
                        mViewPortHandler.getChartHeight() *
                            mLegend.getMaxSizePercent());
                    break;
                  case LegendVerticalAlignment.BOTTOM:
                    legendBottom = min(
                        mLegend.mNeededHeight,
                        mViewPortHandler.getChartHeight() *
                            mLegend.getMaxSizePercent());
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

          if (mLegend.getVerticalAlignment() == LegendVerticalAlignment.TOP ||
              mLegend.getVerticalAlignment() ==
                  LegendVerticalAlignment.BOTTOM) {
            // It's possible that we do not need this offset anymore as it
            //   is available through the extraOffsets, but changing it can mean
            //   changing default visibility for existing apps.
            double yOffset = getRequiredLegendOffset();

            yLegendOffset = min(
                mLegend.mNeededHeight + yOffset,
                mViewPortHandler.getChartHeight() *
                    mLegend.getMaxSizePercent());

            switch (mLegend.getVerticalAlignment()) {
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

    double minOffset = Utils.convertDpToPixel(mMinOffset);

//    if (this is RadarChartPainter) { todo
//      XAxis x = this.mXAxis;
//
//      if (x.isEnabled() && x.isDrawLabelsEnabled()) {
//        minOffset = max(minOffset, x.mLabelRotatedWidth.toDouble());
//      }
//    }

    legendTop += mExtraTopOffset;
    legendRight += mExtraRightOffset;
    legendBottom += mExtraBottomOffset;
    legendLeft += mExtraLeftOffset;

    double offsetLeft = max(minOffset, legendLeft);
    double offsetTop = max(minOffset, legendTop);
    double offsetRight = max(minOffset, legendRight);
    double offsetBottom =
        max(minOffset, max(getRequiredBaseOffset(), legendBottom));

    mViewPortHandler.restrainViewPort(
        offsetLeft, offsetTop, offsetRight, offsetBottom);
  }

  /**
   * returns the angle relative to the chart center for the given point on the
   * chart in degrees. The angle is always between 0 and 360°, 0° is NORTH,
   * 90° is EAST, ...
   *
   * @param x
   * @param y
   * @return
   */
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

  /**
   * Returns a recyclable MPPointF instance.
   * Calculates the position around a center point, depending on the distance
   * from the center, and the angle of the position around the center.
   *
   * @param center
   * @param dist
   * @param angle  in degrees, converted to radians internally
   * @return
   */
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

  /**
   * Returns the distance of a certain point on the chart to the center of the
   * chart.
   *
   * @param x
   * @param y
   * @return
   */
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

  /**
   * Returns the xIndex for the given angle around the center of the chart.
   * Returns -1 if not found / outofbounds.
   *
   * @param angle
   * @return
   */
  int getIndexForAngle(double angle);

  /**
   * Set an offset for the rotation of the RadarChart in degrees. Default 270f
   * --> top (NORTH)
   *
   * @param angle
   */
  void setRotationAngle(double angle) {
    mRawRotationAngle = angle;
    mRotationAngle = Utils.getNormalizedAngle(mRawRotationAngle);
  }

  /**
   * gets the raw version of the current rotation angle of the pie chart the
   * returned value could be any value, negative or positive, outside of the
   * 360 degrees. this is used when working with rotation direction, mainly by
   * gestures and animations.
   *
   * @return
   */
  double getRawRotationAngle() {
    return mRawRotationAngle;
  }

  /**
   * gets a normalized version of the current rotation angle of the pie chart,
   * which will always be between 0.0 < 360.0
   *
   * @return
   */
  double getRotationAngle() {
    return mRotationAngle;
  }

  /**
   * Set this to true to enable the rotation / spinning of the chart by touch.
   * Set it to false to disable it. Default: true
   *
   * @param enabled
   */
  void setRotationEnabled(bool enabled) {
    mRotateEnabled = enabled;
  }

  /**
   * Returns true if rotation of the chart by touch is enabled, false if not.
   *
   * @return
   */
  bool isRotationEnabled() {
    return mRotateEnabled;
  }

  /**
   * Gets the minimum offset (padding) around the chart, defaults to 0.f
   */
  double getMinOffset() {
    return mMinOffset;
  }

  /**
   * Sets the minimum offset (padding) around the chart, defaults to 0.f
   */
  void setMinOffset(double minOffset) {
    mMinOffset = minOffset;
  }

  /**
   * returns the diameter of the pie- or radar-chart
   *
   * @return
   */
  double getDiameter() {
    Rect content = Rect.fromLTRB(
        mViewPortHandler.getContentRect().left + mExtraLeftOffset,
        mViewPortHandler.getContentRect().top + mExtraTopOffset,
        mViewPortHandler.getContentRect().right - mExtraRightOffset,
        mViewPortHandler.getContentRect().bottom - mExtraBottomOffset);
    return min(content.width, content.height);
  }

  /**
   * Returns the radius of the chart in pixels.
   *
   * @return
   */
  double getRadius();

  /**
   * Returns the required offset for the chart legend.
   *
   * @return
   */
  double getRequiredLegendOffset();

  /**
   * Returns the base offset needed for the chart without calculating the
   * legend size.
   *
   * @return
   */
  double getRequiredBaseOffset();

  @override
  double getYChartMax() {
    return 0;
  }

  @override
  double getYChartMin() {
    return 0;
  }

  /**
   * ################ ################ ################ ################
   */
  /** CODE BELOW THIS RELATED TO ANIMATION */

  /**
   * Applys a spin animation to the Chart.
   *
   * @param durationmillis
   * @param fromangle
   * @param toangle
   */
  void spin(int durationmillis, double fromangle, double toangle,
      EasingFunction easing) {
//  todo
//    setRotationAngle(fromangle);
//
//    ObjectAnimator spinAnimator = ObjectAnimator.ofFloat(this, "rotationAngle", fromangle,
//        toangle);
//    spinAnimator.setDuration(durationmillis);
//    spinAnimator.setInterpolator(easing);
//
//    spinAnimator.addUpdateListener(new AnimatorUpdateListener() {
//
//    @Override
//    public void onAnimationUpdate(ValueAnimator animation) {
//    postInvalidate();
//    }
//    });
//    spinAnimator.start();
  }
}
