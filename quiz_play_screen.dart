import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/firestore_service.dart';

class QuizPlayScreen extends StatefulWidget {
  final String quizId;
  final String title;
  final List<Map<String, dynamic>> questions;

  const QuizPlayScreen({
    super.key,
    required this.quizId,
    required this.title,
    required this.questions,
  });

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  int _current = 0;
  int _score = 0;
  int? _selected;
  bool _answered = false;
  bool _finished = false;

  void _select(int index) {
    if (_answered) return;
    final correct = widget.questions[_current]['correctIndex'] as int;
    setState(() {
      _selected = index;
      _answered = true;
      if (index == correct) _score++;
    });
  }

  void _next() {
    if (_current < widget.questions.length - 1) {
      setState(() {
        _current++;
        _selected = null;
        _answered = false;
      });
    } else {
      _submitResult();
    }
  }

  Future<void> _submitResult() async {
    await FirestoreService().saveQuizResult(
      quizId: widget.quizId,
      score: _score,
      total: widget.questions.length,
    );
    setState(() => _finished = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) return _ResultScreen(score: _score, total: widget.questions.length);

    final q = widget.questions[_current];
    final options = List<String>.from(q['options']);
    final correct = q['correctIndex'] as int;
    final progress = (_current + 1) / widget.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.quizColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Progress
            Row(
              children: [
                Text('${_current + 1}/${widget.questions.length}',
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: AppColors.quizColor.withOpacity(0.15),
                      valueColor: const AlwaysStoppedAnimation(AppColors.quizColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('Score: $_score',
                    style: const TextStyle(
                        color: AppColors.success, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 30),

            // Question
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                q['question'],
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 24),

            // Options
            ...List.generate(options.length, (i) {
              Color bgColor = Colors.white;
              Color borderColor = const Color(0xFFE0E4F5);
              Color textColor = AppColors.textPrimary;

              if (_answered) {
                if (i == correct) {
                  bgColor = AppColors.success.withOpacity(0.12);
                  borderColor = AppColors.success;
                  textColor = AppColors.success;
                } else if (i == _selected && i != correct) {
                  bgColor = AppColors.error.withOpacity(0.1);
                  borderColor = AppColors.error;
                  textColor = AppColors.error;
                }
              } else if (_selected == i) {
                bgColor = AppColors.primary.withOpacity(0.08);
                borderColor = AppColors.primary;
              }

              return GestureDetector(
                onTap: () => _select(i),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: bgColor,
                    border: Border.all(color: borderColor, width: 1.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: borderColor.withOpacity(0.2),
                        child: Text(
                          String.fromCharCode(65 + i),
                          style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(options[i],
                            style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w500)),
                      ),
                      if (_answered && i == correct)
                        const Icon(Icons.check_circle,
                            color: AppColors.success, size: 22),
                      if (_answered && i == _selected && i != correct)
                        const Icon(Icons.cancel,
                            color: AppColors.error, size: 22),
                    ],
                  ),
                ),
              );
            }),

            const Spacer(),
            if (_answered)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.quizColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    _current == widget.questions.length - 1
                        ? 'Finish Quiz 🎉'
                        : 'Next Question →',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ResultScreen extends StatelessWidget {
  final int score;
  final int total;

  const _ResultScreen({required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = (score / total * 100).round();
    final emoji = pct >= 80
        ? '🏆'
        : pct >= 60
            ? '👍'
            : '💪';
    final msg = pct >= 80
        ? 'Excellent work!'
        : pct >= 60
            ? 'Good job!'
            : 'Keep practicing!';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 72)),
              const SizedBox(height: 16),
              Text(msg,
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              const SizedBox(height: 12),
              Text('$score / $total correct  ($pct%)',
                  style: TextStyle(
                      fontSize: 18, color: Colors.white.withOpacity(0.85))),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () =>
                    Navigator.popUntil(context, (r) => r.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Back to Home',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
