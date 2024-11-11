import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math';

void main() {
  runApp(_ChartApp());
}

// Main application widget
class _ChartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const _WindmillChart(),
    );
  }
}

// Blog page with the chart
class _WindmillChart extends StatefulWidget {
  const _WindmillChart();

  @override
  _WindmillChartState createState() => _WindmillChartState();
}

class _WindmillChartState extends State<_WindmillChart> {
  late List<_WindEnergy> _windEnergyData;

  @override
  void initState() {
    _windEnergyData = [
      _WindEnergy('Brazil', 29135),
      _WindEnergy('United Kingdom', 30215),
      _WindEnergy('Spain', 31028),
      _WindEnergy('India', 44736),
      _WindEnergy('Germany', 69459),
      _WindEnergy('US', 148020),
      _WindEnergy('China', 441895),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _BackgroundPainter(),
          ),
          SfCartesianChart(
            plotAreaBorderWidth: 0,
            primaryXAxis: const CategoryAxis(
              majorGridLines: MajorGridLines(width: 0),
              majorTickLines: MajorTickLines(color: Colors.white),
              axisLine: AxisLine(color: Colors.white, width: 2),
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
            primaryYAxis: NumericAxis(
              title: const AxisTitle(text: 'Megawatts'),
              majorGridLines: const MajorGridLines(width: 0),
              majorTickLines: const MajorTickLines(color: Colors.white),
              axisLine: const AxisLine(color: Colors.white, width: 2),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              axisLabelFormatter: (AxisLabelRenderDetails args) {
                return ChartAxisLabel('${args.text} MW', args.textStyle);
              },
            ),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              activationMode: ActivationMode.singleTap,
              color: Colors.brown,
              borderColor: Colors.brown,
              borderWidth: 5,
              builder: (dynamic data, dynamic point, dynamic series,
                  int pointIndex, int seriesIndex) {
                return Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        SizedBox(
                          height: 30,
                          width: 35,
                          child: Image.asset(_countryImages(pointIndex)),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${point.y.toString()}MW',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            title: const ChartTitle(
              text:
                  ' Visualize the largest top 7 wind power producers by country ',
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.brown,
                fontSize: 20,
              ),
              backgroundColor: Colors.white,
            ),
            series: <CartesianSeries<_WindEnergy, String>>[
              ColumnSeries(
                dataSource: _windEnergyData,
                xValueMapper: (_WindEnergy data, int index) => data.country,
                yValueMapper: (_WindEnergy data, int index) => data.megawatt,
                animationDuration: 0,
                onCreateRenderer: (ChartSeries<_WindEnergy, String> series) {
                  return _CustomColumnSeriesRenderer();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _countryImages(int pointIndex) {
    switch (pointIndex) {
      case 0:
        return 'assets/brazil.png';
      case 1:
        return 'assets/uk.png';
      case 2:
        return 'assets/spain.png';
      case 3:
        return 'assets/india.png';
      case 4:
        return 'assets/germany.png';
      case 5:
        return 'assets/us.png';
      case 6:
        return 'assets/china.png';
    }
    return '';
  }

  @override
  void dispose() {
    _windEnergyData.clear();
    super.dispose();
  }
}

class _WindEnergy {
  _WindEnergy(this.country, this.megawatt);
  final String country;
  final double megawatt;
}

// Custom renderer for column series
class _CustomColumnSeriesRenderer
    extends ColumnSeriesRenderer<_WindEnergy, String> {
  @override
  ColumnSegment<_WindEnergy, String> createSegment() => _ColumnSegment();
}

// Custom segment class to draw custom shapes.
class _ColumnSegment extends ColumnSegment<_WindEnergy, String> {
  final Path _bladesPath = Path();
  Path _postPath = Path();

  void _reset() {
    _bladesPath.reset();
    _postPath.reset();
  }

  @override
  bool contains(Offset position) {
    return _postPath.contains(position) || _bladesPath.contains(position);
  }

  @override
  void onPaint(Canvas canvas) {
    _reset();
    if (segmentRect == null) {
      return;
    }

    final Paint bladeFillPaint = Paint()
      ..color = Colors.brown
      ..style = PaintingStyle.fill;
    final Paint bladeStrokePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Paint postFillPaint = bladeFillPaint;
    final Paint postStrokePaint = bladeStrokePaint;

    final double bottom = segmentRect!.bottom;
    final double top = segmentRect!.top;
    final double centerX = segmentRect!.center.dx;
    final double centerY = top;
    final double postBaseWidth = segmentRect!.width * 0.2;
    final double postTopWidth = segmentRect!.width * 0.05;
    final double halfPostBaseWidth = postBaseWidth / 2;
    final double halfPostTopWidth = postTopWidth / 2;

    _postPath = Path()
      ..moveTo(centerX - halfPostBaseWidth, bottom)
      ..lineTo(centerX + halfPostBaseWidth, bottom)
      ..lineTo(centerX + halfPostTopWidth, top)
      ..lineTo(centerX - halfPostTopWidth, top)
      ..close();

    canvas.drawPath(_postPath, postFillPaint);
    canvas.drawPath(_postPath, postStrokePaint);

    final Offset center = Offset(centerX, centerY);
    double bladeWidth = 20;
    double bladeLength =
        10 * (currentSegmentIndex < 3 ? 3 : currentSegmentIndex.toDouble());

    // Define the angles for the three blades in radians.
    double angle1 = 0;
    double angle2 = 120 * pi / 180;
    double angle3 = 240 * pi / 180;

    // Draw first blade.
    _drawBlade(canvas, center, angle1, bladeLength, bladeWidth, bladeFillPaint,
        bladeStrokePaint);

    // Draw second blade.
    _drawBlade(canvas, center, angle2, bladeLength, bladeWidth, bladeFillPaint,
        bladeStrokePaint);

    // Draw third blade.
    _drawBlade(canvas, center, angle3, bladeLength, bladeWidth, bladeFillPaint,
        bladeStrokePaint);

    // Draws circle at the center of the windmill.
    canvas.drawCircle(center, 5, Paint()..color = Colors.white);
  }

  // Helper method to draw each blade
  void _drawBlade(
    Canvas canvas,
    Offset center,
    double angle,
    double bladeLength,
    double bladeWidth,
    Paint fillPaint,
    Paint strokePaint,
  ) {
    Matrix4 transformMatrix = Matrix4.identity()
      ..translate(center.dx, center.dy)
      ..rotateZ(angle);

    final double halfWidth = bladeWidth / 2;
    final double quarterWidth = bladeWidth / 4;
    final Path bladePath = Path()
      ..moveTo(0, 0)
      ..cubicTo(
          quarterWidth, -bladeLength, halfWidth, -bladeLength, 0, -bladeLength)
      ..cubicTo(-quarterWidth, -bladeLength, -halfWidth, -bladeLength, 0, 0);

    _bladesPath.addPath(bladePath, Offset.zero,
        matrix4: transformMatrix.storage);

    // Draw the blade on the canvas
    canvas.drawPath(_bladesPath, fillPaint);
    canvas.drawPath(_bladesPath, strokePaint);
  }

  @override
  void dispose() {
    _reset();
    super.dispose();
  }
}

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final Rect backgroundRect = Rect.fromLTWH(0, 0, width, height);
    final Paint sunPaint = Paint()..color = Colors.yellow;
    final Paint skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Colors.orange,
          Color.fromARGB(255, 90, 190, 236),
          Colors.lightGreen,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(backgroundRect);

    canvas.drawRect(backgroundRect, skyPaint);
    canvas.drawCircle(Offset(width * 0.8, height * 0.2), 60, sunPaint);
    _drawCloud(canvas, Offset(width * 0.3, height * 0.3));
    _drawCloud(canvas, Offset(width * 0.6, height * 0.4));
  }

  void _drawCloud(Canvas canvas, Offset position) {
    final Paint cloudPaint = Paint()..color = Colors.white;
    _drawOval(canvas, position.translate(-40, 10), 70, 40, cloudPaint);
    _drawOval(canvas, position.translate(40, 10), 70, 40, cloudPaint);
    _drawOval(canvas, position, 100, 60, cloudPaint);
  }

  void _drawOval(Canvas canvas, Offset position, double width, double height,
      Paint paint) {
    canvas.drawOval(
        Rect.fromCenter(center: position, width: width, height: height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
