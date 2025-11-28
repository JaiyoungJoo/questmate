import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quest_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuestProvider>();
    final allQuests = provider.allQuests;

    // 전체 통계 계산
    final totalQuests = allQuests.length;
    final completedQuests = allQuests.where((q) => q.isDone).length;
    final pendingQuests = totalQuests - completedQuests;
    final completionRate = totalQuests > 0 
        ? (completedQuests / totalQuests * 100).round() 
        : 0;

    return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text(
              '통계',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            // 통계 카드들
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: '전체',
                    value: totalQuests.toString(),
                    icon: Icons.list_alt,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: '완료',
                    value: completedQuests.toString(),
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: '진행중',
                    value: pendingQuests.toString(),
                    icon: Icons.pending,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: '완료율',
                    value: '$completionRate%',
                    icon: Icons.trending_up,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              '최근 할 일',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (allQuests.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.analytics_outlined, 
                           size: 64, 
                           color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        '아직 할 일이 없습니다',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...allQuests.take(5).map((quest) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        quest.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: quest.isDone ? Colors.green : Colors.grey,
                      ),
                      title: Text(
                        quest.title,
                        style: TextStyle(
                          decoration: quest.isDone 
                              ? TextDecoration.lineThrough 
                              : TextDecoration.none,
                        ),
                      ),
                      subtitle: Text(
                        quest.scheduledDate != null
                            ? '${quest.scheduledDate!.year}-${quest.scheduledDate!.month.toString().padLeft(2, '0')}-${quest.scheduledDate!.day.toString().padLeft(2, '0')}'
                            : '날짜 미지정',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  )),
          ],
        ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

