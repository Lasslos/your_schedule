import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/core/api/models/timetable_period.dart';
import 'package:your_schedule/ui/screens/home_screen/home_screen_state_provider.dart';
import 'package:your_schedule/ui/screens/home_screen/widgets/timetable_period_widget.dart';

/// A widget that displays all the periods of a day.
/// The algorithm works as follows:

/// 1. The layout is an unlimited grid
/// 2. Each event is one cell wide, and the height and vertical position is fixed based on starting and ending times.
/// 3. Try to place each event in a column as far left as possible, without it intersecting any earlier event in that column.
/// 4. Then, when each connected group of events is placed, their actual widths will be 1/n of the maximum number of columns used by the group.
/// This is calculated in order of size if the group to make sure the largest group is always 1/n of the maximum number of columns used.
/// 5. Then, any event that can have more space is expanded to fill the space.

//This returns the periods as a grid. It is implemented as a stream to be able tp separately yield
//the parts of the grid that are independent of each other.
//This simplifies the code and makes it easier to understand without removing any functionality.
Iterable<List<List<TimeTablePeriod>>> periodsToTimeTableGrid(
    List<TimeTablePeriod> periods) sync* {
  /// The grid is a list of columns, each of which is a list of "rows" which are actually just periods.
  List<List<TimeTablePeriod>> grid = [];
  DateTime? lastEndTime;

  periods.sort(
    (a, b) => !a.start.isAtSameMomentAs(b.start)
        ? a.start.compareTo(b.start)
        : a.end.compareTo(b.end),
  );

  /// We go through each period in order of start time.
  for (TimeTablePeriod period in periods) {
    if (lastEndTime != null && period.start.isAfter(lastEndTime)) {
      /// In this case, all the following periods are independent of the previous ones.
      /// We yield the grid and start a new one.
      yield grid;
      grid = [];
      lastEndTime = null;
    }

    /// We try to place the period in the first column where the last element doesn't intersect with this period.
    /// We just have to check the last as the periods are sorted by start time.
    bool placed = false;
    for (var column in grid) {
      if (!column.last.collidesWith(period)) {
        column.add(period);
        placed = true;
        break;
      }
    }
    if (!placed) {
      /// If we couldn't place it in any column, we create a new one.
      grid.add([period]);
    }
    if (lastEndTime == null || period.end.isAfter(lastEndTime)) {
      lastEndTime = period.end;
    }
  }
  if (grid.isNotEmpty) {
    yield grid;
  }
}

class PeriodLayout extends ConsumerStatefulWidget {
  final List<TimeTablePeriod> periods;
  final double fontSize;

  const PeriodLayout({
    required this.periods,
    required this.fontSize,
    super.key,
  });

  @override
  ConsumerState<PeriodLayout> createState() => _PeriodLayoutState();
}

class _PeriodLayoutState extends ConsumerState<PeriodLayout> {
  @override
  void initState() {
    super.initState();
    if (widget.periods.isEmpty) {
      return;
    }
    var earliestStart = widget.periods
        .map((e) => e.start)
        .reduce((value, element) => value.isBefore(element) ? value : element);
    var latestEnd = widget.periods
        .map((e) => e.end)
        .reduce((value, element) => value.isAfter(element) ? value : element);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(homeScreenStateProvider.notifier)
        ..startOfDay = TimeOfDay.fromDateTime(earliestStart)
        ..endOfDay = TimeOfDay.fromDateTime(latestEnd);
    });
  }

  @override
  Widget build(BuildContext context) {
    TimeOfDay startOfDay =
        ref.watch(homeScreenStateProvider.select((value) => value.startOfDay));
    TimeOfDay endOfDay =
        ref.watch(homeScreenStateProvider.select((value) => value.endOfDay));
    return CustomMultiChildLayout(
      delegate: _PeriodLayoutDelegate(
        periods: widget.periods,
        startOfDay: startOfDay,
        endOfDay: endOfDay,
      ),
      children: widget.periods
          .map(
            (e) => LayoutId(
              id: e,
              child: TimeTablePeriodWidget(
                period: e,
                fontSize: widget.fontSize,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _PeriodLayoutDelegate extends MultiChildLayoutDelegate {
  final List<TimeTablePeriod> periods;
  final TimeOfDay startOfDay;
  final TimeOfDay endOfDay;

  _PeriodLayoutDelegate({
    required this.periods,
    required this.startOfDay,
    required this.endOfDay,
  });

  @override
  void performLayout(Size size) {
    for (List<List<TimeTablePeriod>> gridPart
        in periodsToTimeTableGrid(periods)) {
      /// We first calculate the offset of each child.
      double columnWidth = size.width / gridPart.length;

      /// height * (start - startOfDay) / (endOfDay - startOfDay) = yOffset
      double dateTimeToYOffset(DateTime dateTime) =>
          size.height *
          (dateTime.hour * 60 +
              dateTime.minute -
              startOfDay.hour * 60 -
              startOfDay.minute) /
          (endOfDay.hour * 60 +
              endOfDay.minute -
              startOfDay.hour * 60 -
              startOfDay.minute);
      for (int i = 0; i < gridPart.length; i++) {
        List<TimeTablePeriod> column = gridPart[i];
        for (TimeTablePeriod period in column) {
          positionChild(
            period,
            Offset(
              i * columnWidth,
              dateTimeToYOffset(period.start),
            ),
          );
        }
      }

      /// This calculates how many columns the period can expand into.
      /// 1 means it can't expand, 2 means it can expand into the next column, etc.
      int possibleWidthExpansion(TimeTablePeriod period, int column) {
        int expansion = 1;
        for (int i = column + 1; i < gridPart.length; i++) {
          if (gridPart[i].any((element) => element.collidesWith(period))) {
            return expansion;
          }
          expansion++;
        }
        return expansion;
      }

      for (int i = 0; i < gridPart.length; i++) {
        List<TimeTablePeriod> column = gridPart[i];
        for (TimeTablePeriod period in column) {
          layoutChild(
            period,
            BoxConstraints(
              minWidth: columnWidth,
              maxWidth: columnWidth * possibleWidthExpansion(period, i),
              minHeight: dateTimeToYOffset(period.end) -
                  dateTimeToYOffset(period.start),
              maxHeight: dateTimeToYOffset(period.end) -
                  dateTimeToYOffset(period.start),
            ),
          );
        }
      }
    }
  }

  @override
  bool shouldRelayout(_PeriodLayoutDelegate oldDelegate) {
    return !listEquals(oldDelegate.periods, periods) &&
        oldDelegate.startOfDay != startOfDay &&
        oldDelegate.endOfDay != endOfDay;
  }
}
