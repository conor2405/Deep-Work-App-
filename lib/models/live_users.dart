class LiveUsers {
  final List<LiveUser> users;
  final int total;

  LiveUsers({
    required this.users,
    required this.total,
  });
}

class LiveUser {
  bool isOnline;
  bool isActive;
  double lat;
  double lng;

  LiveUser({
    required this.isOnline,
    required this.isActive,
    required this.lat,
    required this.lng,
  });

  factory LiveUser.fromJson(Map<String, dynamic> json) {
    return LiveUser(
      isOnline: json['isOnline'],
      isActive: json['isActive'],
      lat: json['lat'],
      lng: json['lng'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isOnline'] = this.isOnline;
    data['isActive'] = this.isActive;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    return data;
  }

  @override
  String toString() {
    return 'LiveUser{isOnline: $isOnline, lat: $lat, lng: $lng}';
  }
}
