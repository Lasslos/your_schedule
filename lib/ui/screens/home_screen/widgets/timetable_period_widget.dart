import 'package:flutter/material.dart';
import 'package:your_schedule/core/api/models/timetable_period.dart';

class TimeTablePeriodWidget extends StatelessWidget {
  const TimeTablePeriodWidget({required this.period, Key? key})
      : super(key: key);

  final TimeTablePeriod period;

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(4),
      child: Placeholder(),

      ///TODO: Implement
    );
  }
}
