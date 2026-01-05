import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:neurorga/services/mood_service.dart';
import 'package:neurorga/services/auth_service.dart';
import 'package:neurorga/models/mood_entry.dart';
import 'package:intl/intl.dart';

class ProgressAnalyticsScreen extends StatefulWidget {
  const ProgressAnalyticsScreen({super.key});

  @override
  State<ProgressAnalyticsScreen> createState() => _ProgressAnalyticsScreenState();
}

class _ProgressAnalyticsScreenState extends State<ProgressAnalyticsScreen> {
  final _moodService = MoodService();
  final _authService = AuthService();
  List<MoodEntry> _entries = [];
  Map<String, double> _averages = {};
  Map<String, int> _emotionFrequency = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = _authService.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);
    
    final entries = await _moodService.getUserMoodEntries(user.uid);
    final averages = await _moodService.getAverageRatings(user.uid);
    final frequency = await _moodService.getEmotionFrequency(user.uid);

    setState(() {
      _entries = entries;
      _averages = averages;
      _emotionFrequency = frequency;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _entries.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            size: 80,
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No Data Yet',
                            style: Theme.of(context).textTheme.headlineMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Start listening to rāgas and rating your experiences to see your progress here.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📊 Your Progress',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Track your wellness journey',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Average Ratings',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: AverageCard(
                                title: 'Calmness',
                                value: _averages['calmness'] ?? 0.0,
                                icon: Icons.spa_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              )),
                              const SizedBox(width: 12),
                              Expanded(child: AverageCard(
                                title: 'Focus',
                                value: _averages['focus'] ?? 0.0,
                                icon: Icons.center_focus_strong_outlined,
                                color: Theme.of(context).colorScheme.secondary,
                              )),
                              const SizedBox(width: 12),
                              Expanded(child: AverageCard(
                                title: 'Happiness',
                                value: _averages['happiness'] ?? 0.0,
                                icon: Icons.sentiment_satisfied_alt_outlined,
                                color: Theme.of(context).colorScheme.tertiary,
                              )),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Rating Trends',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: SizedBox(
                                height: 250,
                                child: LineChart(
                                  LineChartData(
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      horizontalInterval: 1,
                                      getDrawingHorizontalLine: (value) => FlLine(
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                                        strokeWidth: 1,
                                      ),
                                    ),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          interval: 1,
                                          getTitlesWidget: (value, meta) => Text(
                                            value.toInt().toString(),
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                          reservedSize: 30,
                                        ),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            if (value.toInt() < 0 || value.toInt() >= _entries.length) {
                                              return const SizedBox.shrink();
                                            }
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: Text(
                                                DateFormat('M/d').format(_entries.reversed.toList()[value.toInt()].createdAt),
                                                style: Theme.of(context).textTheme.bodySmall,
                                              ),
                                            );
                                          },
                                          reservedSize: 30,
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    minY: 0,
                                    maxY: 5,
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: _entries.reversed.toList().asMap().entries.map((e) => FlSpot(
                                          e.key.toDouble(),
                                          e.value.calmnessRating.toDouble(),
                                        )).toList(),
                                        isCurved: true,
                                        color: Theme.of(context).colorScheme.primary,
                                        barWidth: 3,
                                        isStrokeCapRound: true,
                                        dotData: FlDotData(
                                          show: true,
                                          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                            radius: 4,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                        ),
                                      ),
                                      LineChartBarData(
                                        spots: _entries.reversed.toList().asMap().entries.map((e) => FlSpot(
                                          e.key.toDouble(),
                                          e.value.focusRating.toDouble(),
                                        )).toList(),
                                        isCurved: true,
                                        color: Theme.of(context).colorScheme.secondary,
                                        barWidth: 3,
                                        isStrokeCapRound: true,
                                        dotData: FlDotData(
                                          show: true,
                                          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                            radius: 4,
                                            color: Theme.of(context).colorScheme.secondary,
                                          ),
                                        ),
                                      ),
                                      LineChartBarData(
                                        spots: _entries.reversed.toList().asMap().entries.map((e) => FlSpot(
                                          e.key.toDouble(),
                                          e.value.happinessRating.toDouble(),
                                        )).toList(),
                                        isCurved: true,
                                        color: Theme.of(context).colorScheme.tertiary,
                                        barWidth: 3,
                                        isStrokeCapRound: true,
                                        dotData: FlDotData(
                                          show: true,
                                          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                            radius: 4,
                                            color: Theme.of(context).colorScheme.tertiary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              LegendItem(
                                color: Theme.of(context).colorScheme.primary,
                                label: 'Calmness',
                              ),
                              const SizedBox(width: 16),
                              LegendItem(
                                color: Theme.of(context).colorScheme.secondary,
                                label: 'Focus',
                              ),
                              const SizedBox(width: 16),
                              LegendItem(
                                color: Theme.of(context).colorScheme.tertiary,
                                label: 'Happiness',
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Recent Sessions',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _entries.take(5).length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final entry = _entries[index];
                              return SessionCard(entry: entry);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}

class AverageCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color color;

  const AverageCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value.toStringAsFixed(1),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class SessionCard extends StatelessWidget {
  final MoodEntry entry;

  const SessionCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.music_note,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.ragaName,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM d, yyyy').format(entry.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text(
                      '${entry.calmnessRating}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${entry.focusRating}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${entry.happinessRating}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.tertiary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
