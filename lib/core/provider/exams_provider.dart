import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:your_schedule/core/provider/connectivity_provider.dart';
import 'package:your_schedule/core/untis.dart';
import 'package:your_schedule/utils.dart';

part 'exams_provider.g.dart';

@riverpod
class Exams extends _$Exams {
  @override
  Map<Date, List<Exam>> build(ActiveUntisSession session, Week week) {
    if (ref.watch(canMakeRequestProvider)) {
      var exams = ref.watch(requestExamsProvider(session, week));
      if (exams.hasValue) {
        return exams.requireValue;
      }
    }
    return ref.watch(cachedExamsProvider(session, week));
  }
}
