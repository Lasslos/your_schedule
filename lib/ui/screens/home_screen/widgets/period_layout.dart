import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/core/session/session.dart';
import 'package:your_schedule/core/untis/untis_api.dart';
import 'package:your_schedule/ui/screens/home_screen/widgets/timetable_period_widget.dart';

/// Ein Widget, das die Stunden in einer Tagesansicht anzeigt.
/// Der Algorithmus ist wie folgt:

// 1. Das Layout ist ein unbegrenztes Raster.
// 2. Die Stunden können in Stundenblöcke unterteilt werden. Diese Blöcke starten im-
// mer genau dann, wenn die Startzeit der nächsten Stunde nach der Endzeit der vorherigen
// Stunde liegt. Dann sind sie in der Anzeige völlig unabhängig.
// 3. Jede Stunde ist eine Spalte breit, die vertikale Position ist durch die Start- und End-
// zeiten bestimmt.
// 4. Platziere jede Stunde so weit links wie möglich, ohne dabei eine andere Stunde zu
// überschneiden.
// 5. Wenn alle Stunden platziert sind, berechne für jeden Stundenblock die tatsächliche
// Breite der Stunden, indem man den Platz durch die Anzahl der Spalten teilt.
// 6. Fülle die leeren Lücken im Raster auf, indem die anliegenden Stunden nach rechts
// erweitert werden.

// Das hier gibt die Stunden als Raster zurück. Es ist als Stream implementiert, um die Teile des
// Rasters zu separieren, die voneinander unabhängig sind.
// Das vereinfacht den Code und macht ihn ohne Funktionseinbußen verständlicher.
Iterable<List<List<TimeTablePeriod>>> periodsToTimeTableGrid(
  List<TimeTablePeriod> periods,
) sync* {
  // Das Raster ist eine Liste von Spalten, jede Spalte ist eine Liste von "Zeilen", die eigentlich nur Stunden sind.
  List<List<TimeTablePeriod>> grid = [];
  DateTime? lastEndTime;

  periods.sort(
    (a, b) => !a.startTime.isAtSameMomentAs(b.startTime)
        ? a.startTime.compareTo(b.startTime)
        : a.endTime.compareTo(b.endTime),
  );

  // Wir gehen jede Stunde in der Reihenfolge ihrer Startzeit durch.
  for (TimeTablePeriod period in periods) {
    if (lastEndTime != null && period.startTime.isAfter(lastEndTime)) {
      // In diesem Fall sind alle folgenden Stunden nach der letzten Endzeit und sind daher unabhängig.
      // Wir geben das Raster zurück und beginnen ein neues.
      yield grid;
      grid = [];
      lastEndTime = null;
    }

    // Wir versuchen, den Punkt in die erste Spalte zu setzen, in der das letzte Element nicht mit diesem Punkt überschneidet.
    // Wir müssen nur das letzte überprüfen, da die Perioden nach der Startzeit sortiert sind.
    bool placed = false;
    for (var column in grid) {
      if (!column.last.collidesWith(period)) {
        column.add(period);
        placed = true;
        break;
      }
    }
    if (!placed) {
      /// Wenn wir keine freie Spalte gefunden haben, fügen wir eine neue Spalte hinzu.
      grid.add([period]);
    }
    if (lastEndTime == null || period.endTime.isAfter(lastEndTime)) {
      lastEndTime = period.endTime;
    }
  }
  if (grid.isNotEmpty) {
    yield grid;
  }
}

class PeriodLayout extends ConsumerWidget {
  final List<TimeTablePeriod> periods;
  final double fontSize;

  const PeriodLayout({
    required this.periods,
    required this.fontSize,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    late TimeOfDay startOfDay;
    late TimeOfDay endOfDay;

    var timeGrid = ref.watch(
      selectedSessionProvider.select((value) => value.userData!.timeGrid),
    );
    startOfDay = timeGrid.first.startTime;
    endOfDay = timeGrid.last.endTime;

    return CustomMultiChildLayout(
      delegate: _PeriodLayoutDelegate(
        periods: periods,
        startOfDay: startOfDay,
        endOfDay: endOfDay,
      ),
      children: periods
          .map(
            (e) => LayoutId(
              id: e,
              child: TimeTablePeriodWidget(
                period: e,
                fontSize: fontSize,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _PeriodLayoutDelegate extends MultiChildLayoutDelegate {
  final List<TimeTablePeriod> periods;
  final TimeOfDay startOfDay;
  final TimeOfDay endOfDay;

  _PeriodLayoutDelegate({
    required this.periods,
    required this.startOfDay,
    required this.endOfDay,
  });

  @override
  void performLayout(Size size) {
    for (List<List<TimeTablePeriod>> gridPart
        in periodsToTimeTableGrid(periods)) {
      /// Als erstes berechnen wir den Offset für jede Stunde.
      double columnWidth = size.width / gridPart.length;

      /// height * (start - startOfDay) / (endOfDay - startOfDay) = yOffset
      double dateTimeToYOffset(DateTime dateTime) =>
          size.height *
          (dateTime.hour * 60 +
              dateTime.minute -
              startOfDay.hour * 60 -
              startOfDay.minute) /
          (endOfDay.hour * 60 +
              endOfDay.minute -
              startOfDay.hour * 60 -
              startOfDay.minute);

      for (int i = 0; i < gridPart.length; i++) {
        List<TimeTablePeriod> column = gridPart[i];
        for (TimeTablePeriod period in column) {
          positionChild(
            period,
            Offset(
              i * columnWidth,
              dateTimeToYOffset(period.startTime),
            ),
          );
        }
      }

      /// Das berechnet, wie viele Spalten die Periode expandieren kann.
      /// 1 bedeutet, dass sie sich nicht ausdehnen kann, 2 bedeutet, dass sie sich in die nächste Spalte ausdehnen kann usw.
      int possibleWidthExpansion(TimeTablePeriod period, int column) {
        int expansion = 1;
        for (int i = column + 1; i < gridPart.length; i++) {
          if (gridPart[i].any((element) => element.collidesWith(period))) {
            return expansion;
          }
          expansion++;
        }
        return expansion;
      }

      for (int i = 0; i < gridPart.length; i++) {
        List<TimeTablePeriod> column = gridPart[i];
        for (TimeTablePeriod period in column) {
          layoutChild(
            period,
            BoxConstraints(
              minWidth: columnWidth * possibleWidthExpansion(period, i),
              maxWidth: columnWidth * possibleWidthExpansion(period, i),
              minHeight: dateTimeToYOffset(period.endTime) -
                  dateTimeToYOffset(period.startTime),
              maxHeight: dateTimeToYOffset(period.endTime) -
                  dateTimeToYOffset(period.startTime),
            ),
          );
        }
      }
    }
  }

  @override
  bool shouldRelayout(_PeriodLayoutDelegate oldDelegate) {
    return !listEquals(oldDelegate.periods, periods) &&
        oldDelegate.startOfDay != startOfDay &&
        oldDelegate.endOfDay != endOfDay;
  }
}
