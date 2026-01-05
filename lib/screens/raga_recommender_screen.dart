import 'package:flutter/material.dart';
import 'package:neurorga/models/raga.dart';
import 'package:neurorga/models/music_cognition.dart';
import 'package:neurorga/services/raga_service.dart';
import 'package:neurorga/screens/audio_player_screen.dart';

class RagaRecommenderScreen extends StatefulWidget {
  final String emotion;

  const RagaRecommenderScreen({super.key, required this.emotion});

  @override
  State<RagaRecommenderScreen> createState() => _RagaRecommenderScreenState();
}

class _RagaRecommenderScreenState extends State<RagaRecommenderScreen> {
  final _ragaService = RagaService();
  List<Raga> _ragas = [];
  NeuralNeed? _need;
  late List<String> _featureTags;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _featureTags = [];
    _loadPipeline();
  }

  Future<void> _loadPipeline() async {
    setState(() => _isLoading = true);
    final need = _ragaService.getNeuralNeedForEmotion(widget.emotion);
    final ragas = await _ragaService.recommendRagasForEmotion(widget.emotion);
    setState(() {
      _need = need;
      _featureTags = need.featureTags;
      _ragas = ragas;
      _isLoading = false;
    });
  }

  String _getEmotionTitle() {
    switch (widget.emotion) {
      case 'anxious':
        return 'Feeling Anxious';
      case 'sad':
        return 'Feeling Sad';
      case 'unfocused':
        return 'Feeling Unfocused';
      case 'tired':
        return 'Feeling Tired';
      case 'happy':
        return 'Feeling Happy';
      default:
        return 'Recommendations';
    }
  }

  IconData _getEmotionIcon() {
    switch (widget.emotion) {
      case 'anxious':
        return Icons.psychology_outlined;
      case 'sad':
        return Icons.cloud_outlined;
      case 'unfocused':
        return Icons.center_focus_strong_outlined;
      case 'tired':
        return Icons.bedtime_outlined;
      case 'happy':
        return Icons.sentiment_satisfied_alt_outlined;
      default:
        return Icons.music_note_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getEmotionTitle()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ragas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_getEmotionIcon(), size: 64, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'No rāgas available yet',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Check back soon for recommendations',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PipelineHeader(emotion: widget.emotion, icon: _getEmotionIcon(), need: _need),
                        const SizedBox(height: 16),
                        _FeatureChips(title: 'Musical features to satisfy this need', featureTags: _featureTags),
                        const SizedBox(height: 24),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _ragas.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final r = _ragas[index];
                            final matched = r.featureTags.where((t) => _featureTags.contains(t)).toList();
                            return RagaCard(raga: r, emotion: widget.emotion, matchedFeatureTags: matched);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class RagaCard extends StatelessWidget {
  final Raga raga;
  final String emotion;
  final List<String>? matchedFeatureTags;

  const RagaCard({super.key, required this.raga, required this.emotion, this.matchedFeatureTags});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AudioPlayerScreen(raga: raga, emotion: emotion),
          ),
        ),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.music_note,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          raga.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.play_circle_outline,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Tap to listen',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                raga.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if ((matchedFeatureTags ?? const []).isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: matchedFeatureTags!
                      .map((tag) => Chip(
                            label: Text(MusicalFeatureTags.labelFor(tag)),
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.6),
                            side: BorderSide.none,
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.science_outlined,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        raga.neuroscienceDescription,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PipelineHeader extends StatelessWidget {
  final String emotion;
  final IconData icon;
  final NeuralNeed? need;

  const _PipelineHeader({required this.emotion, required this.icon, required this.need});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Theme.of(context).colorScheme.primary,
          Theme.of(context).colorScheme.tertiary,
        ]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Emotion → Neural need → Features → Rāgas',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(_titleForEmotion(emotion),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.9))),
                  ],
                ),
              ),
            ],
          ),
          if (need != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.science_outlined, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(need!.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(need!.description, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.95))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _titleForEmotion(String e) {
    switch (e) {
      case 'anxious':
        return 'Feeling Anxious';
      case 'sad':
        return 'Feeling Sad';
      case 'unfocused':
        return 'Feeling Unfocused';
      case 'tired':
        return 'Feeling Tired';
      case 'happy':
        return 'Feeling Happy';
      default:
        return 'Recommendations';
    }
  }
}

class _FeatureChips extends StatelessWidget {
  final String title;
  final List<String> featureTags;

  const _FeatureChips({required this.title, required this.featureTags});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: featureTags
              .map((t) => Chip(
                    label: Text(MusicalFeatureTags.labelFor(t)),
                    side: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
