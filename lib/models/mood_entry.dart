import 'package:cloud_firestore/cloud_firestore.dart';

class MoodEntry {
  final String id;
  final String userId;
  final String ragaId;
  final String ragaName;
  final String emotionBefore;
  final int calmnessRating;
  final int focusRating;
  final int happinessRating;
  final DateTime createdAt;
  final DateTime updatedAt;

  MoodEntry({
    required this.id,
    required this.userId,
    required this.ragaId,
    required this.ragaName,
    required this.emotionBefore,
    required this.calmnessRating,
    required this.focusRating,
    required this.happinessRating,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'raga_id': ragaId,
    'raga_name': ragaName,
    'emotion_before': emotionBefore,
    'calmness_rating': calmnessRating,
    'focus_rating': focusRating,
    'happiness_rating': happinessRating,
    'created_at': Timestamp.fromDate(createdAt),
    'updated_at': Timestamp.fromDate(updatedAt),
  };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    ragaId: json['raga_id'] as String,
    ragaName: json['raga_name'] as String,
    emotionBefore: json['emotion_before'] as String,
    calmnessRating: json['calmness_rating'] as int,
    focusRating: json['focus_rating'] as int,
    happinessRating: json['happiness_rating'] as int,
    createdAt: (json['created_at'] as Timestamp).toDate(),
    updatedAt: (json['updated_at'] as Timestamp).toDate(),
  );

  MoodEntry copyWith({
    String? id,
    String? userId,
    String? ragaId,
    String? ragaName,
    String? emotionBefore,
    int? calmnessRating,
    int? focusRating,
    int? happinessRating,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MoodEntry(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    ragaId: ragaId ?? this.ragaId,
    ragaName: ragaName ?? this.ragaName,
    emotionBefore: emotionBefore ?? this.emotionBefore,
    calmnessRating: calmnessRating ?? this.calmnessRating,
    focusRating: focusRating ?? this.focusRating,
    happinessRating: happinessRating ?? this.happinessRating,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
