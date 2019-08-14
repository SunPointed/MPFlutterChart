import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mp_flutter_chart/chart/old/chart_enums.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/data.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/core/legend.dart';
import 'package:mp_flutter_chart/chart/mp/core/limit.dart';
import 'package:mp_flutter_chart/chart/mp/mode.dart';
import 'package:mp_flutter_chart/chart/mp/util.dart';

import 'package:mp_flutter_chart/chart/old/chart.dart' as old;
import 'package:mp_flutter_chart/chart/mp/chart/line_chart.dart';
import 'package:mp_flutter_chart/chart/mp/painter/line_chart_painter.dart';
import 'package:mp_flutter_chart/chart/mp/painter/painter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  LineChart _lineChart;
  LineData _lineData;

  var random = Random(1);
  List<List<String>> _xBarVals = List();
  List<List<double>> _yBarVals = List();

  List<List<String>> _xLineVals = List();
  List<List<double>> _yLineVals = List();
  List<List<String>> _xLineBVals = List();
  List<List<double>> _yLineBVals = List();
  List<String> _legendNames = List();

  List<String> _xPieVals = List();
  List<double> _yPieVals = List();

  @override
  void initState() {
    _initData();
    _initLineChart();
    super.initState();
  }

  void _initData() {
    _xBarVals.clear();
    _yBarVals.clear();

    _xLineVals.clear();
    _yLineVals.clear();

    List<String> xData = List();
    List<String> xBData = List();
    for (int i = 1; i <= 50; i++) {
      var d = (i - 1).toString();
      xData.add(d);
      if (i < 8) {
        _xPieVals.add(d);
        xBData.add(d);
      }
    }
    _xBarVals.add(xData);
    _xLineVals.add(xData);
    _xLineBVals.add(xBData);

    List<double> yData = List();
    List<double> yData1 = List();
    List<double> yData2 = List();
    List<double> yBData = List();
    for (int i = 1; i <= 50; i++) {
      var data = random.nextDouble() * 100;
      var d = random.nextDouble() > 0.5 ? data : -data;
      yData.add(d);
      yData1.add(d + 10);
      yData2.add(random.nextDouble() * 20);
      if (i < 8) {
        _yPieVals.add(data);
        yBData.add(d);
      }
    }
    _yBarVals.add(yData);
    _yBarVals.add(yData1);
    _yBarVals.add(yData2);
    _yLineVals.add(yData);
    _yLineVals.add(yData1);
    _yLineVals.add(yData2);
    _yLineBVals.add(yBData);

    _legendNames.add("1");
    _legendNames.add("two");
    _legendNames.add("three");

    setLineData(45, 180);
  }

  void _initLineChart() {
    var desc = Description();
    desc.setEnabled(false);
    var lineState = LineChartState((painter) {
      painter.mXAxis.enableGridDashedLine(10, 10, 0);

      painter.mAxisRight.setEnabled(false);
//    _lineChart.painter.mAxisRight.enableGridDashedLine(10, 10, 0);
//    _lineChart.painter.mAxisRight.setAxisMaximum(200);
//    _lineChart.painter.mAxisRight.setAxisMinimum(-50);

      painter.mAxisLeft.enableGridDashedLine(10, 10, 0);
      painter.mAxisLeft.setAxisMaximum(200);
      painter.mAxisLeft.setAxisMinimum(-50);

      LimitLine llXAxis = new LimitLine(9, "Index 10");
      llXAxis.setLineWidth(4);
      llXAxis.enableDashedLine(10, 10, 0);
      llXAxis.setLabelPosition(LimitLabelPosition.RIGHT_BOTTOM);
      llXAxis.setTextSize(10);

      LimitLine ll1 = new LimitLine(150, "Upper Limit");
      ll1.setLineWidth(4);
      ll1.enableDashedLine(10, 10, 0);
      ll1.setLabelPosition(LimitLabelPosition.RIGHT_TOP);
      ll1.setTextSize(10);

      LimitLine ll2 = new LimitLine(-30, "Lower Limit");
      ll2.setLineWidth(4);
      ll2.enableDashedLine(10, 10, 0);
      ll2.setLabelPosition(LimitLabelPosition.RIGHT_BOTTOM);
      ll2.setTextSize(10);

      // draw limit lines behind data instead of on top
      painter.mAxisLeft.setDrawLimitLinesBehindData(true);
      painter.mXAxis.setDrawLimitLinesBehindData(true);

      // add limit lines
      painter.mAxisLeft.addLimitLine(ll1);
      painter.mAxisLeft.addLimitLine(ll2);
      painter.mLegend.setForm(LegendForm.LINE);
    }, _lineData,
        touchEnabled: true,
        drawGridBackground: false,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: true,
        scaleYEnabled: true,
        pinchZoomEnabled: true,
        desc: desc);
    _lineChart = LineChart(lineState);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
//      body: Center(
//          child: ConstrainedBox(
//              constraints: BoxConstraints(
//                  maxWidth: double.infinity, maxHeight: double.infinity),
//              child: _lineChart)),

        body: CustomScrollView(shrinkWrap: false, slivers: [
          new SliverPadding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
            sliver: new SliverList(
              delegate: new SliverChildListDelegate(
                <Widget>[
                  Center(
                      child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: double.infinity, maxHeight: 300),
                    child: _lineChart,
                  )),
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: double.infinity, maxHeight: 300),
                      child: old.BarChart.values(
                          _xBarVals, _yBarVals, _legendNames),
                    ),
                  ),
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: double.infinity, maxHeight: 300),
                      child: old.LineChart.values(
                          _xLineVals, _yLineVals, _legendNames),
                    ),
                  ),
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: double.infinity, maxHeight: 300),
                      child: old.LineChart.values(_xLineBVals, _yLineBVals,
                          List<String>()..add("haha"), LineMode.CUBIC_BEZIER),
                    ),
                  ),
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: double.infinity, maxHeight: 300),
                      child: old.LineChart.values(_xLineVals, _yLineVals,
                          _legendNames, LineMode.CUBIC_BEZIER),
                    ),
                  ),
                  Center(
                      child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: double.infinity, maxHeight: 300),
                    child: old.PieChart.values(_xPieVals, _yPieVals),
                  )),
                  Center(
                      child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: double.infinity, maxHeight: 300),
                    child: old.LineChart.values(
                        _xLineVals, _yLineVals, _legendNames),
                  )),
                ],
              ),
            ),
          )
        ]) // This trailing comma makes auto-formatting nicer for build methods.

    );
  }

  void setLineData(int count, double range) {
    List<Entry> values = List();

    for (int i = 0; i < count; i++) {
      double val = (random.nextDouble() * range) - 30;
      values.add(Entry(x: i.toDouble(), y: val));
    }

    LineDataSet set1;

    // create a dataset and give it a type
    set1 = LineDataSet(values, "DataSet 1");

    set1.setDrawIcons(false);

    // draw dashed line
//      set1.enableDashedLine(10, 5, 0);

    // black lines and points
    set1.setColor1(ColorUtils.FADE_RED_END);
    set1.setCircleColor(ColorUtils.FADE_RED_END);
    set1.setHighLightColor(ColorUtils.PURPLE);

    // line thickness and point size
    set1.setLineWidth(1);
    set1.setCircleRadius(3);

    // draw points as solid circles
    set1.setDrawCircleHole(false);

    // customize legend entry
    set1.setFormLineWidth(1);
//      set1.setFormLineDashEffect(new DashPathEffect(new double[]{10f, 5f}, 0f));
    set1.setFormSize(15);

    // text size of values
    set1.setValueTextSize(9);

    // draw selection line as dashed
//      set1.enableDashedHighlightLine(10, 5, 0);

    // set the filled area
    set1.setDrawFilled(true);
//    set1.setFillFormatter(A(_lineChart.painter));

    // set color of filled area
    set1.setFillColor(ColorUtils.FADE_RED_END);

    set1.setDrawIcons(true);
    set1.setMode(Mode.CUBIC_BEZIER);
    List<ILineDataSet> dataSets = List();
    dataSets.add(set1); // add the data sets

    // create a data object with the data sets
    _lineData = LineData.fromList(dataSets);
    _lineData.setValueTypeface(TextStyle(fontSize: Utils.convertDpToPixel(9)));
  }
}

class A implements IFillFormatter {
  LineChartPainter painter;

  A(this.painter);

  @override
  double getFillLinePosition(
      ILineDataSet dataSet, LineDataProvider dataProvider) {
    return painter.mAxisLeft.getAxisMinimum();
  }
}
