import 'package:equatable/equatable.dart';

class TimeModel {
  int seconds;

  TimeModel(this.seconds);

  TimeModel.zero() : seconds = 0;

  int get minutes => seconds ~/ 60;
  int get hours => seconds ~/ 3600;
  String get timeString {
    final hours = this.hours.toString().padLeft(2, '0');
    final minutes = (this.minutes % 60).toString().padLeft(2, '0');
    final seconds = (this.seconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  double get decimalMinutes => seconds / 60;

  int get getTrimmedTimeMinutes {
    int trimmedMinutes = this.minutes > 180 ? 180 : this.minutes;
    trimmedMinutes = trimmedMinutes < 0 ? 0 : trimmedMinutes;
    return trimmedMinutes;
  }

  set setMinutes(int minutes) => seconds = minutes * 60;
  set setHours(int hours) => seconds = hours * 3600;
  set setSeconds(int seconds) => this.seconds = seconds;
  set setHoursMinutes(List<int> time) =>
      seconds = (time[0] * 3600) + (time[1] * 60);
}
