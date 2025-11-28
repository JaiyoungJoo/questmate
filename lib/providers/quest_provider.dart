import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/quest.dart';
import '../services/hive_service.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';

class QuestProvider extends ChangeNotifier {
  final HiveService hive;
  final FirebaseService firebase;
  final AuthService auth;

  List<Quest> _quests = [];
  bool _loading = false;
  DateTime? _selectedDate;

  QuestProvider({
    required this.hive,
    required this.firebase,
    required this.auth,
  });

  List<Quest> get quests {
    if (_selectedDate == null) {
      return _quests;
    }
    // 선택된 날짜의 퀘스트만 필터링 (날짜만 비교, 시간 제외)
    final selectedDateOnly = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
    );
    return _quests.where((quest) {
      if (quest.scheduledDate == null) return false;
      final questDateOnly = DateTime(
        quest.scheduledDate!.year,
        quest.scheduledDate!.month,
        quest.scheduledDate!.day,
      );
      return questDateOnly.isAtSameMomentAs(selectedDateOnly);
    }).toList();
  }

  // 전체 퀘스트 목록 (필터링 없음)
  List<Quest> get allQuests => _quests;

  bool get isLoading => _loading;
  DateTime? get selectedDate => _selectedDate;

  void setSelectedDate(DateTime? date) {
    _selectedDate = date;
    notifyListeners();
  }

  Future<void> init() async {
    await hive.init();

    _quests = hive.getAll();
    notifyListeners();

    auth.authStateChanges().listen((user) async {
      if (user == null) {
        _quests = hive.getAll();
        notifyListeners();
      } else {
        _loading = true;
        notifyListeners();

        try {
          // 로컬 데이터를 Firebase로 업로드
          for (final q in hive.getAll()) {
            await firebase.addQuest(user.uid, q);
          }

          // Firebase에서 최신 데이터 가져오기
          _quests = await firebase.fetchQuests(user.uid);
        } catch (e) {
          // Firebase 에러 시 로컬 데이터만 사용
          _quests = hive.getAll();
        }

        _loading = false;
        notifyListeners();
      }
    });
  }

  Future<void> addQuest(String title, {DateTime? scheduledDate}) async {
    final quest = Quest(
      id: const Uuid().v4(),
      title: title,
      scheduledDate: scheduledDate,
    );
    final user = auth.currentUser;

    await hive.add(quest);

    if (user != null) {
      try {
        await firebase.addQuest(user.uid, quest);
        _quests = await firebase.fetchQuests(user.uid);
      } catch (e) {
        // Firebase 에러 시 로컬 데이터만 사용
        _quests = hive.getAll();
      }
    } else {
      _quests = hive.getAll();
    }

    notifyListeners();
  }

  // 특정 날짜에 할 일이 있는지 확인
  bool hasQuestOnDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return _quests.any((quest) {
      if (quest.scheduledDate == null) return false;
      final questDateOnly = DateTime(
        quest.scheduledDate!.year,
        quest.scheduledDate!.month,
        quest.scheduledDate!.day,
      );
      return questDateOnly.isAtSameMomentAs(dateOnly);
    });
  }

  Future<void> toggleQuest(Quest quest) async {
    quest.isDone = !quest.isDone;
    await hive.update(quest);

    final user = auth.currentUser;
    if (user != null) {
      try {
        await firebase.updateQuest(user.uid, quest);
        _quests = await firebase.fetchQuests(user.uid);
      } catch (e) {
        // Firebase 에러 시 로컬 데이터만 사용
        _quests = hive.getAll();
      }
    } else {
      _quests = hive.getAll();
    }

    notifyListeners();
  }

  Future<void> deleteQuest(Quest quest) async {
    await hive.delete(quest.id);

    final user = auth.currentUser;
    if (user != null) {
      try {
        await firebase.deleteQuest(quest.id);
        _quests = await firebase.fetchQuests(user.uid);
      } catch (e) {
        // Firebase 에러 시 로컬 데이터만 사용
        _quests = hive.getAll();
      }
    } else {
      _quests = hive.getAll();
    }
    notifyListeners();
  }
}
