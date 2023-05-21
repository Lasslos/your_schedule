import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:your_schedule/core/session/custom_subject_colors.dart';
import 'package:your_schedule/core/session/filters.dart';
import 'package:your_schedule/core/session/session.dart';
import 'package:your_schedule/core/untis/untis_api.dart';
import 'package:your_schedule/custom_subject_color/custom_subject_color.dart';

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
    UserData userData =
        ref.watch(selectedSessionProvider.select((value) => value.userData!));

    CustomSubjectColor statusColor;
    bool isRegularStatusColor = false;
    List<TimeTablePeriodStatus> periodStatuses = period.periodStatus;

    if (periodStatuses.contains(TimeTablePeriodStatus.exam)) {
      statusColor = examColor;
    } else if (periodStatuses.contains(TimeTablePeriodStatus.cancelled)) {
      statusColor = cancelledColor;
    } else if (periodStatuses.contains(TimeTablePeriodStatus.irregular) ||
        period.subject == null ||
        period.room == null ||
        period.teacher == null) {
      statusColor = irregularColor;
    } else if (periodStatuses.contains(TimeTablePeriodStatus.regular)) {
      isRegularStatusColor = true;
      statusColor = ref.watch(customSubjectColorsProvider)[period.subject?.id] ?? regularColor;
    } else {
      statusColor = emptyColor;
    }

    Subject? subject = userData.subjects[period.subject?.id];
    Room? room = userData.rooms[period.room?.id];
    Teacher? teacher = userData.teachers[period.teacher?.id];

    Color textColor = periodStatuses.contains(TimeTablePeriodStatus.cancelled) ? Theme.of(context).textTheme.bodyLarge!.color! : statusColor.textColor;

    return Card(
      margin: const EdgeInsets.all(2),
      color: periodStatuses.contains(TimeTablePeriodStatus.cancelled) ? Theme.of(context).cardColor : statusColor.color,
      shape: periodStatuses.contains(TimeTablePeriodStatus.cancelled)
          ? RoundedRectangleBorder(
              side: BorderSide(
                color: statusColor.color,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          onTap(
            context,
            ref,
            isRegularStatusColor ? null : statusColor,
            subject,
            teacher,
            room,
          );
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool useShortText = constraints.maxWidth < 100;
            String? subjectText = (useShortText ? subject?.name : subject?.longName) ?? period.lessonText;
            if (subjectText.isEmpty) {
              subjectText = null;
            }
            String? teacherText = useShortText ? teacher?.shortName : teacher?.longName;
            String? roomText = room?.name;

            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (subjectText != null)
                  Flexible(
                    child: Text(
                      subjectText,
                      style: TextStyle(
                        fontSize: fontSize,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                if (teacherText != null)
                  Flexible(
                    child: Text(
                      teacherText,
                      style: TextStyle(
                        fontSize: fontSize,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                if (roomText != null)
                  Flexible(
                    child: Text(
                      roomText,
                      style: TextStyle(
                        fontSize: fontSize,
                        color: textColor,
                      ),
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
    BuildContext context,
    WidgetRef ref,
    CustomSubjectColor? statusColor,
    Subject? subject,
    Teacher? teacher,
    Room? room,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PeriodDetailsView(
          period: period,
          statusColor: statusColor,
          subject: subject,
          teacher: teacher,
          room: room,
        ),
        fullscreenDialog: true,
      ),
    );
  }
}

class PeriodDetailsView extends ConsumerWidget {
  final TimeTablePeriod period;
  final Subject? subject;
  final Teacher? teacher;
  final Room? room;
  final CustomSubjectColor? statusColor;

  const PeriodDetailsView({
    required this.period,
    required this.statusColor,
    this.subject,
    this.teacher,
    this.room,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var customSubjectColor =
        ref.watch(customSubjectColorsProvider)[period.subject?.id] ??
            regularColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: statusColor?.color ?? customSubjectColor.color,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: statusColor?.textColor ?? customSubjectColor.textColor,
        ),
        title: Text(
          "Stundendetails",
          style: TextStyle(
            color: statusColor?.textColor ?? customSubjectColor.textColor,
          ),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(
            height: 8,
          ),
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
                  color: statusColor?.color ?? customSubjectColor.color,
                ),
                ListTile(
                  title: Text(
                    (subject?.longName ?? period.subject?.id.toString()) ??
                        period.lessonText,
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  subtitle: Text(
                    "${intl.DateFormat("dd. MMM HH:mm").format(period.startTime)}-${intl.DateFormat("HH:mm").format(period.endTime)}",
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
              teacher?.longName ?? "Kein Lehrer",
            ),
          ),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text("Raum"),
            subtitle: Text(
              room?.name ?? "Kein Raum",
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("Status"),
            subtitle: Text(
              period.periodStatus.map((e) => e.displayName).join(", "),
            ),
          ),
          if (period.infoText.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(period.infoText),
            ),
          if (period.lessonText.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.text_snippet_outlined),
              title: Text(period.lessonText),
            ),
          if (period.substitutionText.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.home_work_outlined),
              title: Text(period.substitutionText),
            ),
          const Divider(
            thickness: 1,
          ),
          if (period.subject != null)
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
                //einen color picker anzeigen
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Farbe ändern"),
                    content: MaterialColorPicker(
                      onColorChange: (color) {
                        Color textColor = color.computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white;
                        ref.read(customSubjectColorsProvider.notifier).add(
                              CustomSubjectColor(
                                period.subject!.id,
                                color,
                                textColor,
                              ),
                            );
                      },
                      selectedColor: customSubjectColor.color,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          ref
                              .read(customSubjectColorsProvider.notifier)
                              .remove(period.subject!.id);
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
          if (period.subject != null)
            ListTile(
              leading: const Icon(Icons.visibility_off, color: Colors.red),
              title: const Text(
                "Kurs ausblenden",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                ref.read(filtersProvider.notifier).remove(period.subject!.id);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }
}
