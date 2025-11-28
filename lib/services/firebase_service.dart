import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quest.dart';

class FirebaseService {
  final bool isFirebaseEnabled;
  CollectionReference? _questsCollection;

  FirebaseService({this.isFirebaseEnabled = false}) {
    if (isFirebaseEnabled) {
      _questsCollection = FirebaseFirestore.instance.collection('quests');
    }
  }

  Future<List<Quest>> fetchQuests(String uid) async {
    if (!isFirebaseEnabled || _questsCollection == null) {
      return [];
    }

    try {
      final snapshot = await _questsCollection!
          .where('uid', isEqualTo: uid)
          .orderBy('createdAt')
          .get();

      return snapshot.docs
          .map((d) => Quest.fromMap(Map<String, dynamic>.from(d.data() as Map)))
          .toList();
    } catch (e) {
      // Firebase 에러 시 빈 리스트 반환 (로컬 데이터만 사용)
      return [];
    }
  }

  Future<void> addQuest(String uid, Quest quest) async {
    if (!isFirebaseEnabled || _questsCollection == null) return;

    try {
      await _questsCollection!.doc(quest.id).set({
        'uid': uid,
        ...quest.toMap(),
      });
    } catch (e) {
      // Firebase 에러는 무시 (로컬 저장은 이미 완료됨)
    }
  }

  Future<void> updateQuest(String uid, Quest quest) async {
    if (!isFirebaseEnabled || _questsCollection == null) return;

    try {
      await _questsCollection!.doc(quest.id).update({
        'title': quest.title,
        'isDone': quest.isDone,
        'createdAt': quest.createdAt.toIso8601String(),
        'scheduledDate': quest.scheduledDate?.toIso8601String(),
      });
    } catch (e) {
      // Firebase 에러는 무시 (로컬 저장은 이미 완료됨)
    }
  }

  Future<void> deleteQuest(String id) async {
    if (!isFirebaseEnabled || _questsCollection == null) return;

    try {
      await _questsCollection!.doc(id).delete();
    } catch (e) {
      // Firebase 에러는 무시 (로컬 삭제는 이미 완료됨)
    }
  }
}
