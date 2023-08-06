import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:your_schedule/core/session/filters.dart';
import 'package:your_schedule/core/session/timetable.dart';
import 'package:your_schedule/core/untis/models/timetable/timetable_period.dart';
import 'package:your_schedule/ui/screens/home_screen/home_screen_state_provider.dart';
import 'package:your_schedule/ui/screens/home_screen/widgets/period_layout.dart';
import 'package:your_schedule/ui/screens/home_screen/widgets/time_indicator.dart';
import 'package:your_schedule/util/date_utils.dart';
import 'package:your_schedule/util/logger.dart';
import 'package:your_schedule/util/week.dart';

class DayView extends ConsumerStatefulWidget {
  const DayView({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<DayView> createState() => _DayViewState();
}

class _DayViewState extends ConsumerState<DayView> {
  late PageController _pageController;
  late DateTime _currentDate;

  DateTime get currentDate => _currentDate;

  set currentDate(DateTime value) {
    _currentDate = value.normalized();
  }

  @override
  void initState() {
    super.initState();
    currentDate = ref.read(homeScreenStateProvider).currentDate;
    var index = currentDate.difference(DateTime.now().normalized()).inDays;
    _pageController = PageController(initialPage: index);

    //Pre-load next and previous week
    ref
      ..read(
        timeTableProvider(
          Week.fromDateTime(currentDate.add(const Duration(days: 7))),
        ),
      )
      ..read(
        timeTableProvider(
          Week.fromDateTime(currentDate.subtract(const Duration(days: 7))),
        ),
      );
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<DateTime>(
      homeScreenStateProvider.select((value) => value.currentDate),
      (previous, next) {
        if (currentDate != next) {
          _pageController.animateToPage(
            next.difference(currentDate).inDays,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        }

        //Pre-load next and previous week
        ref
          ..read(
            timeTableProvider(
              Week.fromDateTime(currentDate.add(const Duration(days: 7))),
            ),
          )
          ..read(
            timeTableProvider(
              Week.fromDateTime(
                currentDate.subtract(const Duration(days: 7)),
              ),
            ),
          );
      },
    );

    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        currentDate = DateTime.now().add(Duration(days: index));
        if (currentDate != ref.read(homeScreenStateProvider).currentDate) {
          ref.read(homeScreenStateProvider.notifier).currentDate = currentDate;
        }
      },
      itemBuilder: (BuildContext context, int index) => _Page(index: index),
    );
  }
}

class _Page extends ConsumerWidget {
  final int index;

  const _Page({
    required this.index,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    DateTime currentDate =
        DateTime.now().add(Duration(days: index)).normalized();

    var timeTableAsync =
        ref.watch(timeTableProvider(Week.fromDateTime(currentDate)));
    List<TimeTablePeriod> timeTable;
    var filters = ref.watch(filtersProvider);

    if (timeTableAsync.hasError) {
      Sentry.captureException(
        timeTableAsync.error,
        stackTrace: timeTableAsync.stackTrace,
      );
      getLogger().e("Error while loading timetable", error: timeTableAsync.error, stackTrace: timeTableAsync.stackTrace);
      return Center(child: Text(timeTableAsync.error.toString()));
    } else if (timeTableAsync.isLoading) {
      timeTable = [];
    } else {
      timeTable = timeTableAsync.requireValue[currentDate]!;
    }

    return Center(
      child: Column(
        children: [
          SizedBox(
            height: 42,
            child: InkWell(
              onTap: () {
                ref.read(homeScreenStateProvider.notifier).switchView();
              },
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: DateFormat('EEEE\n').format(currentDate),
                    style: Theme.of(context).textTheme.bodyLarge,
                    children: [
                      TextSpan(
                        text: DateFormat("d. MMMM").format(currentDate),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                PeriodLayout(
                  fontSize: 12,
                  periods: timeTable
                      .where(
                        (element) =>
                            element.subject == null ||
                            filters.contains(element.subject!.id),
                      )
                      .toList(),
                ),
                if (index == 0) const TimeIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
