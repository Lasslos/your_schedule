import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/core/api/models/period_schedule.dart';
import 'package:your_schedule/core/api/providers/period_schedule_provider.dart';
import 'package:your_schedule/ui/screens/home_screen/pinch_to_zoom.dart';
import 'package:your_schedule/util/date_utils.dart';
import 'package:your_schedule/util/logger.dart';

///TODO: Inspect performance and improve, especially caching with all of these builders
///TODO: Add liquid pull to refresh
///TODO: Separate [TwoDimensionalScrollView] and what belongs to this app itself

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

  @override
  Widget build(BuildContext context) {
    return PinchToZoom.builder(
      builder: (context, height) => SingleChildScrollView(
        ///TODO: If you are REALLY bored, consider adding infinite scroll back and forth
        child: Row(
          children: [
            SizedBox(
              height: height,
              child: _buildPeriodScheduleWidget(context),
            ),
            const VerticalDivider(),
            Expanded(
              child: SizedBox(
                height: height,
                child: _buildBody(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) => widget.builder(context, index),
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
        getLogger().w("Difference between consecutive period schedule entries is smaller than 0");
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
                Text(entry.startTime.toMyString(), style: theme.textTheme.labelSmall,),
                const Spacer(),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                const Spacer(),
                Text(entry.periodNumber.toString(), style: theme.textTheme.labelMedium,),
                const Spacer(),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                const Spacer(),
                Text(entry.endTime.toMyString(), style: theme.textTheme.labelSmall,),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
