import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:your_schedule/core/api/models/helpers/timetable_week.dart';
import 'package:your_schedule/core/api/models/timetable_period.dart';
import 'package:your_schedule/core/api/providers/timetable_provider.dart';
import 'package:your_schedule/ui/screens/home_screen/home_screen_state_provider.dart';
import 'package:your_schedule/ui/screens/home_screen/widgets/period_layout.dart';
import 'package:your_schedule/ui/screens/home_screen/widgets/time_indicator.dart';
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
            next.difference(currentDate).inDays,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        }
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

    return Column(
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
                  style: Theme.of(context).textTheme.bodyText1,
                  children: [
                    TextSpan(
                      text: DateFormat("d. MMMM").format(currentDate),
                      style: Theme.of(context).textTheme.caption,
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
                periods: periods,
              ),
              if (index == 0) const TimeIndicator(),
            ],
          ),
        ),
      ],
    );
  }
}
