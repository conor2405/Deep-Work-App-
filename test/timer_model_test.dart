import 'package:deep_work/models/time.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TimeModel', () {
    test('get minutes returns correct value', () {
      final time = TimeModel(120);
      expect(time.minutes, 2);
    });

    test('get hours returns correct value', () {
      final time = TimeModel(7200);
      expect(time.hours, 2);
    });

    test('setMinutes sets seconds correctly', () {
      final time = TimeModel(0);
      time.setMinutes = 5;
      expect(time.seconds, 300);
    });

    test('setHours sets seconds correctly', () {
      final time = TimeModel(0);
      time.setHours = 2;
      expect(time.seconds, 7200);
    });

    test('setSeconds sets seconds correctly', () {
      final time = TimeModel(0);
      time.setSeconds = 60;
      expect(time.seconds, 60);
    });

    test('setHoursMinutes sets seconds correctly', () {
      final time = TimeModel(0);
      time.setHoursMinutes = [2, 30];
      expect(time.seconds, 9000);
    });

    test(
        'getTrimmedTimeMinutes returns 180 for values > 180 and 0 for values <0',
        () {
      final time = TimeModel(100000);
      expect(time.getTrimmedTimeMinutes, 180);
      final time2 = TimeModel.zero();
      time2.setMinutes = -10;
      expect(time2.getTrimmedTimeMinutes, 0);
    });
    test('TimeModel.zero() returns a TimeModel with 0 seconds', () {
      final time = TimeModel.zero();
      expect(time.seconds, 0);
      expect(time.minutes, 0);
      expect(time.hours, 0);
      expect(time.getTrimmedTimeMinutes, 0);
    });
  });
  group('TimeModel String Methods', () {
    test('hours are padded with leading zeros', () {
      final time = TimeModel(4573);
      expect(time.timeString, '01:16:13');
    });
  });
}
