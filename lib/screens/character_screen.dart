import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quest_provider.dart';

class CharacterScreen extends StatefulWidget {
  const CharacterScreen({Key? key}) : super(key: key);

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen>
    with TickerProviderStateMixin {
  String _currentAnimation = 'idle';

  // 스프라이트 시트 설정 (필요에 따라 값 수정)
  static const int _frameCount = 8;
  static const double? _frameWidth = null; // null이면 이미지 폭/프레임수 자동 계산
  static const double? _frameHeight = null; // null이면 이미지 전체 높이 사용
  static const double _fps = 12;

  // 기본적으로 하나의 스프라이트 시트를 사용.
  // 필요하면 다른 파일명으로 교체해도 됨.
  static const String _idleSpritePath =
      'assets/animations/character_sprite.png';
  static const String _celebrationSpritePath =
      'assets/animations/character_sprite.png';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAnimation();
    });
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
    final spritePath = _currentAnimation == 'celebration'
        ? _celebrationSpritePath
        : _idleSpritePath;

    return _SpriteAnimation(
      spritePath: spritePath,
      frameCount: _frameCount,
      frameWidth: _frameWidth,
      frameHeight: _frameHeight,
      fps: _fps,
    );
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

class _SpriteAnimation extends StatefulWidget {
  final String spritePath;
  final int frameCount;
  final double? frameWidth;
  final double? frameHeight;
  final double fps;

  const _SpriteAnimation({
    required this.spritePath,
    required this.frameCount,
    required this.frameWidth,
    required this.frameHeight,
    required this.fps,
  });

  @override
  State<_SpriteAnimation> createState() => _SpriteAnimationState();
}

class _SpriteAnimationState extends State<_SpriteAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  ui.Image? _image;
  ImageStream? _imageStream;
  ImageStreamListener? _imageListener;

  @override
  void initState() {
    super.initState();
    final animationDurationMs =
        (1000 * widget.frameCount / widget.fps).round();
    final int safeDurationMs =
        math.max(1, math.min(60000, animationDurationMs));
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: safeDurationMs),
    )..repeat();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant _SpriteAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.spritePath != widget.spritePath) {
      _loadImage(forceReload: true);
    }
  }

  void _loadImage({bool forceReload = false}) {
    if (_imageListener != null && _imageStream != null) {
      _imageStream!.removeListener(_imageListener!);
    }
    if (forceReload) {
      _image = null;
    }

    final stream =
        AssetImage(widget.spritePath).resolve(const ImageConfiguration());
    _imageListener = ImageStreamListener((imageInfo, _) {
      setState(() {
        _image = imageInfo.image;
      });
    }, onError: (dynamic _, __) {
      // 에셋을 찾지 못했을 경우 무시하고 플레이스홀더 표시
      setState(() {
        _image = null;
      });
    });
    stream.addListener(_imageListener!);
    _imageStream = stream;
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_imageListener != null && _imageStream != null) {
      _imageStream!.removeListener(_imageListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_image == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            '스프라이트 이미지를 추가하면\n애니메이션이 표시됩니다',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      );
    }

    final double frameWidth =
        widget.frameWidth ?? (_image!.width / widget.frameCount);
    final double frameHeight = widget.frameHeight ?? _image!.height.toDouble();

    return SizedBox(
      width: frameWidth,
      height: frameHeight,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final currentFrame =
              ((_controller.value * widget.frameCount).floor()) %
                  widget.frameCount;
          return CustomPaint(
            painter: _SpritePainter(
              image: _image!,
              frameCount: widget.frameCount,
              frameWidth: frameWidth,
              frameHeight: frameHeight,
              currentFrame: currentFrame,
            ),
          );
        },
      ),
    );
  }
}

class _SpritePainter extends CustomPainter {
  final ui.Image image;
  final int frameCount;
  final double frameWidth;
  final double frameHeight;
  final int currentFrame;

  _SpritePainter({
    required this.image,
    required this.frameCount,
    required this.frameWidth,
    required this.frameHeight,
    required this.currentFrame,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final src = Rect.fromLTWH(
      frameWidth * currentFrame,
      0,
      frameWidth,
      frameHeight,
    );
    final dst = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(image, src, dst, Paint());
  }

  @override
  bool shouldRepaint(covariant _SpritePainter oldDelegate) {
    return oldDelegate.currentFrame != currentFrame ||
        oldDelegate.image != image;
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

