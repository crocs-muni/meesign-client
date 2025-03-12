import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WeightedAvatar extends StatelessWidget {
  final int index;
  final List<int> weights;
  final Widget? child;

  const WeightedAvatar({
    super.key,
    required this.index,
    required this.weights,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        SizedBox.square(
          dimension: 32,
          child: CircleAvatar(
            child: child,
          ),
        ),
        SizedBox.square(
          dimension: 40,
          child: PieChart(
            PieChartData(
              startDegreeOffset: -90,
              sectionsSpace: 2,
              sections: [
                for (final (j, weight) in weights.indexed)
                  PieChartSectionData(
                    radius: 2,
                    value: weight.toDouble(),
                    showTitle: false,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: j == index ? 1 : .2),
                  )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
