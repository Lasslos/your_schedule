import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/ui/screens/home_screen/home_screen_state_provider.dart';
import 'package:your_schedule/util/date_utils.dart';

class TimeIndicator extends ConsumerWidget {
  const TimeIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var homeScreenState = ref.watch(homeScreenStateProvider);

    return TimedRefresh(
      interval: const Duration(seconds: 30),
      builder: (time, context) {
        TimeOfDay startTime = homeScreenState.startOfDay;
        TimeOfDay endTime = homeScreenState.endOfDay;
        TimeOfDay now = TimeOfDay.fromDateTime(time);

        if (now.difference(startTime) < Duration.zero ||
            now.difference(endTime) > Duration.zero) {
          return const SizedBox.shrink();
        }

        double relativePosition = now.difference(startTime).inMinutes /
            endTime.difference(startTime).inMinutes;
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
