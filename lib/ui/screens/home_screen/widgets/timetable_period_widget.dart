import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:your_schedule/core/api/models/timetable_periodider.dart';
import 'package:your_schedule/util/string_utils.dart';

class TimeTablePeriodWidget extends ConsumerWidget {
  const TimeTablePeriodWidget({
    required this.period,
    required this.fontSize,
    super.key,
  });

  final double fontSize;
  final TimeTablePeriod period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      child: InkWell(
        onTap: () {
          onTap(context, ref, color);
        },
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
                    overflow: TextOverflow.visible,
                  ),
                ),
                Flexible(
                  child: Text(
                    useShortText
                        ? period.teacher.name
                        : period.teacher.longName,
                    style: TextStyle(fontSize: fontSize, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                  ),
                ),
                Flexible(
                  child: Text(
                    period.room.name,
                    style: TextStyle(fontSize: fontSize, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                  ),
                ),
                /*if (period.activityType != null)
                  Flexible(
                    child: Text(
                      period.activityType!,
                      style: TextStyle(fontSize: fontSize),
                      maxLines: 1,
                    overflow: TextOverflow.visible,
                    ),
                  ),*/
              ],
            );
          },
        ),
      ),
    );
  }

  void onTap(BuildContext context, WidgetRef ref, Color periodStatusColor) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: periodStatusColor,
            title: ListTile(
              title:
                  Text(intl.DateFormat("EEEE, dd.MM.y").format(period.start)),
              subtitle: Text(
                "${intl.DateFormat("HH:mm").format(period.start)} - ${intl.DateFormat("HH:mm").format(period.end)}",
              ),
            ),
          ),
          body: ListView(
            children: [
              ListTile(
                title: const Text("Fach"),
                subtitle: Text(period.subject.name),
              ),
              ListTile(
                title: const Text("Lehrer"),
                subtitle: Text(
                    period.teacher.longName.toLowerCase().capitalizeFirst()),
              ),
              ListTile(
                title: const Text("Raum"),
                subtitle: Text(period.room.name),
              ),
              ListTile(
                title: const Text("Status"),
                subtitle: Text(period.periodStatus.readableName),
              ),
              ListTile(
                title: const Text("Klasse"),
                subtitle: Text(
                    "${period.schoolClass.name} - ${period.schoolClass.longName}"),
              ),
              if (period.substText != null)
                ListTile(
                  title: const Text("Vertretungstext"),
                  subtitle: Text(period.substText!),
                ),
              if (period.activityType != null)
                ListTile(
                  title: const Text("Aktivitätstyp"),
                  subtitle: Text(period.activityType!),
                ),
            ],
          ),
        ),
        fullscreenDialog: true,
      ),
    );
  }
}
