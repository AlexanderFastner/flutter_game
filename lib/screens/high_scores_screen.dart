import 'package:flutter/material.dart';

import '../services/high_score_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadScores();
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
        appBar: AppBar(
          title: const Text('High Scores'),
          backgroundColor: Colors.blue.shade900,
          foregroundColor: Colors.white,
          bottom: TabBar(
            labelStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            labelColor: Colors.orange.shade300,
            unselectedLabelColor: Colors.white70,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                color: Colors.orange.shade300,
                width: 4,
              ),
              insets: const EdgeInsets.symmetric(horizontal: 24),
            ),
            tabs: difficulties
                .map((difficulty) => Tab(text: difficulty))
                .toList(),
          ),
        ),
        body: _isLoading
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

