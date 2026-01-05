import 'package:flutter/material.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final articles = [
      ArticleData(
        title: 'The Science of Music and Emotions',
        subtitle: 'How music affects your brain',
        icon: Icons.science_outlined,
        content: '''Music has a profound impact on the brain, activating multiple neural networks simultaneously. When we listen to music, it triggers the release of dopamine, a neurotransmitter associated with pleasure and reward.

Research shows that different types of music can influence our emotional state, heart rate, and even immune system function. The limbic system, which includes the amygdala and hippocampus, processes the emotional content of music.

Carnatic music, with its complex melodic structures and rhythmic patterns, creates unique neural responses that can enhance cognitive function and emotional well-being.''',
      ),
      ArticleData(
        title: 'Understanding Rāgas',
        subtitle: 'Ancient melodies for modern minds',
        icon: Icons.music_note_outlined,
        content: '''Rāgas are melodic frameworks in Indian classical music, each with specific rules for note progression and emotional expression. Each rāga is traditionally associated with particular times of day, seasons, and emotional states.

The systematic application of notes (swaras) in a rāga creates specific patterns that resonate with our neural pathways. This is why certain rāgas are prescribed for particular moods or times.

Modern neuroscience research validates what ancient practitioners knew: rāgas can systematically influence our emotional and cognitive states through their unique tonal structures.''',
      ),
      ArticleData(
        title: 'Brainwaves and Music',
        subtitle: 'The frequency of relaxation',
        icon: Icons.waves_outlined,
        content: '''Our brain operates at different frequencies, producing various types of brainwaves. Music can influence these patterns:

• Beta waves (14-30 Hz): Alert, focused state
• Alpha waves (8-14 Hz): Relaxed, calm awareness
• Theta waves (4-8 Hz): Deep meditation, creativity
• Delta waves (0.5-4 Hz): Deep sleep, healing

Slow, melodic music like many Carnatic rāgas promotes alpha and theta wave activity, facilitating relaxation and stress reduction. Fast, rhythmic patterns can enhance beta waves, improving focus and alertness.''',
      ),
      ArticleData(
        title: 'The Neuroscience of Calm',
        subtitle: 'How music reduces stress',
        icon: Icons.spa_outlined,
        content: '''When we experience stress, our body releases cortisol, the stress hormone. Listening to calming music can significantly reduce cortisol levels while increasing the production of serotonin and oxytocin, promoting feelings of well-being.

Music activates the parasympathetic nervous system, which controls our "rest and digest" response. This physiological shift lowers heart rate, blood pressure, and muscle tension.

Slow-tempo rāgas with gradual, descending phrases are particularly effective at triggering this relaxation response, making them ideal for anxiety management.''',
      ),
      ArticleData(
        title: 'Music and Memory',
        subtitle: 'Enhancing cognitive function',
        icon: Icons.psychology_outlined,
        content: '''Music has a unique ability to enhance memory and cognitive function. The hippocampus, our brain's memory center, shows increased activity when we engage with music.

Research indicates that musical training and regular music listening can improve:
• Working memory
• Pattern recognition
• Spatial reasoning
• Language processing

Carnatic music's complex melodic patterns provide excellent mental exercise, potentially offering cognitive benefits similar to learning a new language or playing an instrument.''',
      ),
      ArticleData(
        title: 'The Mozart Effect and Beyond',
        subtitle: 'Music for focus and productivity',
        icon: Icons.lightbulb_outline,
        content: '''The "Mozart Effect" suggested that classical music could temporarily enhance spatial-temporal reasoning. While the original claims were overstated, research confirms that music can improve focus and productivity.

Instrumental music without lyrics is particularly effective for tasks requiring concentration, as it provides stimulation without linguistic distraction. The structured, mathematical patterns in Carnatic music can help synchronize neural oscillations, enhancing cognitive performance.

For optimal focus, choose rāgas with moderate tempo and clear, organized melodic structures.''',
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📚 Learn',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Explore the science behind the music',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 32),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: articles.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) => ArticleCard(article: articles[index]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ArticleData {
  final String title;
  final String subtitle;
  final IconData icon;
  final String content;

  ArticleData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.content,
  });
}

class ArticleCard extends StatelessWidget {
  final ArticleData article;

  const ArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(article: article),
          ),
        ),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  article.icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
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
        ),
      ),
    );
  }
}

class ArticleDetailScreen extends StatelessWidget {
  final ArticleData article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.tertiary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(article.icon, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.title,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            article.subtitle,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                article.content,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
