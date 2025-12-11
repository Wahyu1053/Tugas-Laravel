import 'user.dart';
import 'comment.dart';

class News {
  final int id;
  final int userId;
  final String title;
  final String content;
  final String? image;
  final String? category;
  final bool isPublished;
  final DateTime createdAt;
  final User? user;
  final List<Comment>? comments;

  News({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.image,
    this.category,
    required this.isPublished,
    required this.createdAt,
    this.user,
    this.comments,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      content: json['content'],
      image: json['image'],
      category: json['category'],
      isPublished: json['is_published'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      comments: json['comments'] != null
          ? (json['comments'] as List)
              .map((comment) => Comment.fromJson(comment))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'image': image,
      'category': category,
      'is_published': isPublished,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
