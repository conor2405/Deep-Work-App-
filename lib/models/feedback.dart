import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackEntry {
  FeedbackEntry({
    required this.uid,
    required this.message,
    this.email,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String uid;
  final String message;
  final String? email;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'message': message,
      'email': email,
      'createdAt': createdAt,
    };
  }

  factory FeedbackEntry.fromJson(Map<String, dynamic> json) {
    final createdAt = json['createdAt'];
    return FeedbackEntry(
      uid: json['uid'] as String? ?? '',
      message: json['message'] as String? ?? '',
      email: json['email'] as String?,
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : (createdAt as DateTime?) ?? DateTime.now(),
    );
  }
}
