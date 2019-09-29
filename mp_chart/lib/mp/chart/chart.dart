import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:mp_chart/mp/core/animator.dart';
import 'package:mp_chart/mp/core/axis/x_axis.dart';
import 'package:mp_chart/mp/core/common_interfaces.dart';
import 'package:mp_chart/mp/core/data/chart_data.dart';
import 'package:mp_chart/mp/core/description.dart';
import 'package:mp_chart/mp/core/functions.dart';
import 'package:mp_chart/mp/core/legend/legend.dart';
import 'package:mp_chart/mp/core/marker/i_marker.dart';
import 'package:mp_chart/mp/core/render/legend_renderer.dart';
import 'package:mp_chart/mp/core/utils/color_utils.dart';
import 'package:mp_chart/mp/core/utils/painter_utils.dart';
import 'package:mp_chart/mp/core/utils/utils.dart';
import 'package:mp_chart/mp/core/view_port.dart';
import 'package:mp_chart/mp/painter/painter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

abstract class Chart<P extends ChartPainter> extends StatefulWidget
    implements AnimatorUpdateListener {
  ////// needed
  ChartData data;
  IMarker marker;
  Description description;
  ViewPortHandler viewPortHandler;
  XAxis xAxis;
  Legend legend;
  LegendRenderer legendRenderer;
  OnChartValueSelectedListener selectionListener;

  ////// option
  double maxHighlightDistance;
  bool highLightPerTapEnabled;
  double extraTopOffset, extraRightOffset, extraBottomOffset, extraLeftOffset;
  bool drawMarkers;

  ////// split child property
  TextPainter descPaint;
  TextPainter infoPaint;

  ChartState _state;
  XAxisSettingFunction _xAxisSettingFunction;
  LegendSettingFunction _legendSettingFunction;
  DataRendererSettingFunction rendererSettingFunction;

  P _painter;
  ChartAnimator animator;

  ChartState getState() {
    return _state;
  }

  ChartState createChartState();

  @override
  State createState() {
    _state = createChartState();
    return _state;
  }

  Chart(ChartData data,
      {IMarker marker,
      Description description,
      XAxisSettingFunction xAxisSettingFunction,
      LegendSettingFunction legendSettingFunction,
      DataRendererSettingFunction rendererSettingFunction,
      OnChartValueSelectedListener selectionListener,
      double maxHighlightDistance = 100.0,
      bool highLightPerTapEnabled = true,
      double extraTopOffset = 0.0,
      double extraRightOffset = 0.0,
      double extraBottomOffset = 0.0,
      double extraLeftOffset = 0.0,
      String noDataText = "No chart data available.",
      bool drawMarkers = true,
      double descTextSize = 12,
      double infoTextSize = 12,
      Color descTextColor,
      Color infoTextColor})
      : data = data,
        maxHighlightDistance = maxHighlightDistance,
        highLightPerTapEnabled = highLightPerTapEnabled,
        extraLeftOffset = extraLeftOffset,
        extraTopOffset = extraTopOffset,
        extraRightOffset = extraRightOffset,
        extraBottomOffset = extraBottomOffset,
        drawMarkers = drawMarkers,
        marker = marker,
        description = description,
        _xAxisSettingFunction = xAxisSettingFunction,
        _legendSettingFunction = legendSettingFunction,
        rendererSettingFunction = rendererSettingFunction,
        selectionListener = selectionListener {
    if (descTextColor == null) {
      descTextColor = ColorUtils.BLACK;
    }
    descPaint = PainterUtils.create(null, null, descTextColor, descTextSize,
        fontFamily: description?.typeface?.fontFamily,
        fontWeight: description?.typeface?.fontWeight);
    if (infoTextColor == null) {
      infoTextColor = ColorUtils.BLACK;
    }
    infoPaint =
        PainterUtils.create(null, noDataText, infoTextColor, infoTextSize);

    if (maxHighlightDistance == 0.0) {
      maxHighlightDistance = Utils.convertDpToPixel(500);
    }

    this.viewPortHandler ??= initViewPortHandler();
    this.marker ??= initMarker();
    this.description ??= initDescription();
    this.selectionListener ??= initSelectionListener();

    this.animator = ChartAnimator(this);

    doneBeforePainterInit();
    initialPainter();
  }

  @override
  void onAnimationUpdate(double x, double y) {
    _state?.setStateIfNotDispose();
  }

  @override
  void onRotateUpdate(double angle) {}

  IMarker initMarker() => null;

  Description initDescription() => Description();

  ViewPortHandler initViewPortHandler() => ViewPortHandler();

  XAxis initXAxis() => XAxis();

  Legend initLegend() => Legend();

  LegendRenderer initLegendRenderer() =>
      LegendRenderer(viewPortHandler, legend);

  OnChartValueSelectedListener initSelectionListener() => null;

  ChartPainter get painter => _painter;

  set painter(P value) {
    _painter = value;
  }

  void doneBeforePainterInit() {
    this.legend = initLegend();
    this.legendRenderer = initLegendRenderer();
    xAxis = initXAxis();
    if (_legendSettingFunction != null) {
      _legendSettingFunction(legend, this);
    }
    if (_xAxisSettingFunction != null) {
      _xAxisSettingFunction(xAxis, this);
    }
  }

  void initialPainter();
}

abstract class ChartState<T extends Chart> extends State<T> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool isCapturing = false;
  bool _singleTap = false;

  void setStateIfNotDispose() {
    if (mounted) {
      setState(() {});
    }
  }

  void updatePainter();

  void capture() async {
    if (isCapturing) return;
    isCapturing = true;
    String directory = "";
    if (Platform.isAndroid) {
      directory = (await getExternalStorageDirectory()).path;
    } else if (Platform.isIOS) {
      directory = (await getApplicationDocumentsDirectory()).path;
    } else {
      return;
    }

    String fileName = DateTime.now().toIso8601String();
    String path = '$directory/$fileName.png';
    _screenshotController.capture(path: path, pixelRatio: 3.0).then((imgFile) {
      ImageGallerySaver.saveImage(Uint8List.fromList(imgFile.readAsBytesSync()))
          .then((value) {
        imgFile.delete();
      });
      isCapturing = false;
    }).catchError((error) {
      isCapturing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    widget.doneBeforePainterInit();
    widget.initialPainter();
    updatePainter();
    return Screenshot(
        controller: _screenshotController,
        child: Container(
            decoration: BoxDecoration(color: ColorUtils.WHITE),
            child: Stack(
                // Center is a layout widget. It takes a single child and positions it
                // in the middle of the parent.
                children: [
                  ConstrainedBox(
                      constraints: BoxConstraints(
                          minHeight: double.infinity,
                          minWidth: double.infinity),
                      child: GestureDetector(
                          onTapDown: (detail) {
                            _singleTap = true;
                            onTapDown(detail);
                          },
                          onTapUp: (detail) {
                            if (_singleTap) {
                              _singleTap = false;
                              onSingleTapUp(detail);
                            }
                          },
                          onDoubleTap: () {
                            _singleTap = false;
                            onDoubleTap();
                          },
                          onScaleStart: (detail) {
                            onScaleStart(detail);
                          },
                          onScaleUpdate: (detail) {
                            _singleTap = false;
                            onScaleUpdate(detail);
                          },
                          onScaleEnd: (detail) {
                            onScaleEnd(detail);
                          },
                          child: CustomPaint(painter: widget.painter))),
                ])));
  }

  @override
  void reassemble() {
    super.reassemble();
    widget.animator?.reset();
    widget.painter?.reassemble();
  }

  void onDoubleTap();

  void onScaleStart(ScaleStartDetails detail);

  void onScaleUpdate(ScaleUpdateDetails detail);

  void onScaleEnd(ScaleEndDetails detail);

  void onTapDown(TapDownDetails detail);

  void onSingleTapUp(TapUpDetails detail);
}
