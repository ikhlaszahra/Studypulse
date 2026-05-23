import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/app_colors.dart';
import '../../services/firestore_service.dart';
import '../../widgets/custom_widgets.dart';
import 'quiz_play_screen.dart';

class QuizListScreen extends StatefulWidget {
  const QuizListScreen({super.key});

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  final _fs = FirestoreService();

  void _showAddQuizDialog() {
    final titleCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();
    final List<Map<String, dynamic>> questions = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddQuizSheet(
        titleCtrl: titleCtrl,
        subjectCtrl: subjectCtrl,
        onSave: (title, subject, qs) async {
          if (title.isEmpty || qs.isEmpty) return;
          await _fs.addQuiz({
            'title': title,
            'subject': subject,
            'questions': qs,
            'questionCount': qs.length,
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📝 My Quizzes'),
        backgroundColor: AppColors.quizColor,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddQuizDialog,
        backgroundColor: AppColors.quizColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Quiz', style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fs.getQuizzes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz_outlined,
                      size: 72, color: AppColors.quizColor.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  const Text('No quizzes yet!',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  const Text('Tap + to create your first quiz',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final qCount = data['questionCount'] ?? 0;
              return _QuizCard(
                title: data['title'] ?? 'Untitled',
                subject: data['subject'] ?? '',
                questionCount: qCount,
                onPlay: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizPlayScreen(
                      quizId: docs[i].id,
                      title: data['title'],
                      questions:
                          List<Map<String, dynamic>>.from(data['questions']),
                    ),
                  ),
                ),
                onDelete: () => _fs.deleteQuiz(docs[i].id),
              );
            },
          );
        },
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final String title;
  final String subject;
  final int questionCount;
  final VoidCallback onPlay;
  final VoidCallback onDelete;

  const _QuizCard({
    required this.title,
    required this.subject,
    required this.questionCount,
    required this.onPlay,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.quizColor.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 3))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.quizColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.quiz_rounded,
              color: AppColors.quizColor, size: 26),
        ),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        subtitle: Text('$subject  •  $questionCount questions',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.play_circle_rounded,
                  color: AppColors.quizColor, size: 32),
              onPressed: onPlay,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: AppColors.error, size: 22),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Add Quiz Bottom Sheet ─────────────────────────────────────────────────────
class _AddQuizSheet extends StatefulWidget {
  final TextEditingController titleCtrl;
  final TextEditingController subjectCtrl;
  final Function(String, String, List<Map<String, dynamic>>) onSave;

  const _AddQuizSheet({
    required this.titleCtrl,
    required this.subjectCtrl,
    required this.onSave,
  });

  @override
  State<_AddQuizSheet> createState() => _AddQuizSheetState();
}

class _AddQuizSheetState extends State<_AddQuizSheet> {
  final List<Map<String, dynamic>> _questions = [];
  final _qCtrl = TextEditingController();
  final List<TextEditingController> _optionCtrls =
      List.generate(4, (_) => TextEditingController());
  int _correctIndex = 0;

  void _addQuestion() {
    if (_qCtrl.text.isEmpty) return;
    setState(() {
      _questions.add({
        'question': _qCtrl.text,
        'options': _optionCtrls.map((c) => c.text).toList(),
        'correctIndex': _correctIndex,
      });
      _qCtrl.clear();
      for (final c in _optionCtrls) {
        c.clear();
      }
      _correctIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Create Quiz',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            CustomTextField(
                label: 'Quiz Title', controller: widget.titleCtrl),
            const SizedBox(height: 12),
            CustomTextField(
                label: 'Subject', controller: widget.subjectCtrl),
            const Divider(height: 28),
            const Text('Add a Question',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            CustomTextField(label: 'Question', controller: _qCtrl),
            const SizedBox(height: 8),
            ...List.generate(4, (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Radio<int>(
                        value: i,
                        groupValue: _correctIndex,
                        onChanged: (v) =>
                            setState(() => _correctIndex = v!),
                        activeColor: AppColors.success,
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _optionCtrls[i],
                          decoration: InputDecoration(
                            labelText: 'Option ${i + 1}',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            CustomButton(
              text: 'Add Question',
              onPressed: _addQuestion,
              color: AppColors.primary.withOpacity(0.8),
            ),
            if (_questions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('${_questions.length} question(s) added ✅',
                  style: const TextStyle(color: AppColors.success)),
            ],
            const SizedBox(height: 16),
            CustomButton(
              text: 'Save Quiz',
              onPressed: () {
                widget.onSave(widget.titleCtrl.text,
                    widget.subjectCtrl.text, _questions);
                Navigator.pop(context);
              },
              icon: Icons.save_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
