import 'package:flutter/material.dart';
import 'package:your_schedule/core/api/models/timetable_period.dart';

class TimeTablePeriodWidget extends StatelessWidget {
  const TimeTablePeriodWidget({
    required this.period,
    required this.fontSize,
    super.key,
  });

  final double fontSize;
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
      margin: const EdgeInsets.all(2),
      color: color,
      clipBehavior: Clip.hardEdge,
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool useShortText = constraints.maxWidth < 100;

          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: Text(
                  period.subject.name,
                  style: TextStyle(fontSize: fontSize, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                ),
              ),
              Flexible(
                child: Text(
                  useShortText ? period.teacher.name : period.teacher.longName,
                  style: TextStyle(fontSize: fontSize, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                ),
              ),
              Flexible(
                child: Text(
                  period.room.name,
                  style: TextStyle(fontSize: fontSize, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                ),
              ),
              /*if (period.activityType != null)
                Flexible(
                  child: Text(
                    period.activityType!,
                    style: TextStyle(fontSize: fontSize),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                  ),
                ),*/
            ],
          );
        },
      ),
    );
  }
}
