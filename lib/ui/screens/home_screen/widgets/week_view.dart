import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:your_schedule/core/session.dart';
import 'package:your_schedule/core/untis.dart';
import 'package:your_schedule/ui/screens/home_screen/home_screen_state_provider.dart';
import 'package:your_schedule/ui/screens/home_screen/widgets/period_layout.dart';
import 'package:your_schedule/ui/screens/home_screen/widgets/time_indicator.dart';
import 'package:your_schedule/utils.dart';

class WeekView extends ConsumerStatefulWidget {
  const WeekView({super.key});

  @override
  ConsumerState createState() => _WeekViewState();
}

class _WeekViewState extends ConsumerState<WeekView> {
  late PageController _pageController;
  late Date currentDate;

  @override
  void initState() {
    super.initState();
    currentDate = ref.read(homeScreenStateProvider).currentDate;
    var index = currentDate.differenceInDays(Week.now().startDate) ~/ 7;
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
        var normalizedCurrentDate = Week.fromDate(currentDate).startDate;
        var normalizedNext = Week.fromDate(next).startDate;
        if (normalizedCurrentDate != normalizedNext) {
          _pageController.animateToPage(
            Week.now().startDate.differenceInDays(normalizedNext) ~/ 7,
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
        var oldDate = ref.read(homeScreenStateProvider).currentDate;
        var daysRelativeToStartOfWeek = oldDate.differenceInDays(Week.fromDate(oldDate).startDate);
        currentDate = Week.now()
            .startDate.addDays(index * 7 + daysRelativeToStartOfWeek);
        ref.read(homeScreenStateProvider.notifier).currentDate = currentDate;
      },
      itemBuilder: (BuildContext context, int index) {
        return _Page(index: index);
      },
    );
  }
}

class _Page extends ConsumerWidget {
  final int index;

  const _Page({
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Date currentDate = Date.now().addWeeks(index);
    Week currentWeek = Week.fromDate(currentDate);
    List<List<TimeTablePeriod>?> days = [];

    var timeTableAsync = ref.watch(timeTableProvider(Week.fromDate(currentDate)));
    var filters = ref.watch(filtersProvider);

    if (timeTableAsync.hasError) {
      return Center(child: Text(timeTableAsync.error.toString()));
    } else if (timeTableAsync.isLoading) {
      //Note: Week starts on Saturday to show next week after Friday
      for (var i = 2; i < 7; i++) {
        days.add([]);
      }
    } else {
      var timeTable = timeTableAsync.requireValue;
      //Note: Week starts on Saturday to show next week after Friday
      for (var i = 2; i < 7; i++) {
        days.add(
          timeTable[currentWeek.startDate.addDays(i)]!.where(
            (element) {
              if (element.subject == null) {
                return true;
              }
              return filters.contains(element.subject!.id);
            },
          ).toList(),
        );
      }
    }

    return Column(
      children: [
        SizedBox(
          height: 42,
          child: Row(
            children: [
              //Note: Week starts on Saturday to show next week after Friday
              for (var i = 2; i < 7; i++)
                Flexible(
                  child: InkWell(
                    onTap: () {
                      var possibleNewDate = currentWeek.startDate.addDays(i);
                      if (possibleNewDate.isBefore(
                        Date.now(),
                      )) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Das liegt in der Vergangenheit!',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            action: SnackBarAction(
                              label: 'OK',
                              textColor: Colors.white,
                              onPressed: () {
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                              },
                            ),
                          ),
                        );
                        return;
                      }
                      ref.read(homeScreenStateProvider.notifier)
                        ..currentDate = possibleNewDate
                        ..switchView();
                    },
                    child: Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: currentWeek.startDate.addDays(i).format(DateFormat('E\n')),
                          style: Theme.of(context).textTheme.bodyLarge,
                          children: [
                            TextSpan(
                              text: currentWeek.startDate.addDays(i).format(DateFormat("d. MMM")),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Row(
                children: List.generate(
                  9,
                  (index) {
                    if (index % 2 == 1) {
                      //Separator
                      return const SizedBox(
                        width: 2,
                      );
                    }
                    return Flexible(
                      fit: FlexFit.tight,
                      child: PeriodLayout(
                        fontSize: 12,
                        periods: days[index ~/ 2]!,
                      ),
                    );
                  },
                ),
              ),
              if (index == 0) const TimeIndicator(),
            ],
          ),
        ),
      ],
    );
  }
}
