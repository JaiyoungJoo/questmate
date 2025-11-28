import 'package:flutter/material.dart';
import '../models/quest.dart';

class QuestTile extends StatelessWidget {
  final Quest quest;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const QuestTile({
    Key? key,
    required this.quest,
    required this.onToggle,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(quest.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        leading: Checkbox(
          value: quest.isDone,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          quest.title,
          style: TextStyle(
            decoration: quest.isDone
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
