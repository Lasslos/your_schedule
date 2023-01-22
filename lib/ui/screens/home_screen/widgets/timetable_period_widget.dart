import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:your_schedule/core/api/models/timetable_period.dart';
import 'package:your_schedule/filter/filter.dart';
import 'package:your_schedule/settings/custom_subject_color/custom_subject_color_provider.dart';

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
    CustomSubjectColor statusColor;
    switch (period.periodStatus) {
      case PeriodStatus.regular:
        statusColor = ref.watch(customSubjectColorProvider
                .select((value) => value[period.subject])) ??
            CustomSubjectColor.regularColor;
        break;
      case PeriodStatus.irregular:
        statusColor = CustomSubjectColor.irregularColor;
        break;
      case PeriodStatus.cancelled:
        statusColor = CustomSubjectColor.cancelledColor;
        break;
      case PeriodStatus.empty:
        statusColor = CustomSubjectColor.emptyColor;
        break;
      case PeriodStatus.unknown:
        statusColor = CustomSubjectColor.emptyColor;
        break;
    }

    return Card(
      margin: const EdgeInsets.all(2),
      color: statusColor.color,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          onTap(context, ref, statusColor);
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
                    style: TextStyle(
                        fontSize: fontSize, color: statusColor.textColor),
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                  ),
                ),
                Flexible(
                  child: Text(
                    useShortText
                        ? period.teacher.name
                        : period.teacher.longName,
                    style: TextStyle(
                        fontSize: fontSize, color: statusColor.textColor),
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                  ),
                ),
                Flexible(
                  child: Text(
                    period.room.name,
                    style: TextStyle(
                        fontSize: fontSize, color: statusColor.textColor),
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void onTap(
      BuildContext context, WidgetRef ref, CustomSubjectColor statusColor) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PeriodDetailsView(
          period: period,
          statusColor:
              period.periodStatus != PeriodStatus.regular ? statusColor : null,
        ),
        fullscreenDialog: true,
      ),
    );
  }
}

class PeriodDetailsView extends ConsumerWidget {
  final TimeTablePeriod period;
  final CustomSubjectColor? statusColor;

  const PeriodDetailsView({
    required this.period,
    required this.statusColor,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CustomSubjectColor customSubjectColor = ref.watch(customSubjectColorProvider
            .select((value) => value[period.subject])) ??
        CustomSubjectColor.regularColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: statusColor?.color ?? customSubjectColor.color,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: statusColor?.textColor ?? customSubjectColor.textColor,
        ),
        title: Text("Stundendetails",
            style: TextStyle(
                color: statusColor?.textColor ?? customSubjectColor.textColor)),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: ListView(
          children: [
            SizedBox(
              height: 150,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 50,
                    color: customSubjectColor.color,
                  ),
                  ListTile(
                    title: Text(
                      period.subject.longName,
                      style: const TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    subtitle: Text(
                      "${intl.DateFormat("dd. MMM HH:mm").format(period.start)}-${intl.DateFormat("HH:mm").format(period.end)}",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              thickness: 1,
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text("Lehrer"),
              subtitle: Text(
                period.teacher.longName,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: const Text("Raum"),
              subtitle: Text(period.room.name),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("Status"),
              subtitle: Text(period.periodStatus.readableName),
            ),
            ListTile(
              enableFeedback: true,
              leading: const Icon(Icons.school_outlined),
              title: const Text("Klasse"),
              subtitle: Text(
                "${period.schoolClass.name} - ${period.schoolClass.longName}",
              ),
            ),
            if (period.substText != null)
              ListTile(
                leading: const Icon(Icons.text_snippet_outlined),
                title: const Text("Vertretungstext"),
                subtitle: Text(period.substText!),
              ),
            if (period.activityType != null)
              ListTile(
                leading: const Icon(Icons.backup_table),
                title: const Text("Aktivitätstyp"),
                subtitle: Text(period.activityType!),
              ),
            const Divider(
              thickness: 1,
            ),
            //create two list tiles, one shall add the period to the filterd ones that means hide it, the other one shall change its color
            ListTile(
              leading: SizedBox(
                width: 24,
                height: 24,
                child: Center(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: customSubjectColor.color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
              title: const Text("Farbe ändern"),
              onTap: () {
                //show a color picker
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Farbe ändern"),
                    content: MaterialColorPicker(
                      onColorChange: (color) {
                        Color textColor = color.computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white;
                        ref
                            .read(customSubjectColorProvider.notifier)
                            .addColor(period.subject, color, textColor);
                      },
                      selectedColor: customSubjectColor.color,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          ref
                              .read(customSubjectColorProvider.notifier)
                              .removeColor(period.subject);
                          Navigator.of(context).pop();
                        },
                        child: const Text("Zurücksetzen"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Ok"),
                      )
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility_off, color: Colors.red),
              title: const Text("Kurs ausblenden",
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                ref.read(filterItemsProvider.notifier).addItem(period.subject);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
