import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:neurorga/models/music_cognition.dart';
import 'package:neurorga/models/raga.dart';
import 'package:neurorga/services/backend_config.dart';

class RagaService {
  RagaService() {
    debugPrint('RagaService constructed');
  }

  /// Returns the cognition-driven NeuralNeed derived from an emotion.
  NeuralNeed getNeuralNeedForEmotion(String emotion) {
    switch (emotion) {
      case 'anxious':
        return NeuralNeed(
          id: 'downregulate_sympathetic',
          title: 'Down‑regulate sympathetic arousal',
          description: 'Soothe racing thoughts and reduce physiological arousal with predictable, low‑arousal musical cues.',
          featureTags: const [
            MusicalFeatureTags.slowTempo,
            MusicalFeatureTags.steadyPulse,
            MusicalFeatureTags.predictablePhrases,
            MusicalFeatureTags.downwardContours,
            MusicalFeatureTags.lowerRegister,
            MusicalFeatureTags.minimalDissonance,
            MusicalFeatureTags.soothingTimbre,
            MusicalFeatureTags.minimalOrnamentation,
          ],
        );
      case 'sad':
        return NeuralNeed(
          id: 'mood_uplift_regulation',
          title: 'Gently elevate mood and broaden affect',
          description: 'Introduce gentle brightness and upward motion to support reappraisal without over‑arousal.',
          featureTags: const [
            MusicalFeatureTags.moderateTempo,
            MusicalFeatureTags.ascendingContours,
            MusicalFeatureTags.archContours,
            MusicalFeatureTags.brightMajorish,
            MusicalFeatureTags.consonantIntervals,
            MusicalFeatureTags.gentleGamaka,
            MusicalFeatureTags.midRegister,
          ],
        );
      case 'unfocused':
        return NeuralNeed(
          id: 'stabilize_attention',
          title: 'Stabilize attention and boost executive control',
          description: 'Use rhythmic regularity and simple structures to reduce mind‑wandering.',
          featureTags: const [
            MusicalFeatureTags.steadyPulse,
            MusicalFeatureTags.predictablePhrases,
            MusicalFeatureTags.moderateTempo,
            MusicalFeatureTags.minimalOrnamentation,
            MusicalFeatureTags.pentatonic,
            MusicalFeatureTags.consonantIntervals,
          ],
        );
      case 'tired':
        return NeuralNeed(
          id: 'gentle_activation',
          title: 'Gentle activation without over‑stimulation',
          description: 'Add modest energy and upward motion to lift arousal safely.',
          featureTags: const [
            MusicalFeatureTags.gentleSwing,
            MusicalFeatureTags.moderateTempo,
            MusicalFeatureTags.ascendingContours,
            MusicalFeatureTags.brightMajorish,
            MusicalFeatureTags.midRegister,
          ],
        );
      case 'happy':
        return NeuralNeed(
          id: 'savor_and_sustain',
          title: 'Savor and sustain positive affect',
          description: 'Maintain pleasant arousal with balanced motion and warmth.',
          featureTags: const [
            MusicalFeatureTags.archContours,
            MusicalFeatureTags.moderateTempo,
            MusicalFeatureTags.gentleGamaka,
            MusicalFeatureTags.brightMajorish,
            MusicalFeatureTags.steadyPulse,
          ],
        );
      default:
        return NeuralNeed(
          id: 'balanced_regulation',
          title: 'Balanced regulation',
          description: 'Use neutral, predictable cues to support stability.',
          featureTags: const [
            MusicalFeatureTags.moderateTempo,
            MusicalFeatureTags.steadyPulse,
            MusicalFeatureTags.predictablePhrases,
            MusicalFeatureTags.consonantIntervals,
          ],
        );
    }
  }

  /// Offline feature-overlap recommender sorted by match score.
  Future<List<Raga>> recommendRagasForEmotion(String emotion) async {
    try {
      final need = getNeuralNeedForEmotion(emotion);
      List<Raga> pool;
      if (!BackendConfig.backendEnabled) {
        pool = _getSampleRagas();
      } else {
        // If a backend exists, prefer feature search when available, otherwise fall back to all.
        final snapshot = await _firestore.collection('ragas').get();
        pool = snapshot.docs.map((d) => Raga.fromJson(d.data())).toList();
      }

      // Filter to only ragas explicitly mapped to this emotion.
      var filtered = pool.where((r) => r.emotion == emotion).toList();

      // Rank by number of overlapping features, then by recency as a stable tiebreaker.
      filtered.sort((a, b) {
        final aScore = _overlapScore(a.featureTags, need.featureTags);
        final bScore = _overlapScore(b.featureTags, need.featureTags);
        if (bScore != aScore) return bScore.compareTo(aScore);
        return b.updatedAt.compareTo(a.updatedAt);
      });
      // Enforce exactly top 2 results for the selected emotion to avoid accidental overfill.
      final top = filtered.take(2).toList();
      final names = top.map((r) => r.name).join(', ');
      debugPrint('recommendRagasForEmotion("$emotion"): pool=${pool.length}, filtered=${filtered.length}, returning=${top.length}');
      debugPrint('recommendRagasForEmotion("$emotion") names: [$names]');
      return top;
    } catch (e) {
      debugPrint('Error recommending ragas: $e');
      return [];
    }
  }

  int _overlapScore(List<String> a, List<String> b) {
    final setB = b.toSet();
    return a.where((t) => setB.contains(t)).length;
  }

  FirebaseFirestore get _firestore {
    debugPrint('RagaService: accessing Firestore instance');
    return FirebaseFirestore.instance;
  }

  Future<List<Raga>> getRagasByEmotion(String emotion) async {
    try {
      if (!BackendConfig.backendEnabled) {
        return _getSampleRagas().where((r) => r.emotion == emotion).toList();
      }
      final snapshot = await _firestore
          .collection('ragas')
          .where('emotion', isEqualTo: emotion)
          .get();
      
      return snapshot.docs.map((doc) => Raga.fromJson(doc.data())).toList();
    } catch (e) {
      debugPrint('Error fetching ragas by emotion: $e');
      return [];
    }
  }

  Future<Raga?> getRagaById(String id) async {
    try {
      if (!BackendConfig.backendEnabled) {
        try {
          return _getSampleRagas().firstWhere((r) => r.id == id);
        } catch (_) {
          return null;
        }
      }
      final doc = await _firestore.collection('ragas').doc(id).get();
      if (doc.exists) {
        return Raga.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching raga by id: $e');
      return null;
    }
  }

  Future<List<Raga>> getAllRagas() async {
    try {
      if (!BackendConfig.backendEnabled) {
        return _getSampleRagas();
      }
      final snapshot = await _firestore.collection('ragas').get();
      return snapshot.docs.map((doc) => Raga.fromJson(doc.data())).toList();
    } catch (e) {
      debugPrint('Error fetching all ragas: $e');
      return [];
    }
  }

  Future<void> initializeSampleRagas() async {
    try {
      if (!BackendConfig.backendEnabled) {
        // Nothing to initialize when offline; data comes from local list.
        return;
      }
      final snapshot = await _firestore.collection('ragas').limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        return;
      }

      final sampleRagas = _getSampleRagas();
      final batch = _firestore.batch();
      
      for (final raga in sampleRagas) {
        final docRef = _firestore.collection('ragas').doc(raga.id);
        batch.set(docRef, raga.toJson());
      }
      
      await batch.commit();
      debugPrint('Sample ragas initialized successfully');
    } catch (e) {
      debugPrint('Error initializing sample ragas: $e');
    }
  }

  List<Raga> _getSampleRagas() {
    final now = DateTime.now();
    return [
      Raga(
        id: 'raga_1',
        name: 'Darbari Kanada',
        emotion: 'anxious',
        description: 'A deeply meditative rāga traditionally performed late at night, known for its slow, contemplative movements.',
        neuroscienceDescription: 'The slow, descending phrases in Darbari Kanada activate the parasympathetic nervous system, reducing cortisol levels and promoting deep relaxation. Its tonal patterns enhance alpha and theta brainwave activity, ideal for anxiety relief.',
        youtubeUrl: '',
        spotifyUrl: 'https://open.spotify.com/playlist/6iNP4hAFwyS40Y0JpPRJJj?si=G7Io_waRQQuaK2WPl03Y7w',
        featureTags: const [
          MusicalFeatureTags.slowTempo,
          MusicalFeatureTags.steadyPulse,
          MusicalFeatureTags.predictablePhrases,
          MusicalFeatureTags.downwardContours,
          MusicalFeatureTags.lowerRegister,
          MusicalFeatureTags.minimalDissonance,
          MusicalFeatureTags.soothingTimbre,
          MusicalFeatureTags.gentleGamaka,
        ],
        createdAt: now,
        updatedAt: now,
      ),
      Raga(
        id: 'raga_2',
        name: 'Poorvi Kalyani',
        emotion: 'anxious',
        description: 'An evening rāga with gentle, soothing oscillations that calm the mind.',
        neuroscienceDescription: 'The unique note combinations in Poorvi Kalyani stimulate the release of GABA, a neurotransmitter that reduces neural excitability and promotes calmness.',
        youtubeUrl: '',
        spotifyUrl: 'https://open.spotify.com/playlist/0EGFaWL80N4GHH7pZfecml?si=OkKL203MS9WPMH7eRtHDiA',
        featureTags: const [
          MusicalFeatureTags.slowTempo,
          MusicalFeatureTags.steadyPulse,
          MusicalFeatureTags.downwardContours,
          MusicalFeatureTags.gentleGamaka,
          MusicalFeatureTags.consonantIntervals,
          MusicalFeatureTags.soothingTimbre,
        ],
        createdAt: now,
        updatedAt: now,
      ),
      Raga(
        id: 'raga_3',
        name: 'Sahana',
        emotion: 'sad',
        description: 'A morning rāga that brings hope and positivity through its gentle, uplifting phrases.',
        neuroscienceDescription: 'Sahana\'s melodic structure enhances serotonin production, improving mood and emotional resilience. The ascending patterns activate reward centers in the brain.',
        youtubeUrl: '',
        spotifyUrl: 'https://open.spotify.com/playlist/51Sz6gGhgOA3wlIMuDEcyM?si=leAXOKJKRu-bv55Z7wQnSw',
        featureTags: const [
          MusicalFeatureTags.moderateTempo,
          MusicalFeatureTags.ascendingContours,
          MusicalFeatureTags.archContours,
          MusicalFeatureTags.brightMajorish,
          MusicalFeatureTags.gentleGamaka,
          MusicalFeatureTags.consonantIntervals,
          MusicalFeatureTags.midRegister,
        ],
        createdAt: now,
        updatedAt: now,
      ),
      Raga(
        id: 'raga_4',
        name: 'Ananda Bhairavi',
        emotion: 'sad',
        description: 'Known as the "Joyful Bhairavi", this rāga combines melancholy with hope.',
        neuroscienceDescription: 'This rāga balances emotional processing by activating both the amygdala and prefrontal cortex, helping process sadness while maintaining emotional regulation.',
        youtubeUrl: '',
        spotifyUrl: 'https://open.spotify.com/playlist/1jS2fRwEbJXqfT8cN4pRL2?si=jQxjESr8Ri64id0_PhGc2w',
        featureTags: const [
          MusicalFeatureTags.moderateTempo,
          MusicalFeatureTags.archContours,
          MusicalFeatureTags.gentleGamaka,
          MusicalFeatureTags.consonantIntervals,
          MusicalFeatureTags.soothingTimbre,
          MusicalFeatureTags.midRegister,
        ],
        createdAt: now,
        updatedAt: now,
      ),
      Raga(
        id: 'raga_5',
        name: 'Shankarabharanam',
        emotion: 'unfocused',
        description: 'A bright, energizing morning rāga equivalent to the major scale, promoting clarity and alertness.',
        neuroscienceDescription: 'The clear, structured patterns of Shankarabharanam enhance beta brainwave activity, improving concentration and mental clarity. It activates the dorsolateral prefrontal cortex, key for sustained attention.',
        youtubeUrl: '',
        spotifyUrl: 'https://open.spotify.com/playlist/2C2KIJRrXDNaikfYvhumPA?si=5E5FQDARQMecUESuLGkfUw',
        featureTags: const [
          MusicalFeatureTags.moderateTempo,
          MusicalFeatureTags.steadyPulse,
          MusicalFeatureTags.predictablePhrases,
          MusicalFeatureTags.brightMajorish,
          MusicalFeatureTags.consonantIntervals,
          MusicalFeatureTags.midRegister,
        ],
        createdAt: now,
        updatedAt: now,
      ),
      Raga(
        id: 'raga_6',
        name: 'Kalyani',
        emotion: 'unfocused',
        description: 'A majestic rāga that brings mental clarity and determination.',
        neuroscienceDescription: 'Kalyani\'s ascending structure increases dopamine levels, enhancing motivation and cognitive function. Its tonal patterns synchronize neural oscillations for better focus.',
        youtubeUrl: '',
        spotifyUrl: 'https://open.spotify.com/playlist/1XNShEjGCHgq3VESPnZW0r?si=BfrgD1kuQ0CfY3cp2gpPYQ',
        featureTags: const [
          MusicalFeatureTags.moderateTempo,
          MusicalFeatureTags.ascendingContours,
          MusicalFeatureTags.brightMajorish,
          MusicalFeatureTags.gentleGamaka,
          MusicalFeatureTags.consonantIntervals,
        ],
        createdAt: now,
        updatedAt: now,
      ),
      Raga(
        id: 'raga_7',
        name: 'Kurinji',
        emotion: 'tired',
        description: 'Known for peace and relaxation, often rendered in the evening with gentle, soothing phrases.',
        neuroscienceDescription: 'Kurinji’s calm, predictable contours and lower‑register emphasis support parasympathetic activation and restful alpha activity—ideal when you’re tired and seeking serene restoration without drowsiness.',
        youtubeUrl: '',
        spotifyUrl: 'https://open.spotify.com/playlist/5ODrPzNBS3WoRYIn4SZBs9?si=1OM-IbY_Ruqk4wTKJ67NNg',
        featureTags: const [
          MusicalFeatureTags.slowTempo,
          MusicalFeatureTags.steadyPulse,
          MusicalFeatureTags.predictablePhrases,
          MusicalFeatureTags.downwardContours,
          MusicalFeatureTags.lowerRegister,
          MusicalFeatureTags.soothingTimbre,
          MusicalFeatureTags.gentleGamaka,
          MusicalFeatureTags.minimalOrnamentation,
        ],
        createdAt: now,
        updatedAt: now,
      ),
      Raga(
        id: 'raga_8',
        name: 'Revagupti',
        emotion: 'tired',
        description: 'A rare, gentle rāga known for its restorative properties.',
        neuroscienceDescription: 'Revagupti enhances parasympathetic activity, lowering heart rate and blood pressure. It promotes deep relaxation while maintaining gentle alertness.',
        youtubeUrl: '',
        spotifyUrl: 'https://open.spotify.com/playlist/3d3x1DFtV6xy0MG9MozbuO?si=xTGwQc9YRoqPeEzkD_paEQ',
        featureTags: const [
          MusicalFeatureTags.pentatonic,
          MusicalFeatureTags.slowTempo,
          MusicalFeatureTags.sparseRhythm,
          MusicalFeatureTags.predictablePhrases,
          MusicalFeatureTags.minimalOrnamentation,
          MusicalFeatureTags.soothingTimbre,
        ],
        createdAt: now,
        updatedAt: now,
      ),
      Raga(
        id: 'raga_9',
        name: 'Hamsadhwani',
        emotion: 'happy',
        description: 'A bright, cheerful rāga that radiates joy and positive energy.',
        neuroscienceDescription: 'The uplifting melodies of Hamsadhwani trigger endorphin release, amplifying feelings of joy. Its fast-paced patterns activate motor cortex and encourage movement.',
        youtubeUrl: '',
        spotifyUrl: 'https://open.spotify.com/playlist/1FrHUS4Ad1gSkaldr4gvmd?si=aXpj0NRKTRCSkbghaIv_tg',
        featureTags: const [
          MusicalFeatureTags.moderateTempo,
          MusicalFeatureTags.ascendingContours,
          MusicalFeatureTags.brightMajorish,
          MusicalFeatureTags.steadyPulse,
          MusicalFeatureTags.gentleGamaka,
        ],
        createdAt: now,
        updatedAt: now,
      ),
      Raga(
        id: 'raga_10',
        name: 'Mohanam',
        emotion: 'happy',
        description: 'A delightful pentatonic rāga that captivates with its beauty and simplicity.',
        neuroscienceDescription: 'Mohanam\'s harmonious structure enhances oxytocin production, promoting feelings of contentment and social bonding. Its patterns synchronize with natural circadian rhythms.',
        youtubeUrl: '',
        spotifyUrl: 'https://open.spotify.com/playlist/4BBmpkGd9qMXtuw4DDMnpg?si=v3k2P-z4Qq64WYio53NQDA',
        featureTags: const [
          MusicalFeatureTags.pentatonic,
          MusicalFeatureTags.archContours,
          MusicalFeatureTags.brightMajorish,
          MusicalFeatureTags.steadyPulse,
          MusicalFeatureTags.moderateTempo,
        ],
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
