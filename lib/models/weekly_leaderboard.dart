import 'package:deep_work/models/time.dart';
import 'package:deep_work/models/timer_result.dart';
import '';

class WeeklyScoreboard {
  double monday;
  double tuesday;
  double wednesday;
  double thursday;
  double friday;
  double saturday;
  double sunday;
  double total;
  DateTime get date => DateTime.now();

  WeeklyScoreboard({
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
    required this.total,
  });

  factory WeeklyScoreboard.fromTimerResult(List<TimerResult> timerResults) {
    // get all the timer results for the current week
    final List<TimerResult> currentWeek = timerResults
        .where((TimerResult timerResult) => timerResult.startTime.isAfter(
            DateTime.now()
                .subtract(Duration(days: DateTime.now().weekday - 1))))
        .toList();
    List<double> tempDays = List<double>.filled(7, 0);

    for (int i = 1; i <= 7; i++) {
      tempDays[i - 1] = TimeModel(currentWeek
          .where(
              (TimerResult timerResult) => timerResult.startTime.weekday == i)
          .map((TimerResult timerResult) => timerResult.timeRun)
          .fold(
              0,
              (int previousValue, int element) =>
                  previousValue + element)).minutes.toDouble();
    }
    double total = tempDays.fold(
        0, (double previousValue, double element) => previousValue + element);

    return WeeklyScoreboard(
      monday: tempDays[0],
      tuesday: tempDays[1],
      wednesday: tempDays[2],
      thursday: tempDays[3],
      friday: tempDays[4],
      saturday: tempDays[5],
      sunday: tempDays[6],
      total: total,
    );
  }
}
