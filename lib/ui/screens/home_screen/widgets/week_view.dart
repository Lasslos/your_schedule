import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:your_schedule/core/api/models/helpers/timetable_week.dart';
import 'package:your_schedule/core/api/models/timetable_period.dart';
import 'package:your_schedule/core/api/providers/timetable_provider.dart';
import 'package:your_schedule/ui/screens/home_screen/home_screen_state_provider.dart';
import 'package:your_schedule/ui/screens/home_screen/widgets/period_layout.dart';
import 'package:your_schedule/util/date_utils.dart';

class WeekView extends ConsumerStatefulWidget {
  const WeekView({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _WeekViewState();
}

class _WeekViewState extends ConsumerState<WeekView> {
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
    var index = currentDate.difference(Week.now().startDate).inDays ~/ 7;
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
            next.normalized().difference(DateTime.now().normalized()).inDays ~/
                7,
            duration: const Duration(milliseconds: 300),
            curve: Curves.bounceInOut,
          );
        }
      },
    );

    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        var oldDate = ref.read(homeScreenStateProvider).currentDate;
        var durationRelativeToStartOfWeek =
            oldDate.difference(Week.fromDateTime(oldDate).startDate);
        currentDate = Week.now()
            .startDate
            .add(Duration(days: index * 7))
            .add(durationRelativeToStartOfWeek);
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
    Key? key,
  }) : super(key: key);


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    DateTime currentDate = DateTime.now().add(Duration(days: index * 7)).normalized();
    Week currentWeek = Week.fromDateTime(currentDate);
    List<List<TimeTablePeriod>?> days = List.generate(
      5,
      (index) => ref.watch(
        filteredTimeTablePeriodsFamily(
          currentWeek.startDate.add(Duration(days: index)),
        ),
      ),
    );
    if (days.any((element) => element == null)) {
      ref.read(timeTableProvider.notifier).fetchTimeTableWeek(currentWeek);
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 42,
          child: Row(
            children: [
              for (var i = 0; i < 5; i++)
                Flexible(
                  child: InkWell(
                    onTap: () {
                      var possibleNewDate =
                          currentWeek.startDate.add(Duration(days: i));
                      if (possibleNewDate
                          .isBefore(DateTime.now().normalized())) {
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
                        ..currentDate =
                            currentWeek.startDate.add(Duration(days: i))
                        ..switchView();
                    },
                    child: Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: DateFormat('E\n').format(
                            currentWeek.startDate.add(Duration(days: i)),
                          ),
                          style: Theme.of(context).textTheme.bodyText1,
                          children: [
                            TextSpan(
                              text: DateFormat("d. MMM").format(
                                  currentWeek.startDate.add(Duration(days: i))),
                              style: Theme.of(context).textTheme.caption,
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
          child: Row(
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
        )
      ],
    );
  }
}
