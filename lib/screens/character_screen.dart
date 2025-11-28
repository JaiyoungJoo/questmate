import 'package:flutter/material.dart';
// Lottie 애니메이션 파일을 추가하면 주석 해제
// import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../providers/quest_provider.dart';

class CharacterScreen extends StatefulWidget {
  const CharacterScreen({Key? key}) : super(key: key);

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen>
    with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _celebrationController;
  String _currentAnimation = 'idle';

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(vsync: this);
    _celebrationController = AnimationController(vsync: this);
    
    // 완료율에 따라 애니메이션 변경을 위한 리스너
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAnimation();
    });
  }

  @override
  void dispose() {
    _idleController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  void _updateAnimation() {
    final provider = context.read<QuestProvider>();
    final allQuests = provider.allQuests;
    final completedQuests = allQuests.where((q) => q.isDone).length;
    final completionRate = allQuests.isNotEmpty
        ? (completedQuests / allQuests.length * 100).round()
        : 0;

    // 완료율이 높으면 축하 애니메이션
    if (completionRate >= 80 && _currentAnimation != 'celebration') {
      setState(() {
        _currentAnimation = 'celebration';
      });
    } else if (completionRate < 80 && _currentAnimation != 'idle') {
      setState(() {
        _currentAnimation = 'idle';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuestProvider>();
    final allQuests = provider.allQuests;
    final completedQuests = allQuests.where((q) => q.isDone).length;
    final totalQuests = allQuests.length;
    final completionRate = totalQuests > 0
        ? (completedQuests / totalQuests * 100).round()
        : 0;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          // 캐릭터 애니메이션 영역
          Container(
            height: 300,
            width: 300,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: _buildCharacterAnimation(),
            ),
          ),
          const SizedBox(height: 32),
          // 캐릭터 정보
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                Text(
                  '나의 캐릭터',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                // 레벨 표시
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.indigo[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '레벨 ${_calculateLevel(completionRate)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '$completionRate% 완료',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.indigo[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // 경험치 바
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: completionRate / 100,
                          minHeight: 12,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.indigo[400]!,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // 통계 카드
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.check_circle,
                        value: completedQuests.toString(),
                        label: '완료',
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.pending,
                        value: (totalQuests - completedQuests).toString(),
                        label: '진행중',
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // 응원 메시지
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.red[300]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getMotivationalMessage(completionRate),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCharacterAnimation() {
    // Lottie 애니메이션을 사용하는 경우
    // assets 폴더에 lottie 파일이 있어야 함
    
    // 임시로 간단한 애니메이션 위젯 사용
    // 실제로는 Lottie.asset('assets/animations/character_idle.json') 사용
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Lottie 파일이 없을 경우를 대비한 플레이스홀더
        Icon(
          Icons.sentiment_satisfied_alt,
          size: 120,
          color: Colors.indigo[300],
        ),
        const SizedBox(height: 16),
        Text(
          '캐릭터 애니메이션',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Lottie 파일을 추가하면\n애니메이션이 표시됩니다',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
    
    // Lottie 파일이 있는 경우 아래 코드 사용:
    /*
    if (_currentAnimation == 'idle') {
      return Lottie.asset(
        'assets/animations/character_idle.json',
        controller: _idleController,
        onLoaded: (composition) {
          _idleController
            ..duration = composition.duration
            ..repeat();
        },
      );
    } else {
      return Lottie.asset(
        'assets/animations/character_celebration.json',
        controller: _celebrationController,
        onLoaded: (composition) {
          _celebrationController
            ..duration = composition.duration
            ..repeat();
        },
      );
    }
    */
  }

  int _calculateLevel(int completionRate) {
    // 완료율에 따라 레벨 계산
    if (completionRate >= 90) return 5;
    if (completionRate >= 70) return 4;
    if (completionRate >= 50) return 3;
    if (completionRate >= 30) return 2;
    return 1;
  }

  String _getMotivationalMessage(int completionRate) {
    if (completionRate >= 90) {
      return '완벽해요! 계속 이렇게 화이팅!';
    } else if (completionRate >= 70) {
      return '잘하고 있어요! 조금만 더 힘내세요!';
    } else if (completionRate >= 50) {
      return '절반 이상 완료했어요! 좋아요!';
    } else if (completionRate >= 30) {
      return '시작이 반이에요! 화이팅!';
    } else {
      return '오늘도 할 일을 하나씩 완료해봐요!';
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

