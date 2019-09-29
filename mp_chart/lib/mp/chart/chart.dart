import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:mp_chart/mp/controller/controller.dart';
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

abstract class Chart<P extends ChartPainter, C extends Controller>
    extends StatefulWidget implements AnimatorUpdateListener {
  final C controller;

  P _painter;
  ChartAnimator _animator;
  ChartState _state;

  ChartAnimator get animator => _animator;

  ChartState get state => _state;

  ChartState createChartState();

  @override
  State createState() {
    _state = createChartState();
    return _state;
  }

  Chart(this.controller) {
    controller.attachChart(this);
    _animator = ChartAnimator(this);
    doneBeforePainterInit();
    initialPainter();
  }

  @override
  void onAnimationUpdate(double x, double y) {
    _state?.setStateIfNotDispose();
  }

  @override
  void onRotateUpdate(double angle) {}

  ChartPainter get painter => _painter;

  set painter(P value) {
    _painter = value;
  }

  void doneBeforePainterInit() {
    controller.legend = controller.initLegend();
    controller.legendRenderer = controller.initLegendRenderer();
    controller.xAxis = controller.initXAxis();
    if (controller.legendSettingFunction != null) {
      controller.legendSettingFunction(controller.legend, this);
    }
    if (controller.xAxisSettingFunction != null) {
      controller.xAxisSettingFunction(controller.xAxis, this);
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
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget._animator = oldWidget._animator;
    widget._state = this;
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
    widget._animator?.reset();
    widget.painter?.reassemble();
  }

  void onDoubleTap();

  void onScaleStart(ScaleStartDetails detail);

  void onScaleUpdate(ScaleUpdateDetails detail);

  void onScaleEnd(ScaleEndDetails detail);

  void onTapDown(TapDownDetails detail);

  void onSingleTapUp(TapUpDetails detail);
}
