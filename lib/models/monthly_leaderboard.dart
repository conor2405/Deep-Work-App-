import 'package:deep_work/models/time.dart';
import 'package:deep_work/models/timer_result.dart';

class MonthlyScoreboard {
  final String month;
  final List<double> time;

  double get total => time.fold(
      0.0, (double previousValue, double element) => previousValue + element);

  MonthlyScoreboard({required this.month, required this.time});

  factory MonthlyScoreboard.fromTimerResult(List<TimerResult> timerResults) {
    List<double> tempDays = List<double>.filled(31, 0);

    for (int i = 1; i <= 31; i++) {
      tempDays[i - 1] = TimeModel(timerResults
              .where((TimerResult timerResult) =>
                  timerResult.startTime.day == i &&
                  timerResult.startTime.month == DateTime.now().month)
              .map((TimerResult timerResult) => timerResult.timeRun)
              .fold(0,
                  (int previousValue, int element) => previousValue + element))
          .minutes
          .toDouble();
    }
    final List<String> monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    String month = monthNames[DateTime.now().month - 1];

    return MonthlyScoreboard(
      month: month,
      time: tempDays,
    );
  }
}
