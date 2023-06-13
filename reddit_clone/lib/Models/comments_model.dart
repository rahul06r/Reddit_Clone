// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:collection/collection.dart';

class Comment {
  final String id;
  final String text;
  final DateTime createdAt;
  final String postId;
  final String username;
  final String profilePic;
  final String userPostedId;
  final List<String> likesForComments;
  Comment({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.postId,
    required this.username,
    required this.profilePic,
    required this.userPostedId,
    required this.likesForComments,
  });

  Comment copyWith({
    String? id,
    String? text,
    DateTime? createdAt,
    String? postId,
    String? username,
    String? profilePic,
    String? userPostedId,
    List<String>? likesForComments,
  }) {
    return Comment(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      postId: postId ?? this.postId,
      username: username ?? this.username,
      profilePic: profilePic ?? this.profilePic,
      userPostedId: userPostedId ?? this.userPostedId,
      likesForComments: likesForComments ?? this.likesForComments,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'text': text,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'postId': postId,
      'username': username,
      'profilePic': profilePic,
      'userPostedId': userPostedId,
      'likesForComments': likesForComments,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
        id: map['id'] as String,
        text: map['text'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
        postId: map['postId'] as String,
        username: map['username'] as String,
        profilePic: map['profilePic'] as String,
        userPostedId: map['userPostedId'] as String,
        likesForComments: List<String>.from(
          (map['likesForComments']),
        ));
  }

  @override
  String toString() {
    return 'Comment(id: $id, text: $text, createdAt: $createdAt, postId: $postId, username: $username, profilePic: $profilePic, userPostedId: $userPostedId, likesForComments: $likesForComments)';
  }

  @override
  bool operator ==(covariant Comment other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.id == id &&
        other.text == text &&
        other.createdAt == createdAt &&
        other.postId == postId &&
        other.username == username &&
        other.profilePic == profilePic &&
        other.userPostedId == userPostedId &&
        listEquals(other.likesForComments, likesForComments);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        text.hashCode ^
        createdAt.hashCode ^
        postId.hashCode ^
        username.hashCode ^
        profilePic.hashCode ^
        userPostedId.hashCode ^
        likesForComments.hashCode;
  }

  // String toJson() => json.encode(toMap());

  // factory Comment.fromJson(String source) =>
  //     Comment.fromMap(json.decode(source) as Map<String, dynamic>);
}
