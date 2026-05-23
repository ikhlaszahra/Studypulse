import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  // ══════════════════════════════════════════════════════════
  //  USER PROFILE
  // ══════════════════════════════════════════════════════════

  Future<Map<String, dynamic>?> getUserProfile() async {
    final doc = await _db.collection('users').doc(_uid).get();
    return doc.data();
  }

  // ══════════════════════════════════════════════════════════
  //  QUIZZES
  // ══════════════════════════════════════════════════════════

  CollectionReference get _quizzes =>
      _db.collection('users').doc(_uid).collection('quizzes');

  Future<void> addQuiz(Map<String, dynamic> quiz) async {
    await _quizzes.add({
      ...quiz,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getQuizzes() {
    return _quizzes.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> deleteQuiz(String quizId) async {
    await _quizzes.doc(quizId).delete();
  }

  Future<void> saveQuizResult({
    required String quizId,
    required int score,
    required int total,
  }) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('quiz_results')
        .add({
      'quizId': quizId,
      'score': score,
      'total': total,
      'percentage': (score / total * 100).round(),
      'takenAt': FieldValue.serverTimestamp(),
    });

    // Update total quizzes count
    await _db.collection('users').doc(_uid).update({
      'totalQuizzes': FieldValue.increment(1),
    });
  }

  // ══════════════════════════════════════════════════════════
  //  TIMETABLE
  // ══════════════════════════════════════════════════════════

  CollectionReference get _timetable =>
      _db.collection('users').doc(_uid).collection('timetable');

  Future<void> addTimetableEntry(Map<String, dynamic> entry) async {
    await _timetable.add(entry);
  }

  Stream<QuerySnapshot> getTimetableEntries() {
    return _timetable.snapshots();
  }

  Future<void> deleteTimetableEntry(String entryId) async {
    await _timetable.doc(entryId).delete();
  }

  Future<void> updateTimetableEntry(
      String entryId, Map<String, dynamic> data) async {
    await _timetable.doc(entryId).update(data);
  }

  // ══════════════════════════════════════════════════════════
  //  CHAT HISTORY (optional persistence)
  // ══════════════════════════════════════════════════════════

  Future<void> saveChatMessage({
    required String message,
    required String sender, // 'user' or 'ai'
  }) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('chat_history')
        .add({
      'message': message,
      'sender': sender,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getChatHistory() {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('chat_history')
        .orderBy('timestamp')
        .snapshots();
  }
}
