import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:your_schedule/core/api/models/helpers/timetable_week.dart';
import 'package:your_schedule/core/api/models/timetable_period.dart';
import 'package:your_schedule/core/api/providers/timetable_provider.dart';
import 'package:your_schedule/ui/screens/home_screen/home_screen_state_provider.dart';
import 'package:your_schedule/ui/screens/home_screen/widgets/period_layout.dart';
import 'package:your_schedule/util/date_utils.dart';

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
            next.normalized().difference(DateTime.now().normalized()).inDays,
            duration: const Duration(milliseconds: 300),
            curve: Curves.bounceInOut,
          );
        }
      },
    );

    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        currentDate = DateTime.now().add(Duration(days: index));
        ref.read(homeScreenStateProvider.notifier).currentDate = currentDate;
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
    DateTime currentDate = DateTime.now().add(Duration(days: index));
    Week currentWeek = Week.fromDateTime(currentDate);
    List<TimeTablePeriod>? periods =
        ref.watch(filteredTimeTablePeriodsFamily(currentDate));
    if (periods == null) {
      ref.read(timeTableProvider.notifier).fetchTimeTableWeek(currentWeek);
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    String weekDay = intl.DateFormat.EEEE().format(currentDate);
    String date = intl.DateFormat.MMMd().format(currentDate);

    return Column(
      children: [
        SizedBox(
          height: 42,
          child: Center(
            child: Text(
              "$weekDay\n$date",
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          child: PeriodLayout(
            periods: periods,
          ),
        ),
      ],
    );
  }
}
