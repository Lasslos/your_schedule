import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/core/api/models/timetable_period.dart';
import 'package:your_schedule/core/api/models/timetable_period_information_elements.dart';
import 'package:your_schedule/core/api/providers/timetable_provider.dart';
import 'package:your_schedule/filter/filter.dart';
import 'package:your_schedule/ui/screens/home_screen/home_screen.dart';

class FilterSetupScreen extends ConsumerStatefulWidget {
  const FilterSetupScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _FilterSetupScreenState();
}

class _FilterSetupScreenState extends ConsumerState<FilterSetupScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    List<TimeTablePeriodSubjectInformation> currentFilters =
        ref.read(filterItemsProvider);
    List<TimeTablePeriod> possibleFilters = ref
        .read(timeTableProvider)
        .weekData
        .values
        .fold<List<TimeTablePeriod>>(
          [],
          (previous, element) => previous
            ..addAll(
              element.days.values.fold<List<TimeTablePeriod>>(
                [],
                (previousValue, element) =>
                    previousValue..addAll(element.periods),
              ),
            ),
        )
        .where(
          (element) =>
              !currentFilters.any((filter) => element.subject == filter),
        )
        .toList();

    possibleFilters = (HashSet<TimeTablePeriod>(
      equals: (a, b) => a.subject == b.subject,
      hashCode: (e) => e.subject.hashCode,
    )..addAll(possibleFilters))
        .toList()
      ..sort(
        (a, b) => a.subject.name.compareTo(b.subject.name),
      );

    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        children: possibleFilters.map((e) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Bist du in diesem Kurs?",
                        style: textTheme.headline6,
                      ),
                      const SizedBox(height: 16),
                      Text(e.subject.name, style: textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      Text(e.teacher.longName, style: textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      Text(e.room.name, style: textTheme.bodyLarge),
                      const SizedBox(height: 16),
                      ToggleButtons(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        onPressed: (index) {
                          if (index == 1) {
                            ref
                                .read(filterItemsProvider.notifier)
                                .addItem(e.subject);
                          }
                          _currentPage++;
                          if (_currentPage >= possibleFilters.length) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const HomeScreen();
                                },
                              ),
                            );
                          } else {
                            _controller.animateToPage(
                              _currentPage,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        isSelected: const [false, false],
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              "Ja",
                              style: textTheme.headline6?.copyWith(
                                color: Colors.green,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              "Nein",
                              style: textTheme.headline6?.copyWith(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
