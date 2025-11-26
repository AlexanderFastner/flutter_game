import 'package:flutter/material.dart';

import '../services/high_score_service.dart';
import '../services/theme_service.dart';
import '../widgets/themed_background.dart';

class HighScoresScreen extends StatefulWidget {
  const HighScoresScreen({super.key});

  @override
  State<HighScoresScreen> createState() => _HighScoresScreenState();
}

class _HighScoresScreenState extends State<HighScoresScreen>
    with SingleTickerProviderStateMixin {
  static const List<String> difficulties = ['Easy', 'Medium', 'Hard'];
  final HighScoreService _service = HighScoreService.instance;
  final Map<String, List<int>> _scores = {};
  bool _isLoading = true;
  final ThemeService _themeService = ThemeService.instance;
  String _themeId = AppThemeIds.neoTokyoSkyline;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _loadScores();
  }

  Future<void> _loadTheme() async {
    final themeId = await _themeService.getCurrentThemeId();
    if (!mounted) return;
    setState(() {
      _themeId = themeId;
    });
  }

  Future<void> _loadScores() async {
    setState(() {
      _isLoading = true;
    });

    for (final difficulty in difficulties) {
      _scores[difficulty] = await _service.getScores(difficulty);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: difficulties.length,
      child: Scaffold(
        body: buildThemedBackground(
          _themeId,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return const LinearGradient(
                              colors: [
                                Color(0xFFFF00A8),
                                Color(0xFFFFA800),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds);
                          },
                          child: const Text(
                            'High Scores',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // balance row visually
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TabBar(
                    labelStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    labelColor: const Color(0xFFFFA800),
                    unselectedLabelColor: Colors.white70,
                    indicator: const UnderlineTabIndicator(
                      borderSide: BorderSide(
                        color: Color(0xFFFFA800),
                        width: 3,
                      ),
                    ),
                    tabs: difficulties
                        .map((difficulty) => Tab(text: difficulty))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : TabBarView(
                          children: difficulties
                              .map((difficulty) => _ScoresList(
                                    difficulty: difficulty,
                                    scores: _scores[difficulty] ?? const [],
                                    onRefresh: _loadScores,
                                  ))
                              .toList(),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoresList extends StatelessWidget {
  final String difficulty;
  final List<int> scores;
  final Future<void> Function() onRefresh;

  const _ScoresList({
    required this.difficulty,
    required this.scores,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (scores.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 80),
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: Colors.blue.shade300,
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'No scores yet for $difficulty.\nPlay a game to set a record!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: scores.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final rank = index + 1;
          final score = scores[index];

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade900,
              foregroundColor: Colors.white,
              child: Text(
                '$rank',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              'Score: $score',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              rank == 1 ? 'New personal best!' : 'Top $rank finish',
              style: const TextStyle(color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}

