import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:your_schedule/core/api/models/period_schedule.dart';
import 'package:your_schedule/core/api/providers/period_schedule_provider.dart';
import 'package:your_schedule/util/date_utils.dart';

class TimeIndicator extends ConsumerWidget {
  const TimeIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => TimedRefresh(
        interval: const Duration(seconds: 30),
        builder: (time, context) {
          late TimeOfDay startTime;
          late TimeOfDay endTime;
          ref.watch(periodScheduleProvider).when(
            data: (state) {
              startTime = state.entries.first.startTime;
              endTime = state.entries.last.endTime;
            },
            loading: () {
              startTime =
                  PeriodSchedule.periodScheduleFallback.entries.first.startTime;
              endTime =
                  PeriodSchedule.periodScheduleFallback.entries.last.endTime;
            },
            error: (error, stackTrace) {
              startTime =
                  PeriodSchedule.periodScheduleFallback.entries.first.startTime;
              endTime =
                  PeriodSchedule.periodScheduleFallback.entries.last.endTime;
              Sentry.captureException(error, stackTrace: stackTrace);
            },
          );

          TimeOfDay now = TimeOfDay.fromDateTime(time);

          if (now.difference(startTime) < Duration.zero ||
              now.difference(endTime) > Duration.zero) {
            return const SizedBox.shrink();
          }

          double relativePosition = now.difference(startTime).inMinutes /
              endTime.difference(startTime).inMinutes;
          if (relativePosition < 0) {
            relativePosition = 0;
          } else if (relativePosition > 1) {
            relativePosition = 1;
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  Spacer(
                    flex: (relativePosition * constraints.maxHeight).floor(),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1.25,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
                Spacer(
                  flex: (constraints.maxHeight -
                          (relativePosition * constraints.maxHeight))
                      .floor(),
                ),
              ],
            );
          },
        );
      },
    );
}

class TimedRefresh extends StatefulWidget {
  final Duration interval;
  final Widget Function(DateTime time, BuildContext context) builder;

  const TimedRefresh({
    required this.interval,
    required this.builder,
    super.key,
  });

  @override
  State<TimedRefresh> createState() => _TimedRefreshState();
}

class _TimedRefreshState extends State<TimedRefresh> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.interval, (_) => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) => widget.builder(DateTime.now(), context);
}
