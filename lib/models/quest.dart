import 'package:hive/hive.dart';

// part 'quest.g.dart';

@HiveType(typeId: 0)
class Quest extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool isDone;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime? scheduledDate;

  Quest({
    required this.id,
    required this.title,
    this.isDone = false,
    DateTime? createdAt,
    this.scheduledDate,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'isDone': isDone,
        'createdAt': createdAt.toIso8601String(),
        'scheduledDate': scheduledDate?.toIso8601String(),
      };

  factory Quest.fromMap(Map<String, dynamic> map) => Quest(
        id: map['id'],
        title: map['title'],
        isDone: map['isDone'] ?? false,
        createdAt: DateTime.parse(map['createdAt']),
        scheduledDate: map['scheduledDate'] != null
            ? DateTime.parse(map['scheduledDate'])
            : null,
      );
}

class QuestAdapter extends TypeAdapter<Quest> {
  @override
  final int typeId = 0;

  @override
  Quest read(BinaryReader reader) {
    final count = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < count; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return Quest(
      id: fields[0],
      title: fields[1],
      isDone: fields[2],
      createdAt: fields[3],
      scheduledDate: fields[4],
    );
  }

  @override
  void write(BinaryWriter writer, Quest obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.isDone)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.scheduledDate);
  }
}
