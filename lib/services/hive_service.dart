import 'package:hive_flutter/hive_flutter.dart';
import '../models/quest.dart';

class HiveService {
  static const String boxName = 'quests';

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(QuestAdapter());
    }
    await Hive.openBox<Quest>(boxName);
  }

  Box<Quest> get _box => Hive.box<Quest>(boxName);

  List<Quest> getAll() => _box.values.toList();

  Future<void> add(Quest quest) async => _box.put(quest.id, quest);

  Future<void> update(Quest quest) async => quest.save();

  Future<void> delete(String id) async => _box.delete(id);

  Future<void> clear() async => _box.clear();
}
