import 'package:dart_extensions_methods/dart_extension_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:your_schedule/core/session/filters.dart';
import 'package:your_schedule/core/session/session.dart';
import 'package:your_schedule/core/session/timetable.dart';
import 'package:your_schedule/core/untis/untis_api.dart';
import 'package:your_schedule/util/logger.dart';
import 'package:your_schedule/util/week.dart';

class FilterScreen extends ConsumerStatefulWidget {
  const FilterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends ConsumerState<FilterScreen> {
  late FocusNode searchFocusNode;
  late TextEditingController searchController;
  bool showSearch = false;
  String searchQuery = "";

  late List<int> periods;

  @override
  void initState() {
    super.initState();
    searchFocusNode = FocusNode();
    searchController = TextEditingController();
    periods = ref.read(selectedSessionProvider).userData!.subjects.keys.toList();
    _sortPeriods();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      selectedSessionProvider.select((value) => value.userData!.subjects.keys.toList()),
      (previous, next) {
        setState(() {
          periods = next;
          _filterPeriods();
          _sortPeriods();
        });
      },
    );

    var timeTableAsync = ref.watch(timeTableProvider(Week.now()));

    if (ref.watch(selectedSessionProvider.select((value) => value.userData!.subjects)).isEmpty
        || timeTableAsync.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (timeTableAsync.hasError) {
      Sentry.captureException(timeTableAsync.error,
          stackTrace: timeTableAsync.stackTrace);
      getLogger().e(
        "Error while loading timetable",
        timeTableAsync.error,
        timeTableAsync.stackTrace,
      );
      return const Scaffold(
        body: Center(
          child: Text('Fehler beim Laden des Stundenplans'),
        ),
      );
    }

    var timeTable = timeTableAsync.requireValue.values.fold(<TimeTablePeriod>[], (previousValue, element) => previousValue..addAll(element));

    var filters = ref.watch(filtersProvider);

    var subjects = ref.watch(selectedSessionProvider.select((value) => value.userData!.subjects));
    var teachers = ref.watch(selectedSessionProvider.select((value) => value.userData!.teachers));
    var rooms = ref.watch(selectedSessionProvider.select((value) => value.userData!.rooms));

    final gridChildren = periods
      .map<Widget>(
        (e) {
          TimeTablePeriod? examplePeriod = timeTable.firstWhereOrNull((element) => element.subject?.id == e);
          Subject? subject = subjects[e];
          Teacher? teacher = teachers[examplePeriod?.teacher?.id];
          Room? room = rooms[examplePeriod?.room?.id];

          return Padding(
            key: ValueKey(e),
            padding: const EdgeInsets.all(4.0),
            child: Selectable(
              selected: filters.contains(e),
            onChanged: (bool value) {
              if (value) {
                ref.read(filtersProvider.notifier).add(e);
              } else {
                ref.read(filtersProvider.notifier).remove(e);
              }
            },
            child: Center(
              child: FilterGridTile(
                subject: subject?.name ?? 'Fach $e',
                teacher: teacher?.shortName ?? 'Lehrer $e',
                  room: room?.name ?? 'Raum $e',
                ),
              ),
            ),
          );
        },
    ).toList();

    return Scaffold(
      appBar: AppBar(
        leading: showSearch
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    showSearch = false;
                    searchQuery = "";
                    searchFocusNode.unfocus();
                    searchController.clear();
                  });
                },
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
                          if (!value.startsWith(searchQuery)) {
                            periods = ref.read(selectedSessionProvider.select((value) => value.userData!.subjects.keys.toList()));
                            searchQuery = value;
                            _filterPeriods();
                            _sortPeriods();
                          } else {
                            searchQuery = value;
                            _filterPeriods();
                          }
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
                              searchQuery = "";
                              periods = ref.read(selectedSessionProvider.select((value) => value.userData!.subjects.keys.toList()));
                              _filterPeriods();
                              _sortPeriods();
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
                  showSearch = true;
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

  void _sortPeriods() {
    final filters = ref.read(selectedSessionProvider.select((value) => value.userData!.subjects.keys.toList()));

    periods.sort((a, b) {
      if (filters.contains(a) && !filters.contains(b)) {
        return 1;
      } else if (!filters.contains(a) && filters.contains(b)) {
        return -1;
      } else {
        final subjects = ref.read(selectedSessionProvider.select((value) => value.userData!.subjects));
        return subjects[a]?.name.compareTo(subjects[b]?.name ?? '') ?? 0;
      }
    });
  }

  void _filterPeriods() {
    var timeTableAsync = ref.watch(timeTableProvider(Week.now()));
    var timeTable = timeTableAsync.requireValue.values.fold(<TimeTablePeriod>[], (previousValue, element) => previousValue..addAll(element));
    var subjects = ref.watch(selectedSessionProvider.select((value) => value.userData!.subjects));
    var teachers = ref.watch(selectedSessionProvider.select((value) => value.userData!.teachers));
    var rooms = ref.watch(selectedSessionProvider.select((value) => value.userData!.rooms));

    periods = periods
        .where(
          (e) {
            var examplePeriod = timeTable.firstWhereOrNull((element) => element.subject?.id == e);
            var subject = subjects[e];
            var teacher = teachers[examplePeriod?.teacher?.id];
            var room = rooms[examplePeriod?.room?.id];

            var result = false;
            if (subject != null) {
              result = subject.name.toLowerCase().contains(searchQuery.toLowerCase()) || result;
              result = subject.longName.toLowerCase().contains(searchQuery.toLowerCase()) || result;
            }
            if (teacher != null) {
              result = teacher.firstName.toLowerCase().contains(searchQuery.toLowerCase()) || result;
              result = teacher.lastName.toLowerCase().contains(searchQuery.toLowerCase()) || result;
              result = teacher.shortName.toLowerCase().contains(searchQuery.toLowerCase()) || result;
            }
            if (room != null) {
              result = room.name.toLowerCase().contains(searchQuery.toLowerCase()) || result;
              result = room.longName.toLowerCase().contains(searchQuery.toLowerCase()) || result;
            }
            return result;
          }
        )
        .toList();
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

  final String subject;
  final String teacher;
  final String room;

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
                subject,
                textAlign: TextAlign.center,
                overflow: TextOverflow.fade,
                maxLines: 1,
              ),
              Text(
                teacher,
                textAlign: TextAlign.center,
                overflow: TextOverflow.fade,
                maxLines: 1,
              ),
              Text(
                room,
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
