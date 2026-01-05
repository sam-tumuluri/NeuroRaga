import 'package:flutter/material.dart';
import 'package:neurorga/models/raga.dart';
import 'package:neurorga/models/mood_entry.dart';
import 'package:neurorga/services/mood_service.dart';
import 'package:neurorga/services/auth_service.dart';

class MoodTrackerScreen extends StatefulWidget {
  final Raga raga;
  final String emotion;

  const MoodTrackerScreen({super.key, required this.raga, required this.emotion});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  int _calmnessRating = 3;
  int _focusRating = 3;
  int _happinessRating = 3;
  bool _isSubmitting = false;
  final _moodService = MoodService();
  final _authService = AuthService();

  Future<void> _submitRatings() async {
    final user = _authService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to save ratings')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final entry = MoodEntry(
        id: '${user.uid}_${DateTime.now().millisecondsSinceEpoch}',
        userId: user.uid,
        ragaId: widget.raga.id,
        ragaName: widget.raga.name,
        emotionBefore: widget.emotion,
        calmnessRating: _calmnessRating,
        focusRating: _focusRating,
        happinessRating: _happinessRating,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _moodService.addMoodEntry(entry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rating saved! Thank you for your feedback.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving rating: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Your Experience'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.music_note,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.raga.name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'How do you feel after listening?',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              RatingSection(
                title: 'Calmness',
                icon: Icons.spa_outlined,
                rating: _calmnessRating,
                onChanged: (value) => setState(() => _calmnessRating = value),
              ),
              const SizedBox(height: 24),
              RatingSection(
                title: 'Focus',
                icon: Icons.center_focus_strong_outlined,
                rating: _focusRating,
                onChanged: (value) => setState(() => _focusRating = value),
              ),
              const SizedBox(height: 24),
              RatingSection(
                title: 'Happiness',
                icon: Icons.sentiment_satisfied_alt_outlined,
                rating: _happinessRating,
                onChanged: (value) => setState(() => _happinessRating = value),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRatings,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Ratings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RatingSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final int rating;
  final ValueChanged<int> onChanged;

  const RatingSection({
    super.key,
    required this.title,
    required this.icon,
    required this.rating,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                final value = index + 1;
                return GestureDetector(
                  onTap: () => onChanged(value),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: rating >= value
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '$value',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: rating >= value
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Low',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  'High',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
