import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/core/api/models/timetable_period.dart';
import 'package:your_schedule/core/api/models/timetable_period_information_elements.dart';
import 'package:your_schedule/core/api/providers/timetable_provider.dart';
import 'package:your_schedule/filter/filter.dart';

class FilterScreen extends ConsumerStatefulWidget {
  const FilterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends ConsumerState<FilterScreen> {
  bool showSearch = false;
  String searchQuery = "";
  late FocusNode searchFocusNode;
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchFocusNode = FocusNode();
    searchController = TextEditingController();
    rebuildGridElements();
  }

  List<TimeTablePeriod> gridElements = [];

  void rebuildGridElements() {
    final filters = ref.read(filterItemsProvider);
    //Get all periods
    List<TimeTablePeriod> allPeriods =
        ref.read(timeTableProvider).weekData.values.fold<List<TimeTablePeriod>>(
      [],
      (previous, element) => previous
        ..addAll(
          element.days.values.fold<List<TimeTablePeriod>>(
            [],
            (previousValue, element) => previousValue..addAll(element.periods),
          ),
        ),
    );

    //Remove all duplicates by putting them into a HashSet and then converting it back to a list
    allPeriods = (HashSet<TimeTablePeriod>(
      equals: (a, b) => a.subject == b.subject,
      hashCode: (e) => e.subject.hashCode,
    )..addAll(allPeriods))
        .toList()
      ..sort(
        (a, b) => a.subject.name.compareTo(b.subject.name),
      );

    List<TimeTablePeriod> filteredPeriods = [];
    List<TimeTablePeriod> notFilteredPeriods = [];
    for (var period in allPeriods) {
      if (filters.contains(period.subject)) {
        filteredPeriods.add(period);
      } else {
        notFilteredPeriods.add(period);
      }
    }

    gridElements = [...notFilteredPeriods, ...filteredPeriods];
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(filterItemsProvider);
    final gridChildren = gridElements
        .map<Widget>(
          (e) => Padding(
            key: ValueKey(e),
            padding: const EdgeInsets.all(4.0),
            child: Selectable(
              selected: !filters.contains(e.subject),
              onChanged: (bool value) {
                if (value) {
                  ref.read(filterItemsProvider.notifier).removeItem(e.subject);
                } else {
                  ref.read(filterItemsProvider.notifier).addItem(e.subject);
                }
              },
              child: Center(
                child: FilterGridTile(
                  subject: e.subject,
                  teacher: e.teacher,
                  room: e.room,
                ),
              ),
            ),
          ),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: showSearch
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  showSearch = false;
                  searchFocusNode.unfocus();
                  rebuildGridElements();
                }),
              )
            : null,
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          child: !showSearch
              ? Row(
                  children: const [
                    Text('Deine Kurse'),
                    Spacer(),
                  ],
                )
              : Container(
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.12),
                  ),
                  padding: const EdgeInsets.only(left: 10),
                  child: Center(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          //Only rebuilt if there was a change other than adding another character
                          //Otherwise there are no elements remove that must be added by calling rebuildGridElements
                          if (!value.startsWith(searchQuery)) {
                            rebuildGridElements();
                          }
                          searchQuery = value;
                          gridElements = gridElements
                              .where(
                                (element) =>
                                    element.subject.name
                                        .toLowerCase()
                                        .contains(value.toLowerCase()) ||
                                    element.subject.longName
                                        .toLowerCase()
                                        .contains(value.toLowerCase()) ||
                                    element.teacher.name
                                        .toLowerCase()
                                        .contains(value.toLowerCase()) ||
                                    element.teacher.longName
                                        .toLowerCase()
                                        .contains(value.toLowerCase()) ||
                                    element.room.name
                                        .toLowerCase()
                                        .contains(value.toLowerCase()) ||
                                    element.room.longName
                                        .toLowerCase()
                                        .contains(value.toLowerCase()),
                              )
                              .toList();
                        });
                      },
                      controller: searchController,
                      focusNode: searchFocusNode,
                      textAlignVertical: TextAlignVertical.center,
                      autofocus: true,
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          iconSize: 18,
                          icon: const Icon(
                            Icons.close,
                          ),
                          onPressed: () {
                            setState(() {
                              searchController.clear();
                              rebuildGridElements();
                            });
                          },
                        ),
                        hintText: 'Suchen',
                      ),
                    ),
                  ),
                ),
        ),
        actions: [
          if (!showSearch)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  showSearch = !showSearch;
                });
              },
            ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 4,
        children: gridChildren,
      ),
    );
  }
}

class Selectable extends StatelessWidget {
  final Function(bool value) onChanged;
  final bool selected;
  final Widget child;

  const Selectable({
    required this.onChanged,
    required this.selected,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(!selected);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.onSurface.withOpacity(0.12)
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              scale: selected ? 0.75 : 1,
              child: child,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: AnimatedCrossFade(
                  duration: const Duration(milliseconds: 150),
                  crossFadeState: selected
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: CircleAvatar(
                    radius: 10,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  secondChild: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.12),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterGridTile extends StatelessWidget {
  const FilterGridTile({
    required this.subject,
    required this.teacher,
    required this.room,
    super.key,
  });

  final TimeTablePeriodSubjectInformation subject;
  final TimeTablePeriodTeacherInformation teacher;
  final TimeTablePeriodRoomInformation room;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: SizedBox.expand(
        child: GridTile(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                subject.name,
                textAlign: TextAlign.center,
                overflow: TextOverflow.fade,
                maxLines: 1,
              ),
              Text(
                teacher.name,
                textAlign: TextAlign.center,
                overflow: TextOverflow.fade,
                maxLines: 1,
              ),
              Text(
                room.name,
                textAlign: TextAlign.center,
                overflow: TextOverflow.fade,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
