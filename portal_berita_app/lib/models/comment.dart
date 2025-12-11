import 'user.dart';

class Comment {
  final int id;
  final int userId;
  final int newsId;
  final String content;
  final DateTime createdAt;
  final User? user;

  Comment({
    required this.id,
    required this.userId,
    required this.newsId,
    required this.content,
    required this.createdAt,
    this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['user_id'],
      newsId: json['news_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'news_id': newsId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
