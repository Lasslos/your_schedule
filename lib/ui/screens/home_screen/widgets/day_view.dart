import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:your_schedule/core/session.dart';
import 'package:your_schedule/core/untis.dart';
import 'package:your_schedule/ui/screens/home_screen/home_screen_state_provider.dart';
import 'package:your_schedule/ui/screens/home_screen/widgets/period_layout.dart';
import 'package:your_schedule/ui/screens/home_screen/widgets/time_indicator.dart';
import 'package:your_schedule/utils.dart';

class DayView extends ConsumerStatefulWidget {
  const DayView({super.key});

  @override
  ConsumerState<DayView> createState() => _DayViewState();
}

class _DayViewState extends ConsumerState<DayView> {
  late PageController _pageController;
  late Date currentDate;

  @override
  void initState() {
    super.initState();
    currentDate = ref.read(homeScreenStateProvider).currentDate;
    var index = currentDate.differenceInDays(Date.now());
    _pageController = PageController(initialPage: index);

    //Pre-load next and previous week
    ref
      ..read(
        timeTableProvider(
          Week.fromDate(currentDate.addWeeks(1)),
        ),
      )
      ..read(
        timeTableProvider(
          Week.fromDate(currentDate.subtractWeeks(1)),
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
    ref.listen<Date>(
      homeScreenStateProvider.select((value) => value.currentDate),
      (previous, next) {
        if (currentDate != next) {
          _pageController.animateToPage(
            next.differenceInDays(currentDate),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        }

        //Pre-load next and previous week
        ref
          ..read(
            timeTableProvider(
              Week.fromDate(currentDate.addWeeks(1)),
            ),
          )
          ..read(
            timeTableProvider(
              Week.fromDate(
                currentDate.subtractWeeks(1),
              ),
            ),
          );
      },
    );

    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        currentDate = Date.now().addDays(index);
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

  const _Page({required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Date currentDate = Date.now().addDays(index);

    var timeTableAsync = ref.watch(timeTableProvider(Week.fromDate(currentDate)));
    List<TimeTablePeriod> timeTable;
    var filters = ref.watch(filtersProvider);

    if (timeTableAsync.hasError) {
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
                    text: currentDate.format(DateFormat("EEEE\n")),
                    style: Theme.of(context).textTheme.bodyLarge,
                    children: [
                      TextSpan(
                        text: currentDate.format(DateFormat("d. MMMM")),
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
