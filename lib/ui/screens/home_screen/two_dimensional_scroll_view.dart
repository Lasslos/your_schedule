import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:your_schedule/core/api/models/period_schedule.dart';
import 'package:your_schedule/core/api/providers/period_schedule_provider.dart';
import 'package:your_schedule/ui/screens/home_screen/pinch_to_zoom.dart';
import 'package:your_schedule/util/date_utils.dart';
import 'package:your_schedule/util/logger.dart';


class TwoDimensionalScrollView extends ConsumerStatefulWidget {
  const TwoDimensionalScrollView.builder(
    this.builder, {
      super.key,
  });

  final Widget Function(BuildContext context, int index) builder;

  @override
  ConsumerState<TwoDimensionalScrollView> createState() =>
      _TwoDimensionalScrollViewState();
}

class _TwoDimensionalScrollViewState extends ConsumerState<TwoDimensionalScrollView> {
  late LinkedScrollControllerGroup _controllers;
  late ScrollController _periodScheduleController;
  late ScrollController _bodyController;

  @override
  void initState() {
    super.initState();
    _controllers = LinkedScrollControllerGroup();
    _periodScheduleController = _controllers.addAndGet();
    _bodyController = _controllers.addAndGet();
  }

  @override
  Widget build(BuildContext context) {
    return PinchToZoom(
      child: Row(
        children: [
          _buildPeriodScheduleWidget(context),
          _buildBody(context),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) => SingleChildScrollView(
        controller: _bodyController,
        ///TODO: If you are REALLY bored, consider adding infinite scroll back and forth
        child: widget.builder(context, index),
      ),
    );
  }

  Widget _buildPeriodScheduleWidget(BuildContext context) {
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
      var difference = entry.startTime.difference(previousEntry.endTime).inMinutes;

      if (difference > 0) {
        children.add(
          Spacer(
            flex: difference,
          ),
        );
      } else if (difference < 0) {
        getLogger().w("Difference between consecutive period schedule entries is smaller than 0");
      }

      children.add(
        Flexible(
          flex: entry.length.inMinutes,
          child: PeriodScheduleColumnElement(entry: entry),
        ),
      );
    }

    return SingleChildScrollView(
      controller: _periodScheduleController,
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
      padding: const EdgeInsets.all(4),
      child: Card(
        child: Column(
          children: [
            Row(
              children: [
                Text(entry.startTime.toString(), style: theme.textTheme.labelSmall,),
                const Spacer(),
              ],
            ),
            Row(
              children: [
                const Spacer(),
                Text(entry.periodNumber.toString(), style: theme.textTheme.labelMedium,),
                const Spacer(),
              ],
            ),
            Row(
              children: [
                const Spacer(),
                Text(entry.startTime.toString(), style: theme.textTheme.labelSmall,),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
