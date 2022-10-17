import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/core/api/models/timetable_period.dart';
import 'package:your_schedule/ui/screens/home_screen/home_screen_state_provider.dart';
import 'package:your_schedule/ui/screens/home_screen/widgets/timetable_period_widget.dart';
import 'package:your_schedule/util/logger.dart';

///Warning: Spaghetti code. I've tried to explain it as good as possible.

class _PeriodLayoutList {
  ///This map works the following:
  ///The map itself contains a DateTime, where a period is starting or a part of it is starting.
  ///The list contains set periods. Let's assume there is one period ending
  ///while another doesnt. In that case, the one that ends defines the end of duration,
  ///and the one that doesnt is contained in both this and the following list.
  Map<DateTime, List<TimeTablePeriod>> partsMap = {};

  _PeriodLayoutList._(this.partsMap);

  factory _PeriodLayoutList.fromPeriods(
    List<TimeTablePeriod> periods,
    DateTime start,
  ) {
    periods = [...periods]..sort((a, b) => a.start.compareTo(b.start));
    var result = <DateTime, List<TimeTablePeriod>>{start: []};
    var sortedListOfKeys = [start];

    for (TimeTablePeriod period in periods) {
      if (!result.containsKey(period.start)) {
        ///This means that there is currently no period starting at this time.
        ///There might be a period going through this time though.
        ///So: We copy the last entry in result into the new starting time.
        ///Also: Cannot use add because it would be the same list.
        DateTime lastKeyBeforePeriodStart =
            sortedListOfKeys.reduce((value, element) {
          assert(
            value.isBefore(period.start),
            "The list of starts' smallest element is not before the period's start.",
          );
          if (!element.isBefore(period.start)) {
            return value;
          }
          if (element.isAfter(value)) {
            return element;
          }
          return value;
        });

        result[period.start] = [...result[lastKeyBeforePeriodStart]!, period];
        sortedListOfKeys.add(period.start);
      } else {
        ///There is a period starting at this time.
        ///We add it to the list of periods starting at this time.
        result[period.start]!.add(period);
      }

      if (sortedListOfKeys.indexOf(period.start) + 1 ==
          sortedListOfKeys.length) {
        ///This means that the period is the last one.
        ///We add an empty list to mark a change in classes
        result[period.end] = [];
        sortedListOfKeys.add(period.end);
        continue;
      }
      for (int i = sortedListOfKeys.indexOf(period.start) + 1; true; i++) {
        var nextBlockBeginning = sortedListOfKeys[i];
        if (nextBlockBeginning.isBefore(period.end)) {
          result[nextBlockBeginning]!.add(period);
          continue;
        } else if (nextBlockBeginning.isAtSameMomentAs(period.end)) {
          break;
        } else if (nextBlockBeginning.isAfter(period.end)) {
          ///We have to add a new entry to the map.
          result[period.end] = [...result[nextBlockBeginning]!];
          sortedListOfKeys.insert(i, period.end);
          break;
        }
      }
    }
    return _PeriodLayoutList._(result);
  }

  void addAll(List<TimeTablePeriod> periods) {
    var sortedListOfKeys = partsMap.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    for (var period in periods) {
      if (!partsMap.containsKey(period.start)) {
        var lastKeyBeforePeriodStart =
            sortedListOfKeys.reduce((value, element) {
              assert(
            value.isBefore(period.start),
            "The list of starts' smallest element is not before the period's start.",
          );
          if (!element.isBefore(period.start)) {
            return value;
          }
          if (element.isAfter(value)) {
            return element;
          }
          return value;
        });

        partsMap[period.start] = [
          ...partsMap[lastKeyBeforePeriodStart]!,
          period,
        ];
        sortedListOfKeys.insert(
          sortedListOfKeys.indexOf(lastKeyBeforePeriodStart) + 1,
          period.start,
        );
      } else {
        ///There is a period starting at this time.
        ///We add it to the list of periods starting at this time.
        partsMap[period.start]!.add(period);
      }

      if (sortedListOfKeys.indexOf(period.start) + 1 >=
          sortedListOfKeys.length) {
        ///This means that the period is the last one.
        ///We add an empty list to mark a change in classes
        partsMap[period.end] = [];
        sortedListOfKeys.add(period.end);
        continue;
      }
      for (int i = sortedListOfKeys.indexOf(period.start) + 1; true; i++) {
        var nextBlockBeginning = sortedListOfKeys[i];
        if (nextBlockBeginning.isBefore(period.end)) {
          partsMap[nextBlockBeginning]!.add(period);
          continue;
        } else if (nextBlockBeginning.isAtSameMomentAs(period.end)) {
          break;
        } else if (nextBlockBeginning.isAfter(period.end)) {
          ///We have to add a new entry to the map.
          partsMap[period.end] = [...partsMap[nextBlockBeginning]!];
          sortedListOfKeys.insert(i, period.end);
          break;
        }
      }
    }
  }
}

class PeriodLayout extends ConsumerStatefulWidget {
  final List<TimeTablePeriod> periods;

  const PeriodLayout({required this.periods, super.key});

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
    if (widget.periods.isEmpty) {
      return const SizedBox();
    }

    var startOfDay =
        ref.watch(homeScreenStateProvider.select((value) => value.startOfDay));
    var endOfDay =
        ref.watch(homeScreenStateProvider.select((value) => value.endOfDay));
    var startOfDayDateTime = DateTime(
      widget.periods.first.start.year,
      widget.periods.first.start.month,
      widget.periods.first.start.day,
      startOfDay.hour,
      startOfDay.minute,
    );
    var endOfDayDateTime = DateTime(
      widget.periods.first.start.year,
      widget.periods.first.start.month,
      widget.periods.first.start.day,
      endOfDay.hour,
      endOfDay.minute,
    );

    return CustomMultiChildLayout(
      delegate: _PeriodLayoutDelegate(
        startOfDay: startOfDayDateTime,
        endOfDay: endOfDayDateTime,
        periods: widget.periods,
      ),
      children: widget.periods
          .map(
            (e) => LayoutId(id: e, child: TimeTablePeriodWidget(period: e)),
          )
          .toList(),
    );
  }
}

class _PeriodLayoutDelegate extends MultiChildLayoutDelegate {
  final List<TimeTablePeriod> periods;
  final DateTime startOfDay;
  final DateTime endOfDay;

  _PeriodLayoutDelegate({
    required List<TimeTablePeriod> periods,
    required this.startOfDay,
    required this.endOfDay,
  }) : periods = List.unmodifiable(
    [...periods]..sort((a, b) => a.start.compareTo(b.start)),
        );

  @override
  void performLayout(Size size) {
    ///The concept for this layout is the following:
    ///1: Construct a periodLayoutList. This sorts them by different blocks where there is a new
    ///block introduced whenever the active periods change.
    ///
    ///2: Determine how much width every individual period should have and where it should be placed on the x-axis.
    ///For this, we start with the lists with the most elements as they will be the ones with the least space.
    ///Then, we iterate through all the other lists step by step and and gradually define the width of the periods.
    ///This bases on the assumption that the biggest lists are always the best indicator for where to put the widgets.
    ///This is the case, because if there were situations where it is important to place widgets not like we placed them by going by the biggest lists,
    ///this would mean that in that spot where this is important is no space and therefore a bigger list, which is a contradiction.
    ///
    ///3: Determine how much height every individual period should have and where it should be placed on the y-axis.
    ///This is trivial.
    ///4: Place the periods.

    List<TimeTablePeriod> regularPeriods = periods
        .where((element) => element.periodStatus == PeriodStatus.regular)
        .toList();
    List<TimeTablePeriod> nonRegularPeriods = periods
        .where((element) => element.periodStatus != PeriodStatus.regular)
        .toList();

    ///We have to do the separation to make sure regular periods appear first.
    _PeriodLayoutList periodLayoutList = _PeriodLayoutList.fromPeriods(
      regularPeriods,
      startOfDay,
    )..addAll(nonRegularPeriods);

    ///Create a list we can iterate through
    var partsListsEntries = periodLayoutList.partsMap.entries.toList();
    Map<int, int> indexToLength = {};
    for (int i = 0; i < partsListsEntries.length; i++) {
      indexToLength[i] = partsListsEntries[i].value.length;
    }
    var temp = indexToLength.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    var indexToLengthList = temp.map((e) => e.key).toList();

    Map<TimeTablePeriod, MapEntry<double, double>> periodToXAndWidth = {};
    outer:
    for (int i = 0; i < indexToLengthList.length; i++) {
      var index = indexToLengthList[i];
      var partsList = partsListsEntries[index].value;
      if (partsList.isEmpty) {
        continue outer;
      }

      ///Now that we have a list of all the parts in this row, we can go through them and determine their width.
      ///We first need to go through and create lists of adjacent periods that are all not determined and add Lists with one Element which are determined.
      List<List<TimeTablePeriod>> adjacentPeriods = [[]];
      List<MapEntry<double, double>> adjacentPeriodsXAndWidth = [
        const MapEntry(0, -1)
      ];
      for (TimeTablePeriod period in partsList) {
        if (periodToXAndWidth.containsKey(period)) {
          ///This means that there is a determined period here.
          ///So we need to do the following:
          ///End the current list and start a new one, only with this period.
          ///Then, add another empty list.
          var xAndWidth = periodToXAndWidth[period]!;

          if (adjacentPeriods.length == 1 && adjacentPeriods.first.isEmpty) {
            ///In this case there is a determined period at the beginning of the list.
            adjacentPeriods.clear();
            adjacentPeriodsXAndWidth.clear();
            adjacentPeriods.add([period]);
            adjacentPeriodsXAndWidth.add(xAndWidth);
          } else {
            adjacentPeriods.add([period]);
            var lastInPeriodsXAndWidth = adjacentPeriodsXAndWidth.last;
            adjacentPeriodsXAndWidth
              ..last = MapEntry(
                lastInPeriodsXAndWidth.key,
                xAndWidth.key - lastInPeriodsXAndWidth.key,
              )
              ..add(xAndWidth);
          }

          adjacentPeriods.add([]);
          adjacentPeriodsXAndWidth.add(
            MapEntry(xAndWidth.key + xAndWidth.value, -1),
          );
          continue;
        } else {
          adjacentPeriods.last.add(period);
        }
      }

      ///Now we need to process the very last element if it doesnt have a width yet.
      if (adjacentPeriodsXAndWidth.last.value == -1) {
        adjacentPeriodsXAndWidth.last = MapEntry(
          adjacentPeriodsXAndWidth.last.key,
          size.width - adjacentPeriodsXAndWidth.last.key,
        );
      }

      ///Now: We have a list with periods that are either predetermined or we can calculate their width.
      ///We will do this and save this to the map.
      for (int i = 0; i < adjacentPeriods.length; i++) {
        var adjacentPeriodsList = adjacentPeriods[i];
        var adjacentPeriodsXAndWidthEntry = adjacentPeriodsXAndWidth[i];
        var width =
            adjacentPeriodsXAndWidthEntry.value / adjacentPeriodsList.length;
        var x = adjacentPeriodsXAndWidthEntry.key;
        for (TimeTablePeriod period in adjacentPeriodsList) {
          periodToXAndWidth[period] = MapEntry(x, width);
          x += width;
        }
      }

      ///Done with step one!
    }

    ///Alright... now that I have cooked spagetti code. Let's do the y-axis.
    ///As said above, this is trivial. Isn't that great?

    int totalMinutes = endOfDay.difference(startOfDay).inMinutes;
    Map<TimeTablePeriod, MapEntry<double, double>> periodToYAndHeight = {};
    for (TimeTablePeriod period in periods) {
      int startMinutes = period.start.difference(startOfDay).inMinutes;
      double y = startMinutes / totalMinutes * size.height;

      int durationInMinutes = period.end.difference(period.start).inMinutes;
      double height = durationInMinutes / totalMinutes * size.height;
      periodToYAndHeight[period] = MapEntry(y, height);
    }

    ///DONE!
    ///Now lets position!
    for (TimeTablePeriod period in periods) {
      if (!periodToXAndWidth.containsKey(period)) {
        getLogger().d("Period not found in periodToXAndWidth: ${period.id}");
      }
      var xAndWidth = periodToXAndWidth[period]!;
      var yAndHeight = periodToYAndHeight[period]!;
      layoutChild(
        period,
        BoxConstraints.tightFor(
          width: xAndWidth.value,
          height: yAndHeight.value,
        ),
      );
      positionChild(period, Offset(xAndWidth.key, yAndHeight.key));
    }
  }

  @override
  bool shouldRelayout(_PeriodLayoutDelegate oldDelegate) {
    return !listEquals(oldDelegate.periods, periods) &&
        oldDelegate.startOfDay != startOfDay &&
        oldDelegate.endOfDay != endOfDay;
  }
}
