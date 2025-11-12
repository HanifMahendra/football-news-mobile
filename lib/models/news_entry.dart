// To parse this JSON data, do
//
//     final newsEntry = newsEntryFromJson(jsonString);

import 'dart:convert';

List<NewsEntry> newsEntryFromJson(String str) => List<NewsEntry>.from(json.decode(str).map((x) => NewsEntry.fromJson(x)));

String newsEntryToJson(List<NewsEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NewsEntry {
  final int id;
  final String title;
  final String content;
  final String category;
  final String? thumbnail;
  final int newsViews;
  final DateTime createdAt;
  final bool isFeatured;
  final int? userId;

  NewsEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.thumbnail,
    required this.newsViews,
    required this.createdAt,
    required this.isFeatured,
    this.userId,
  });

  factory NewsEntry.fromJson(Map<String, dynamic> json) => NewsEntry(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
        title: json['title']?.toString() ?? '',
        content: json['content']?.toString() ?? '',
        category: json['category']?.toString() ?? '',
        thumbnail: json['thumbnail'] != null ? json['thumbnail'].toString() : null,
        newsViews: json['news_views'] is int ? json['news_views'] : int.tryParse(json['news_views'].toString()) ?? 0,
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
        isFeatured: (json['is_featured'] == true) || (json['is_featured']?.toString() == 'true'),
        userId: json['user_id'] is int ? json['user_id'] : (json['user_id'] != null ? int.tryParse(json['user_id'].toString()) : null),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'category': category,
        'thumbnail': thumbnail,
        'news_views': newsViews,
        'created_at': createdAt.toIso8601String(),
        'is_featured': isFeatured,
        'user_id': userId,
      };
}