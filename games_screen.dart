import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  static const List<_GameData> _games = [
    _GameData(
      emoji: '🎯',
      title: '2048',
      description: 'Merge tiles and reach 2048. Great for focus and logic!',
      benefit: 'Improves focus',
      color: Color(0xFFFF6B6B),
      url: 'https://play2048.co',
    ),
    _GameData(
      emoji: '♟️',
      title: 'Chess',
      description: 'Play chess online against AI. Sharpens strategic thinking.',
      benefit: 'Strategic thinking',
      color: Color(0xFF6B5CF6),
      url: 'https://www.chess.com/play/computer',
    ),
    _GameData(
      emoji: '🔤',
      title: 'Wordle',
      description: 'Guess a 5-letter word in 6 tries. Perfect brain warmup!',
      benefit: 'Vocabulary boost',
      color: Color(0xFF00C896),
      url: 'https://www.nytimes.com/games/wordle/index.html',
    ),
    _GameData(
      emoji: '🧩',
      title: 'Sudoku',
      description: 'Fill the grid with numbers. Excellent for logical thinking.',
      benefit: 'Logical reasoning',
      color: Color(0xFF3D5AF1),
      url: 'https://sudoku.com',
    ),
    _GameData(
      emoji: '🧠',
      title: 'Lumosity Brain Training',
      description: 'Science-backed brain training games designed for students.',
      benefit: 'Memory & attention',
      color: Color(0xFFFFB800),
      url: 'https://www.lumosity.com/en/',
    ),
    _GameData(
      emoji: '🃏',
      title: 'Memory Card Game',
      description: 'Match pairs of cards to test and improve your memory.',
      benefit: 'Memory training',
      color: Color(0xFFFF6B9D),
      url: 'https://www.helpfulgames.com/subjects/brain-training/memory.html',
    ),
    _GameData(
      emoji: '🌊',
      title: 'Calm - Breathing Exercise',
      description:
          'Guided breathing and mindfulness to de-stress before studying.',
      benefit: 'Stress relief',
      color: Color(0xFF00D4B4),
      url: 'https://www.calm.com',
    ),
    _GameData(
      emoji: '🔢',
      title: 'Math Riddles',
      description: 'Fun math puzzles and riddles to keep your mind sharp.',
      benefit: 'Math skills',
      color: Color(0xFFFF8C42),
      url: 'https://www.mathplayground.com',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎮 Mind Games'),
        backgroundColor: AppColors.gamesColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFB800), Color(0xFFFF6B6B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Take a Break! 🌟',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(
                    'Playing brain games for 10–15 minutes helps reset your focus. Study better after a mental break!',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.9), fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('Recommended Games',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            const Text('Tap any game to open it',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 14),

            // Game cards
            ...List.generate(
              _games.length,
              (i) => _GameCard(game: _games[i]),
            ),

            // Study advice
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accent.withOpacity(0.4)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('💡 Pro Tip',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          fontSize: 15)),
                  SizedBox(height: 6),
                  Text(
                    'Research shows that short brain-game breaks (10–15 min) between study sessions can boost memory retention by up to 20%. Don\'t study for more than 90 minutes without a break!',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _GameData {
  final String emoji;
  final String title;
  final String description;
  final String benefit;
  final Color color;
  final String url;

  const _GameData({
    required this.emoji,
    required this.title,
    required this.description,
    required this.benefit,
    required this.color,
    required this.url,
  });
}

class _GameCard extends StatelessWidget {
  final _GameData game;

  const _GameCard({required this.game});

  Future<void> _launch() async {
    final uri = Uri.parse(game.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launch,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: game.color.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: game.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(game.emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(game.title,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: game.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(game.benefit,
                            style: TextStyle(
                                fontSize: 10,
                                color: game.color,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(game.description,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12, height: 1.4)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: game.color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}
