import 'dart:math';

import 'package:dart_geohash/dart_geohash.dart';

class LiveUsers {
  final List<LiveUser> users;

  int get total => users.length;

  LiveUsers({
    required this.users,
  });
}

class LiveUser {
  static const int privacyGeohashPrecision = 4;
  static final GeoHasher _geoHasher = GeoHasher();

  final String uid;
  final bool isActive;
  final String geohash;
  late final double lat;
  late final double lng;

  LiveUser({
    required this.uid,
    required this.isActive,
    required this.geohash,
  }) {
    final position = _jitteredPosition(geohash, seed: uid);
    lat = position.lat;
    lng = position.lng;
  }

  factory LiveUser.fromCoordinates({
    required String uid,
    required bool isActive,
    required double lat,
    required double lng,
    int precision = privacyGeohashPrecision,
  }) {
    final geohash = geohashForCoordinates(
      lat: lat,
      lng: lng,
      precision: precision,
    );
    return LiveUser(
      uid: uid,
      isActive: isActive,
      geohash: geohash,
    );
  }

  static String geohashForCoordinates({
    required double lat,
    required double lng,
    int precision = privacyGeohashPrecision,
  }) {
    return _geoHasher.encode(lng, lat, precision: precision).toLowerCase();
  }

  factory LiveUser.fromJson(Map<String, dynamic> json) {
    // check if any of the required fields are missing
    if (!json.containsKey('uid') ||
        !json.containsKey('isActive') ||
        (!json.containsKey('geohash') &&
            (!json.containsKey('lat') || !json.containsKey('lng')))) {
      throw ArgumentError('Missing required fields in LiveUser.fromJson');
    }

    final uid = json['uid'].toString();
    final isActive = json['isActive'] == true;
    final geohashValue = json['geohash'];
    final geohash = geohashValue is String && geohashValue.isNotEmpty
        ? geohashValue.toLowerCase()
        : _geoHasher.encode(
            (json['lng'] as num).toDouble(),
            (json['lat'] as num).toDouble(),
            precision: privacyGeohashPrecision,
          );

    return LiveUser(
      uid: uid,
      isActive: isActive,
      geohash: geohash,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'isActive': isActive,
      'geohash': geohash,
    };
  }

  static _GeoPoint _jitteredPosition(String geohash, {required String seed}) {
    final decoded = _geoHasher.decode(geohash);
    final centerLng = decoded[0];
    final centerLat = decoded[1];
    final span = _spanForPrecision(geohash.length);
    // Offset within the cell so markers don't stack while staying coarse.
    final random = Random(_stableSeed('$seed|$geohash'));
    final jitterLat = (random.nextDouble() - 0.5) * span.latSpan;
    final jitterLng = (random.nextDouble() - 0.5) * span.lngSpan;
    final lat = _clampLatitude(centerLat + jitterLat);
    final lng = _wrapLongitude(centerLng + jitterLng);
    return _GeoPoint(lat: lat, lng: lng);
  }

  static _GeoSpan _spanForPrecision(int length) {
    final totalBits = length * 5;
    final lonBits = (totalBits + 1) ~/ 2;
    final latBits = totalBits ~/ 2;
    final lngSpan = 360.0 / (1 << lonBits);
    final latSpan = 180.0 / (1 << latBits);
    return _GeoSpan(latSpan: latSpan, lngSpan: lngSpan);
  }

  static int _stableSeed(String value) {
    const fnvOffset = 0x811c9dc5;
    const fnvPrime = 0x01000193;
    var hash = fnvOffset;
    for (final unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * fnvPrime) & 0xffffffff;
    }
    return hash & 0x7fffffff;
  }

  static double _wrapLongitude(double longitude) {
    var wrapped = longitude;
    while (wrapped < -180) {
      wrapped += 360;
    }
    while (wrapped > 180) {
      wrapped -= 360;
    }
    return wrapped;
  }

  static double _clampLatitude(double latitude) {
    return latitude.clamp(-90.0, 90.0);
  }
}

class _GeoPoint {
  final double lat;
  final double lng;

  const _GeoPoint({required this.lat, required this.lng});
}

class _GeoSpan {
  final double latSpan;
  final double lngSpan;

  const _GeoSpan({required this.latSpan, required this.lngSpan});
}
