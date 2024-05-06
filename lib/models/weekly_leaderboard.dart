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

  double get average => total / 7;

  double get mondayCumulative => monday;
  double get tuesdayCumulative => monday + tuesday;
  double get wednesdayCumulative => monday + tuesday + wednesday;
  double get thursdayCumulative => monday + tuesday + wednesday + thursday;
  double get fridayCumulative => thursdayCumulative + friday;
  double get saturdayCumulative => fridayCumulative + saturday;
  double get sundayCumulative => saturdayCumulative + sunday;

  double get maxDay => [
        monday,
        tuesday,
        wednesday,
        thursday,
        friday,
        saturday,
        sunday
      ].reduce((double currentMax, double element) =>
          currentMax > element ? currentMax : element);

  double getDayofWeek(int day) {
    if (day == 1) {
      return monday;
    } else if (day == 2) {
      return tuesday;
    } else if (day == 3) {
      return wednesday;
    } else if (day == 4) {
      return thursday;
    } else if (day == 5) {
      return friday;
    } else if (day == 6) {
      return saturday;
    } else {
      return sunday;
    }
  }

  String get maxDayName {
    if (maxDay == monday) {
      return 'Monday';
    } else if (maxDay == tuesday) {
      return 'Tuesday';
    } else if (maxDay == wednesday) {
      return 'Wednesday';
    } else if (maxDay == thursday) {
      return 'Thursday';
    } else if (maxDay == friday) {
      return 'Friday';
    } else if (maxDay == saturday) {
      return 'Saturday';
    } else {
      return 'Sunday';
    }
  }

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

  factory WeeklyScoreboard.thisWeekFromTimerResult(
      List<TimerResult> timerResults) {
    print(DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)));
    // get all the timer results for the current week
    final List<TimerResult> currentWeek = timerResults
        .where((TimerResult timerResult) => timerResult.startTime.isAfter(
            DateTime.now()
                .subtract(Duration(days: DateTime.now().weekday - 1))
                .copyWith(
                    hour: 0,
                    minute: 0,
                    second: 0,
                    millisecond: 0,
                    microsecond: 0)))
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
  factory WeeklyScoreboard.lastWeekFromTimerResult(
      List<TimerResult> timerResults) {
    // get all the timer results for the last week
    final List<TimerResult> lastWeek = timerResults
        .where((TimerResult timerResult) => timerResult.startTime.isAfter(
            DateTime.now()
                .copyWith(
                    hour: 0,
                    minute: 0,
                    second: 0,
                    millisecond: 0,
                    microsecond: 0)
                .subtract(Duration(days: DateTime.now().weekday + 6))))
        .where((TimerResult timerResult) => timerResult.startTime.isBefore(
            DateTime.now()
                .copyWith(
                    hour: 0,
                    minute: 0,
                    second: 0,
                    millisecond: 0,
                    microsecond: 0)
                .subtract(Duration(days: DateTime.now().weekday - 1))))
        .toList();
    List<double> tempDays = List<double>.filled(7, 0);

    for (int i = 1; i <= 7; i++) {
      tempDays[i - 1] = TimeModel(lastWeek
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

  factory WeeklyScoreboard.fromTimerResult(List<TimerResult> timerResults,
      {required DateTime startDate, required DateTime endDate}) {
    List<double> tempDays = List<double>.filled(7, 0);

    for (int i = 1; i <= 7; i++) {
      tempDays[i - 1] = TimeModel(timerResults
              .where((TimerResult timerResult) =>
                  timerResult.startTime.isAfter(startDate) &&
                  timerResult.startTime.isBefore(endDate) &&
                  timerResult.startTime.weekday == i)
              .map((TimerResult timerResult) => timerResult.timeRun)
              .fold(0,
                  (int previousValue, int element) => previousValue + element))
          .minutes
          .toDouble();
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
