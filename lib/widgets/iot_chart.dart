import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class IotChart extends StatelessWidget {
  final List<double> dados;

  const IotChart({super.key, required this.dados});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        backgroundColor: Colors.black,
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: dados
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value))
                .toList(),
            isCurved: true,
            color: const Color(0xFFFFB300),
            barWidth: 3,
          ),
        ],
      ),
    );
  }
}
