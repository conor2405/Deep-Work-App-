import 'package:deep_work/models/live_users.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('LiveUser.fromJson throws when required fields are missing', () {
    expect(
      () => LiveUser.fromJson({'uid': 'abc'}),
      throwsArgumentError,
    );
  });

  test('LiveUser toJson/fromJson roundtrip', () {
    final user = LiveUser(uid: 'abc', isActive: true, lat: 10.5, lng: -20.5);

    final json = user.toJson();
    final decoded = LiveUser.fromJson(json);

    expect(decoded.uid, user.uid);
    expect(decoded.isActive, user.isActive);
    expect(decoded.lat, user.lat);
    expect(decoded.lng, user.lng);
  });
}
