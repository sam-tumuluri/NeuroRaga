import 'package:flutter/foundation.dart';

/// Describes the underlying regulation goal for a given emotional state.
class NeuralNeed {
  final String id; // e.g., 'downregulate_sympathetic'
  final String title; // e.g., 'Down‑regulate sympathetic arousal'
  final String description;
  final List<String> featureTags; // musical feature tags that tend to satisfy this need

  const NeuralNeed({
    required this.id,
    required this.title,
    required this.description,
    required this.featureTags,
  });
}

/// Central registry for musical feature tags and their human‑friendly labels.
/// Use these tags to annotate Ragas and to express needs.
class MusicalFeatureTags {
  // Tempo / rhythm
  static const slowTempo = 'slow-tempo';
  static const moderateTempo = 'moderate-tempo';
  static const steadyPulse = 'steady-pulse';
  static const predictablePhrases = 'predictable-phrases';
  static const sparseRhythm = 'sparse-rhythm';
  static const gentleSwing = 'gentle-swing';

  // Melodic contour / register
  static const downwardContours = 'downward-contours';
  static const ascendingContours = 'ascending-contours';
  static const archContours = 'arch-contours';
  static const lowerRegister = 'lower-register';
  static const midRegister = 'mid-register';

  // Scale / harmony feel
  static const pentatonic = 'pentatonic';
  static const brightMajorish = 'bright-majorish'; // shuddha feel / major‑adjacent
  static const consonantIntervals = 'consonant-intervals';
  static const minimalDissonance = 'minimal-dissonance';

  // Ornamentation / timbre
  static const minimalOrnamentation = 'minimal-ornamentation';
  static const gentleGamaka = 'gentle-gamaka';
  static const richOrnamentation = 'rich-ornamentation';
  static const soothingTimbre = 'soothing-timbre';

  static const Map<String, String> labels = {
    slowTempo: 'Slow tempo',
    moderateTempo: 'Moderate tempo',
    steadyPulse: 'Steady pulse',
    predictablePhrases: 'Predictable phrases',
    sparseRhythm: 'Sparse rhythm',
    gentleSwing: 'Gentle swing',

    downwardContours: 'Downward contours',
    ascendingContours: 'Ascending contours',
    archContours: 'Arch contours',
    lowerRegister: 'Lower register',
    midRegister: 'Mid register',

    pentatonic: 'Pentatonic',
    brightMajorish: 'Bright/majorish feel',
    consonantIntervals: 'Consonant intervals',
    minimalDissonance: 'Minimal dissonance',

    minimalOrnamentation: 'Minimal ornamentation',
    gentleGamaka: 'Gentle gamaka',
    richOrnamentation: 'Rich ornamentation',
    soothingTimbre: 'Soothing timbre',
  };

  static String labelFor(String tag) => labels[tag] ?? tag;
}
