import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/core/session.dart';
import 'package:your_schedule/utils.dart';

class TimeIndicator extends ConsumerWidget {
  const TimeIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => TimedRefresh(
        interval: const Duration(seconds: 30),
        builder: (time, context) {
          var timeGrid = ref.watch(
            selectedSessionProvider.select((value) => value.userData!.timeGrid),
          );
          TimeOfDay startTime = timeGrid.first.startTime;
          TimeOfDay endTime = timeGrid.last.endTime;
          TimeOfDay now = TimeOfDay.fromDateTime(time);

          double relativePosition;

          if (now.difference(startTime) < Duration.zero) {
            relativePosition = 0;
          } else if (now.difference(endTime) > Duration.zero) {
            relativePosition = 1;
          } else {
            relativePosition = now.difference(startTime).inMinutes /
                endTime.difference(startTime).inMinutes;
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  if (relativePosition != 0)
                    Spacer(
                      flex: (relativePosition * constraints.maxHeight).floor(),
                    ),
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1.25,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                        ),
                      ),
                    ],
                  ),
                  if (relativePosition != 1)
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
