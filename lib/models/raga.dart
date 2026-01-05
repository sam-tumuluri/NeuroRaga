import 'package:cloud_firestore/cloud_firestore.dart';

class Raga {
  final String id;
  final String name;
  final String emotion;
  final String description;
  final String neuroscienceDescription;
  final String youtubeUrl;
  /// Optional Spotify URL (playlist, album, track, or show). If empty, fall back to search.
  final String spotifyUrl;
    /// Musical feature tags that characterize this rāga (see MusicalFeatureTags)
    final List<String> featureTags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Raga({
    required this.id,
    required this.name,
    required this.emotion,
    required this.description,
    required this.neuroscienceDescription,
    required this.youtubeUrl,
    this.spotifyUrl = '',
        this.featureTags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'emotion': emotion,
    'description': description,
    'neuroscience_description': neuroscienceDescription,
    'youtube_url': youtubeUrl,
    'spotify_url': spotifyUrl,
        'features': featureTags,
    'created_at': Timestamp.fromDate(createdAt),
    'updated_at': Timestamp.fromDate(updatedAt),
  };

  factory Raga.fromJson(Map<String, dynamic> json) => Raga(
    id: json['id'] as String,
    name: json['name'] as String,
    emotion: json['emotion'] as String,
    description: json['description'] as String,
    neuroscienceDescription: json['neuroscience_description'] as String,
    youtubeUrl: json['youtube_url'] as String,
    spotifyUrl: (json['spotify_url'] ?? '') as String,
        featureTags: (json['features'] is List)
            ? (json['features'] as List).whereType<String>().toList()
            : const [],
    createdAt: (json['created_at'] as Timestamp).toDate(),
    updatedAt: (json['updated_at'] as Timestamp).toDate(),
  );

  Raga copyWith({
    String? id,
    String? name,
    String? emotion,
    String? description,
    String? neuroscienceDescription,
    String? youtubeUrl,
    String? spotifyUrl,
        List<String>? featureTags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Raga(
    id: id ?? this.id,
    name: name ?? this.name,
    emotion: emotion ?? this.emotion,
    description: description ?? this.description,
    neuroscienceDescription: neuroscienceDescription ?? this.neuroscienceDescription,
    youtubeUrl: youtubeUrl ?? this.youtubeUrl,
    spotifyUrl: spotifyUrl ?? this.spotifyUrl,
        featureTags: featureTags ?? this.featureTags,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
