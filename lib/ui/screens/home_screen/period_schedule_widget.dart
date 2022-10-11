import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/core/api/models/period_schedule.dart';
import 'package:your_schedule/core/api/providers/period_schedule_provider.dart';
import 'package:your_schedule/util/date_utils.dart';
import 'package:your_schedule/util/logger.dart';

class PeriodScheduleWidget extends ConsumerWidget {
  const PeriodScheduleWidget({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Row(
        children: [
          SizedBox(
            height: 1000,
            child: _buildPeriodScheduleWidget(context, ref),
          ),
          const VerticalDivider(),
          Expanded(
            child: SizedBox(
              height: 1000,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodScheduleWidget(BuildContext context, WidgetRef ref) {
    var periodSchedule = ref.watch(periodScheduleProvider);

    List<Widget> children = [
      Flexible(
        flex: periodSchedule[0].length.inMinutes,
        child: PeriodScheduleColumnElement(entry: periodSchedule[0]),
      ),
    ];

    for (int i = 1; i < periodSchedule.entries.length; i++) {
      var previousEntry = periodSchedule[i - 1];
      var entry = periodSchedule[i];
      var difference =
          entry.startTime.difference(previousEntry.endTime).inMinutes;

      if (difference > 1) {
        children.addAll([
          Spacer(
            flex: difference ~/ 2,
          ),
          const Divider(),
          Spacer(
            flex: difference ~/ 2,
          ),
        ]);
      } else if (difference < 0) {
        getLogger().w(
          "Difference between consecutive period schedule entries is smaller than 0",
        );
      }

      children.add(
        Flexible(
          flex: entry.length.inMinutes,
          child: PeriodScheduleColumnElement(entry: entry),
        ),
      );
    }

    return SizedBox(
      width: 75,
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
