import 'package:deep_work/models/goal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TimeGoal serializes and deserializes', () {
    final goal = TimeGoal(type: 'daily', goal: 120, completed: 60);

    final json = goal.toJson();
    final decoded = TimeGoal.fromJson(json);

    expect(decoded.type, 'daily');
    expect(decoded.goal, 120);
    expect(decoded.completed, 60);
  });

  test('TimeGoal allows missing completed field', () {
    final decoded = TimeGoal.fromJson({'type': 'daily', 'goal': 120});

    expect(decoded.type, 'daily');
    expect(decoded.goal, 120);
    expect(decoded.completed, isNull);
  });

  test('TimeGoalsAll roundtrip', () {
    final goals = TimeGoalsAll()
      ..setDaily = TimeGoal(type: 'daily', goal: 60, completed: 10)
      ..setWeekly = TimeGoal(type: 'weekly', goal: 300, completed: 100)
      ..setMonthly = TimeGoal(type: 'monthly', goal: 1200, completed: 400)
      ..setYearly = TimeGoal(type: 'yearly', goal: 12000, completed: 3000)
      ..setUID = 'user-1';

    final json = goals.toJson();
    final decoded = TimeGoalsAll.fromJson(json);

    expect(decoded.uid, 'user-1');
    expect(decoded.daily.goal, 60);
    expect(decoded.weekly.goal, 300);
    expect(decoded.monthly.goal, 1200);
    expect(decoded.yearly.goal, 12000);
  });
}
