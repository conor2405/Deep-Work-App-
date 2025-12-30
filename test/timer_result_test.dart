import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deep_work/models/time.dart';
import 'package:deep_work/models/timer_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TimerStats', () {
    test('tick decrements timeLeft and increments timeRun', () {
      final stats = TimerStats(targetTime: TimeModel(10));

      stats.tick();

      expect(stats.timeLeft.seconds, 9);
      expect(stats.timeRun, 1);
    });

    test('pause/resume tracks pause events', () {
      final stats = TimerStats(targetTime: TimeModel(10));

      stats.pause();

      expect(stats.pauses, 1);
      expect(stats.pauseEvents.length, 1);
      expect(stats.pauseEvents.last.endTime, isNull);

      stats.resume();

      expect(stats.pauseEvents.last.endTime, isNotNull);
    });
  });

  group('TimerResult.fromJson', () {
    test('handles notes and pause events', () {
      final start = DateTime(2024, 5, 1, 10, 0, 0);
      final end = start.add(Duration(minutes: 10));
      final pauseStart = start.add(Duration(minutes: 2));
      final pauseEnd = pauseStart.add(Duration(minutes: 1));

      final json = {
        'timeLeft': 0,
        'targetTime': 600,
        'completed': true,
        'timeRun': 600,
        'timePaused': 60,
        'timeElapsed': 660,
        'startTime': Timestamp.fromDate(start),
        'timeFinished': Timestamp.fromDate(end),
        'pauses': 1,
        'pauseEvents': [
          {
            'startTime': Timestamp.fromDate(pauseStart),
            'endTime': Timestamp.fromDate(pauseEnd),
          }
        ],
        'sessionEfficiency': 0.9,
        'notes': ['Focus', 'Break'],
      };

      final result = TimerResult.fromJson(json);

      expect(result.notes, ['Focus', 'Break']);
      expect(result.pauseEvents.length, 1);
      expect(result.pauseEvents.first.startTime, pauseStart);
      expect(result.pauseEvents.first.endTime, pauseEnd);
      expect(result.sessionEfficiency, 0.9);
    });

    test('defaults sessionEfficiency when missing', () {
      final start = DateTime(2024, 5, 1, 10, 0, 0);
      final end = start.add(Duration(minutes: 10));

      final json = {
        'timeLeft': 0,
        'targetTime': 600,
        'completed': true,
        'timeRun': 600,
        'timePaused': 0,
        'timeElapsed': 600,
        'startTime': Timestamp.fromDate(start),
        'timeFinished': Timestamp.fromDate(end),
        'pauses': 0,
        'pauseEvents': [],
      };

      final result = TimerResult.fromJson(json);

      expect(result.sessionEfficiency, 1);
      expect(result.notes, isEmpty);
    });
  });
}
