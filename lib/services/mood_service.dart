import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:neurorga/models/mood_entry.dart';
import 'package:neurorga/services/backend_config.dart';

class MoodService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  // Simple in-memory store for offline mode
  static final Map<String, List<MoodEntry>> _offlineDb = {};

  Future<void> addMoodEntry(MoodEntry entry) async {
    try {
      if (!BackendConfig.backendEnabled) {
        final list = _offlineDb.putIfAbsent(entry.userId, () => []);
        list.removeWhere((e) => e.id == entry.id);
        list.add(entry);
        return;
      }
      await _firestore.collection('mood_entries').doc(entry.id).set(entry.toJson());
    } catch (e) {
      debugPrint('Error adding mood entry: $e');
      rethrow;
    }
  }

  Future<List<MoodEntry>> getUserMoodEntries(String userId) async {
    try {
      if (!BackendConfig.backendEnabled) {
        final list = List<MoodEntry>.from(_offlineDb[userId] ?? []);
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      }
      final snapshot = await _firestore
          .collection('mood_entries')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();
      return snapshot.docs.map((doc) => MoodEntry.fromJson(doc.data())).toList();
    } catch (e) {
      debugPrint('Error fetching user mood entries: $e');
      return [];
    }
  }

  Future<List<MoodEntry>> getRecentMoodEntries(String userId, int limit) async {
    try {
      if (!BackendConfig.backendEnabled) {
        final list = await getUserMoodEntries(userId);
        return list.take(limit).toList();
      }
      final snapshot = await _firestore
          .collection('mood_entries')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((doc) => MoodEntry.fromJson(doc.data())).toList();
    } catch (e) {
      debugPrint('Error fetching recent mood entries: $e');
      return [];
    }
  }

  Future<Map<String, double>> getAverageRatings(String userId) async {
    try {
      final entries = await getUserMoodEntries(userId);
      
      if (entries.isEmpty) {
        return {
          'calmness': 0.0,
          'focus': 0.0,
          'happiness': 0.0,
        };
      }

      final calmnessAvg = entries.map((e) => e.calmnessRating).reduce((a, b) => a + b) / entries.length;
      final focusAvg = entries.map((e) => e.focusRating).reduce((a, b) => a + b) / entries.length;
      final happinessAvg = entries.map((e) => e.happinessRating).reduce((a, b) => a + b) / entries.length;

      return {
        'calmness': calmnessAvg,
        'focus': focusAvg,
        'happiness': happinessAvg,
      };
    } catch (e) {
      debugPrint('Error calculating average ratings: $e');
      return {
        'calmness': 0.0,
        'focus': 0.0,
        'happiness': 0.0,
      };
    }
  }

  Future<Map<String, int>> getEmotionFrequency(String userId) async {
    try {
      final entries = await getUserMoodEntries(userId);
      
      final frequency = <String, int>{};
      for (final entry in entries) {
        frequency[entry.emotionBefore] = (frequency[entry.emotionBefore] ?? 0) + 1;
      }
      
      return frequency;
    } catch (e) {
      debugPrint('Error calculating emotion frequency: $e');
      return {};
    }
  }
}
