class LiveUsers {
  final List<LiveUser> users;

  int get total => users.length;

  LiveUsers({
    required this.users,
  });
}

class LiveUser {
  String uid;
  bool isActive;
  double lat;
  double lng;

  LiveUser({
    required this.uid,
    required this.isActive,
    required this.lat,
    required this.lng,
  });

  factory LiveUser.fromJson(Map<String, dynamic> json) {
    // check if any of the required fields are missing
    if (!json.containsKey('uid') ||
        !json.containsKey('isActive') ||
        !json.containsKey('lat') ||
        !json.containsKey('lng')) {
      throw ArgumentError('Missing required fields in LiveUser.fromJson');
    }

    return LiveUser(
      uid: json['uid'],
      isActive: json['isActive'],
      lat: json['lat'],
      lng: json['lng'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['isActive'] = this.isActive;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    return data;
  }
}
