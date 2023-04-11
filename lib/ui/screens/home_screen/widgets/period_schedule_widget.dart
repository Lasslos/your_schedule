import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:your_schedule/core/api/models/period_schedule.dart';
import 'package:your_schedule/core/api/providers/period_schedule_provider.dart';
import 'package:your_schedule/util/date_utils.dart';
import 'package:your_schedule/util/logger.dart';

class PeriodScheduleWidget extends ConsumerStatefulWidget {
  const PeriodScheduleWidget({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  ConsumerState<PeriodScheduleWidget> createState() => _PeriodScheduleWidgetState();
}

class _PeriodScheduleWidgetState extends ConsumerState<PeriodScheduleWidget> {
  @override
  Widget build(BuildContext context) {
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
            Expanded(child: widget.child),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodScheduleWidget(BuildContext context) {
    return ref.watch(periodScheduleProvider).when(
      error: (error, stackTrace) {
        Sentry.captureException(error, stackTrace: stackTrace);
        return Text(error.toString());
      },
      loading: () => const SizedBox.shrink(),
      data: (periodSchedule) {
            late TimeOfDay startTime;
            late TimeOfDay endTime;

            ref.watch(periodScheduleProvider).when(
              data: (state) {
                startTime = state.entries.first.startTime;
                endTime = state.entries.last.endTime;
              },
              loading: () {
                startTime = PeriodSchedule
                    .periodScheduleFallback.entries.first.startTime;
                endTime =
                    PeriodSchedule.periodScheduleFallback.entries.last.endTime;
              },
              error: (error, stackTrace) {
                startTime = PeriodSchedule
                    .periodScheduleFallback.entries.first.startTime;
                endTime =
                    PeriodSchedule.periodScheduleFallback.entries.last.endTime;
                Sentry.captureException(error, stackTrace: stackTrace);
              },
            );

            var firstDifference = startTime.difference(startTime).inMinutes;
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
          width: 42,
          child: Column(
            children: children,
          ),
        );
      },
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.startTime.toMyString(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 8,
                  ),
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
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Spacer(),
                Text(
                  entry.endTime.toMyString(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
