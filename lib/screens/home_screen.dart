import 'package:flutter/material.dart';
import 'package:neurorga/screens/raga_recommender_screen.dart';
import 'package:neurorga/screens/progress_analytics_screen.dart';
import 'package:neurorga/screens/learn_screen.dart';
import 'package:neurorga/services/auth_service.dart';
import 'package:neurorga/screens/auth/login_screen.dart';
import 'package:neurorga/services/backend_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _authService = AuthService();

  final List<Widget> _screens = [
    const EmotionSelectorScreen(),
    const ProgressAnalyticsScreen(),
    const LearnScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Learn',
          ),
        ],
      ),
    );
  }
}

class EmotionSelectorScreen extends StatelessWidget {
  const EmotionSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emotions = [
      EmotionCardData(
        emotion: 'anxious',
        title: 'Anxious',
        subtitle: 'Calm your racing thoughts',
        icon: Icons.psychology_outlined,
        gradient: const LinearGradient(
          colors: [Color(0xFF6B5FCF), Color(0xFF9B7FD9)],
        ),
      ),
      EmotionCardData(
        emotion: 'sad',
        title: 'Sad',
        subtitle: 'Lift your spirits',
        icon: Icons.cloud_outlined,
        gradient: const LinearGradient(
          colors: [Color(0xFF5E8DBF), Color(0xFF7FB6E8)],
        ),
      ),
      EmotionCardData(
        emotion: 'unfocused',
        title: 'Unfocused',
        subtitle: 'Sharpen your concentration',
        icon: Icons.center_focus_strong_outlined,
        gradient: const LinearGradient(
          colors: [Color(0xFF8B7FD9), Color(0xFFBDB1FF)],
        ),
      ),
      EmotionCardData(
        emotion: 'tired',
        title: 'Tired',
        subtitle: 'Restore your energy',
        icon: Icons.bedtime_outlined,
        gradient: const LinearGradient(
          colors: [Color(0xFF9B8FE3), Color(0xFFCDB8FF)],
        ),
      ),
      EmotionCardData(
        emotion: 'happy',
        title: 'Happy',
        subtitle: 'Amplify your joy',
        icon: Icons.sentiment_satisfied_alt_outlined,
        gradient: const LinearGradient(
          colors: [Color(0xFF7FB6E8), Color(0xFF8BB8E8)],
        ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🎵 NeuroRāga',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'How are you feeling today?',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    PopupMenuButton(
                      icon: const Icon(Icons.account_circle_outlined),
                      itemBuilder: (context) => [
                        if (BackendConfig.backendEnabled)
                          PopupMenuItem(
                            child: const Text('Sign Out'),
                            onTap: () async {
                              await AuthService().signOut();
                              if (context.mounted) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                                );
                              }
                            },
                          )
                        else
                          const PopupMenuItem(
                            enabled: false,
                            child: Text('Backend not connected'),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: emotions.length,
                  itemBuilder: (context, index) => EmotionCard(data: emotions[index]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EmotionCardData {
  final String emotion;
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;

  EmotionCardData({
    required this.emotion,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
  });
}

class EmotionCard extends StatelessWidget {
  final EmotionCardData data;

  const EmotionCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RagaRecommenderScreen(emotion: data.emotion),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: data.gradient,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, color: Colors.white, size: 32),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
