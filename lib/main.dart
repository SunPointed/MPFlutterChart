import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mp_flutter_chart/chart/chart_enums.dart';

import 'chart/chart.dart';

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
    _xBarVals.clear();
    _yBarVals.clear();

    _xLineVals.clear();
    _yLineVals.clear();

    List<String> xData = List();
    List<String> xBData = List();
    for (int i = 1; i <= 50; i++) {
      var d = (i - 1).toString();
      xData.add(d);
      if(i < 8){
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
      if(i < 8){
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

    super.initState();
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
                    child: BarChart.values(_xBarVals, _yBarVals, _legendNames),
                  ),
                ),
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: double.infinity, maxHeight: 300),
                    child: LineChart.values(_xLineVals, _yLineVals, _legendNames),
                  ),
                ),
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: double.infinity, maxHeight: 300),
                    child: LineChart.values(_xLineBVals, _yLineBVals, List<String>()..add("haha"), LineMode.CUBIC_BEZIER),
                  ),
                ),
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: double.infinity, maxHeight: 300),
                    child: LineChart.values(_xLineVals, _yLineVals, _legendNames, LineMode.CUBIC_BEZIER),
                  ),
                ),
                Center(
                    child: ConstrainedBox(
                  constraints:
                      BoxConstraints(maxWidth: double.infinity, maxHeight: 300),
                  child: PieChart.values(_xPieVals, _yPieVals),
                )),
                Center(
                    child: ConstrainedBox(
                  constraints:
                      BoxConstraints(maxWidth: double.infinity, maxHeight: 300),
                  child: LineChart.values(_xLineVals, _yLineVals, _legendNames),
                )),
              ],
            ),
          ),
        )
      ])// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
