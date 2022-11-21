import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/core/api/models/helpers/timetable_week.dart';
import 'package:your_schedule/core/api/models/period_schedule.dart';
import 'package:your_schedule/core/api/providers/period_schedule_provider.dart';
import 'package:your_schedule/ui/screens/home_screen/home_screen_state_provider.dart';
import 'package:your_schedule/ui/screens/home_screen/widgets/timed_refresh.dart';
import 'package:your_schedule/util/date_utils.dart';
import 'package:your_schedule/util/logger.dart';

class PeriodScheduleWidget extends ConsumerStatefulWidget {
  const PeriodScheduleWidget({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  ConsumerState<PeriodScheduleWidget> createState() =>
      _PeriodScheduleWidgetState();
}

class _PeriodScheduleWidgetState extends ConsumerState<PeriodScheduleWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var periodSchedule = ref.read(periodScheduleProvider);
      var startTime = ref.read(homeScreenStateProvider).startOfDay;
      var endTime = ref.read(homeScreenStateProvider).endOfDay;

      if (periodSchedule.entries.first.startTime != startTime) {
        ref.read(homeScreenStateProvider.notifier).startOfDay =
            periodSchedule.entries.first.startTime;
      }
      if (periodSchedule.entries.last.endTime != endTime) {
        ref.read(homeScreenStateProvider.notifier).endOfDay =
            periodSchedule.entries.last.endTime;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeScreenState = ref.watch(homeScreenStateProvider);

    return SingleChildScrollView(
      child: SizedBox(
        height: 750,
        child: Row(
          children: [
            Column(
              children: [
                const SizedBox(height: 42),
                Expanded(
                  child: _buildPeriodScheduleWidget(context),
                ),
              ],
            ),
            const VerticalDivider(
              width: 1,
              thickness: 0.7,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Stack(
                children: [
                  widget.child,
                  TimedRefresh(
                    interval: const Duration(seconds: 30),
                    builder: (time, context) {
                      if ((homeScreenState.currentDate !=
                                  DateTime.now().normalized() &&
                              homeScreenState.viewMode == ViewMode.day) ||
                          (Week.fromDateTime(homeScreenState.currentDate) !=
                                  Week.now()) &&
                              homeScreenState.viewMode == ViewMode.week) {
                        return const SizedBox.shrink();
                      }

                      TimeOfDay startTime = homeScreenState.startOfDay;
                      TimeOfDay endTime = homeScreenState.endOfDay;
                      TimeOfDay now = TimeOfDay.fromDateTime(time);

                      if (now.difference(startTime) < Duration.zero ||
                          now.difference(endTime) > Duration.zero) {
                        return const SizedBox.shrink();
                      }

                      double relativePosition =
                          now.difference(startTime).inMinutes /
                              endTime.difference(startTime).inMinutes;
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return Column(
                            children: [
                              Spacer(
                                  flex:
                                      (relativePosition * constraints.maxHeight)
                                          .floor()),
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.black
                                          : Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(
                                  flex: (constraints.maxHeight -
                                          (relativePosition *
                                              constraints.maxHeight))
                                      .floor()),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodScheduleWidget(BuildContext context) {
    var periodSchedule = ref.watch(periodScheduleProvider);
    var startTime =
        ref.watch(homeScreenStateProvider.select((value) => value.startOfDay));
    var endTime =
        ref.watch(homeScreenStateProvider.select((value) => value.endOfDay));

    var firstDifference =
        periodSchedule.entries.first.startTime.difference(startTime).inMinutes;
    List<Widget> children = [
      if (firstDifference > 1)
        Spacer(
          flex: firstDifference,
        ),
    ];

    int periodScheduleLength = periodSchedule.entries.length;
    for (int i = 0; i < periodScheduleLength; i++) {
      var entry = periodSchedule.entries[i];
      TimeOfDay? nextStartTime = periodScheduleLength - 1 != i
          ? periodSchedule.entries[i + 1].startTime
          : null;
      int? difference = nextStartTime?.difference(entry.endTime).inMinutes;

      children.addAll([
        if (children.isEmpty || children.last.runtimeType != Divider)
          const Divider(
            thickness: 0.7,
            height: 1,
          ),
        Flexible(
          flex: entry.length.inMinutes,
          child: PeriodScheduleColumnElement(entry: entry),
        ),
        const Divider(
          thickness: 0.7,
          height: 1,
        ),
      ]);

      if (difference != null && difference > 1) {
        children.addAll([
          Spacer(
            flex: difference,
          ),
        ]);
      } else if (difference != null && difference < 0) {
        getLogger().w(
          "Difference between consecutive period schedule entries is smaller than 0"
          " (difference: $difference, entry: $entry, nextStartTime: $nextStartTime)",
        );
      }
    }

    var lastDifference =
        endTime.difference(periodSchedule.entries.last.endTime).inMinutes;
    if (lastDifference > 1) {
      children.add(
        Spacer(
          flex: lastDifference,
        ),
      );
    }

    return SizedBox(
      width: 64,
      child: Column(
        children: children,
      ),
    );
  }
}

class PeriodScheduleColumnElement extends StatelessWidget {
  const PeriodScheduleColumnElement({required this.entry, super.key});

  final PeriodScheduleEntry entry;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  entry.startTime.toMyString(),
                  style: theme.textTheme.labelSmall,
                ),
                const Spacer(),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                const Spacer(),
                Text(
                  entry.periodNumber.toString(),
                  style: theme.textTheme.labelMedium,
                ),
                const Spacer(),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                const Spacer(),
                Text(
                  entry.endTime.toMyString(),
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
