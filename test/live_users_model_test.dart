import 'package:deep_work/models/live_users.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('LiveUser.fromJson throws when required fields are missing', () {
    expect(
      () => LiveUser.fromJson({'uid': 'abc', 'isActive': true}),
      throwsArgumentError,
    );
  });

  test('LiveUser toJson/fromJson roundtrip', () {
    final user =
        LiveUser(uid: 'abc', isActive: true, geohash: 'ezs4');

    final json = user.toJson();
    final decoded = LiveUser.fromJson(json);

    expect(decoded.uid, user.uid);
    expect(decoded.isActive, user.isActive);
    expect(decoded.geohash, user.geohash);
    expect(decoded.lat, closeTo(user.lat, 0.000001));
    expect(decoded.lng, closeTo(user.lng, 0.000001));
  });

  test('LiveUser jitter stays within geohash cell', () {
    final user = LiveUser(uid: 'seed', isActive: true, geohash: 'ezs4');
    final decoded = GeoHasher().decode(user.geohash);
    final centerLng = decoded[0];
    final centerLat = decoded[1];
    final spans = _spanForPrecision(user.geohash.length);

    expect(
      user.lat,
      inInclusiveRange(
        centerLat - (spans.latSpan / 2),
        centerLat + (spans.latSpan / 2),
      ),
    );
    expect(
      user.lng,
      inInclusiveRange(
        centerLng - (spans.lngSpan / 2),
        centerLng + (spans.lngSpan / 2),
      ),
    );
  });
}

_GeoSpan _spanForPrecision(int length) {
  final totalBits = length * 5;
  final lonBits = (totalBits + 1) ~/ 2;
  final latBits = totalBits ~/ 2;
  final lngSpan = 360.0 / (1 << lonBits);
  final latSpan = 180.0 / (1 << latBits);
  return _GeoSpan(latSpan: latSpan, lngSpan: lngSpan);
}

class _GeoSpan {
  final double latSpan;
  final double lngSpan;

  const _GeoSpan({required this.latSpan, required this.lngSpan});
}
