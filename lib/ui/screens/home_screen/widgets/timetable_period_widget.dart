import 'package:flutter/material.dart';
import 'package:your_schedule/core/api/models/timetable_period.dart';

class TimeTablePeriodWidget extends StatelessWidget {
  const TimeTablePeriodWidget({
    required this.period,
    super.key,
  });

  final TimeTablePeriod period;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (period.periodStatus) {
      case PeriodStatus.regular:
        color = Colors.lightGreen;
        break;
      case PeriodStatus.irregular:
        color = Colors.orange;
        break;
      case PeriodStatus.cancelled:
        color = Colors.red;
        break;
      case PeriodStatus.empty:
        color = Colors.grey;
        break;
      case PeriodStatus.unknown:
        color = Colors.grey;
        break;
    }

    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool useShortText = constraints.maxWidth < 100;

            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(child: Text(period.subject.name)),
                Flexible(
                  child: Text(
                    useShortText
                        ? period.teacher.name
                        : period.teacher.longName,
                  ),
                ),
                Flexible(child: Text(period.room.name)),
                if (period.activityType != null)
                  Flexible(child: Text(period.activityType!)),
                if (period.substText != null)
                  Flexible(child: Text(period.substText!)),
              ],
            );
          },
        ),
      ),
    );
  }
}
