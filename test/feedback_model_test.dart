import 'package:deep_work/models/feedback.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FeedbackEntry serializes and deserializes', () {
    final createdAt = DateTime(2024, 1, 2, 3, 4, 5);
    final entry = FeedbackEntry(
      uid: 'user-123',
      message: 'Love the focus timer.',
      email: 'user@example.com',
      createdAt: createdAt,
    );

    final json = entry.toJson();
    final restored = FeedbackEntry.fromJson(json);

    expect(restored.uid, entry.uid);
    expect(restored.message, entry.message);
    expect(restored.email, entry.email);
    expect(restored.createdAt, entry.createdAt);
  });
}
