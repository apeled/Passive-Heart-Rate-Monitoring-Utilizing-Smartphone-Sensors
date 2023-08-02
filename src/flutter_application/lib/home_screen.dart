// Import relevant packages
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math';

// HomeScreen Widget
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int averageMeasurement = 0;
  int heartRate = 0;

  @override
  void initState() {
    super.initState();
    _generateRandomHeartRate();
  }

  @override
  Widget build(BuildContext context) {
    // App Layout
    return Scaffold(
      appBar: AppBar(
        title: Text('Healthy Pocket',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Heart Rate Chart
              Container(
                height: 300,
                child: HeartRateChart(),
              ),
              SizedBox(height: 32),
              // Heart Rate Stats
              _heartRateStats(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heartRateStats() {
    // Display latest and average heart rate
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _statsColumn(
          Icons.watch_later_outlined,
          'Latest',
          '$heartRate',
        ),
        _statsColumn(
          Icons.analytics_outlined,
          'Average',
          '$averageMeasurement',
        ),
      ],
    );
  }

  Widget _statsColumn(IconData icon, String title, String value) {
    // Create a stats column widget
    return Column(
      children: [
        Icon(icon, size: 60),
        SizedBox(height: 16),
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Container(
          width: 120,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(fontSize: 36),
            ),
          ),
        ),
      ],
    );
  }

  void _generateRandomHeartRate() {
    // Generate random heart rate
    final random = Random();
    final minHeartRate = 62;
    final maxHeartRate = 84;
    final generatedHeartRate = minHeartRate + random.nextInt(maxHeartRate - minHeartRate + 1);
    final generatedAverageMeasurement = minHeartRate + random.nextInt((maxHeartRate - 22) - minHeartRate + 1);

    setState(() {
      heartRate = generatedHeartRate;
      averageMeasurement = generatedAverageMeasurement;
    });
  }
}

// HeartRateChart Widget
class HeartRateChart extends StatefulWidget {
  @override
  _HeartRateChartState createState() => _HeartRateChartState();
}

class _HeartRateChartState extends State<HeartRateChart> {
  @override
  Widget build(BuildContext context) {
    // Generate mock heart rate data
    final List<HeartRateData> heartRateData = _generateMockHeartRateData();

    // Display chart with the data
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      title: ChartTitle(
        text: 'Heart Rate Measurements (BPM)',
        textStyle: TextStyle(
          color: Colors.grey[800],
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      primaryXAxis: CategoryAxis(
        axisLine: AxisLine(width: 2, color: Colors.grey[400]),
        majorGridLines: MajorGridLines(width: 0),
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
        title: AxisTitle(
          text: 'Time',
          textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
      primaryYAxis: NumericAxis(
        edgeLabelPlacement: EdgeLabelPlacement.shift,
        labelPosition: ChartDataLabelPosition.outside,
        isVisible: true,
        axisLine: AxisLine(width: 0, color: Colors.grey[400]),
        majorTickLines: MajorTickLines(size: 0),
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
        minimum: 40,
      ),
      series: <ChartSeries>[
        SplineSeries<HeartRateData, String>(
            dataSource: heartRateData,
            xValueMapper: (HeartRateData data, _) => data.time,
            yValueMapper: (HeartRateData data, _) => data.heartRate,
            markerSettings: MarkerSettings(
              isVisible: true,
              color: Colors.blueGrey,
              borderColor: Colors.white,
              borderWidth: 1,
            ),
            color: Colors.blueGrey),
      ],
      tooltipBehavior: TooltipBehavior(
        enable: true,
        color: Colors.grey,
        textStyle: TextStyle(color: Colors.white),
        header: '',
        format: 'point.y bpm',
      ),
      trackballBehavior: TrackballBehavior(
        enable: true,
        activationMode: ActivationMode.singleTap,
        tooltipSettings: InteractiveTooltip(
          enable: true,
          color: Color.fromARGB(117, 0, 0, 0),
          textStyle: TextStyle(color: Colors.white),
          format: 'point.y bpm | point.x',
        ),
        lineType: TrackballLineType.vertical,
        lineWidth: 1,
        lineColor: Colors.blueGrey,
      ),
    );
  }

  List<HeartRateData> _generateMockHeartRateData() {
    // Generate random heart rate data for 24 hours
    final List<HeartRateData> data = [];
    final totalDataPoints = 24;
    final random = Random();

    for (int i = 0; i < totalDataPoints; i++) {
      final time = '${i.toString().padLeft(2, '0')}:00';
      final heartRate = _calculateRandomHeartRate(i, random);

      data.add(HeartRateData(time: time, heartRate: heartRate));
    }

    return data;
  }

  int _calculateRandomHeartRate(int hour, Random random) {
    // Calculate a random heart rate based on the hour
    if ((hour < 10) || (hour > 20) || (hour == 13) || (hour == 14) || (hour == 15)) {
      return random.nextInt(50) + hour + 40;
    } else {
      return random.nextInt(50) + hour + 50;
    }
  }
}

// HeartRateData class

class HeartRateData {
  final String time;
  final int heartRate;

  HeartRateData({required this.time, required this.heartRate});
}
