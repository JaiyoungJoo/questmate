import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/quest_provider.dart';
import '../services/auth_service.dart';
import '../widgets/quest_tile.dart';
import 'login_screen.dart';
import 'stats_screen.dart';
import 'character_screen.dart';

class HomeScreen extends StatefulWidget {
  final AuthService auth;

  const HomeScreen({Key? key, required this.auth}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final PageController _pageController = PageController();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuestProvider>().setSelectedDate(_selectedDay);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuestProvider>();
    final user = widget.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(user == null ? 'QuestMate (Guest)' : 'QuestMate - ${user.email}'),
        actions: [
          if (user == null)
            IconButton(
              icon: const Icon(Icons.login),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(auth: widget.auth),
                  ),
                );
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: widget.auth.signOut,
            )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TabIndicator(
                label: '할 일',
                icon: Icons.calendar_today,
                isSelected: _currentPage == 0,
                onTap: () {
                  _pageController.animateToPage(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
              _TabIndicator(
                label: '캐릭터',
                icon: Icons.face,
                isSelected: _currentPage == 1,
                onTap: () {
                  _pageController.animateToPage(
                    1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
              _TabIndicator(
                label: '통계',
                icon: Icons.analytics,
                isSelected: _currentPage == 2,
                onTap: () {
                  _pageController.animateToPage(
                    2,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                // 첫 번째 페이지: 할 일 관리
                _buildQuestPage(provider),
                // 두 번째 페이지: 캐릭터
                const CharacterScreen(),
                // 세 번째 페이지: 통계
                const StatsScreen(),
              ],
            ),
      bottomNavigationBar: _currentPage == 0
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: "새 퀘스트 입력…",
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (_controller.text.trim().isNotEmpty) {
                          provider.addQuest(
                            _controller.text.trim(),
                            scheduledDate: _selectedDay,
                          );
                          _controller.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildQuestPage(QuestProvider provider) {
    return Column(
      children: [
        // 달력 위젯
        TableCalendar<dynamic>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    provider.setSelectedDate(selectedDay);
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  eventLoader: (day) {
                    // 해당 날짜에 할 일이 있으면 표시
                    return provider.hasQuestOnDate(day) ? [1] : [];
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: Colors.indigo,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    outsideDaysVisible: false,
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                ),
                const Divider(height: 1),
                // 선택된 날짜 표시
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        _selectedDay != null
                            ? '${_selectedDay!.year}년 ${_selectedDay!.month}월 ${_selectedDay!.day}일'
                            : '날짜 선택',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      if (_selectedDay != null && !isSameDay(_selectedDay, DateTime.now()))
                        TextButton(
                          onPressed: () {
                            final today = DateTime.now();
                            setState(() {
                              _selectedDay = today;
                              _focusedDay = today;
                            });
                            provider.setSelectedDate(today);
                          },
                          child: const Text('오늘'),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // 퀘스트 목록
                Expanded(
                  child: provider.quests.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.task_alt, size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text(
                                '${_selectedDay != null ? _selectedDay!.month : ""}월 ${_selectedDay != null ? _selectedDay!.day : ""}일에 할 일이 없습니다',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          children: provider.quests
                              .map((q) => QuestTile(
                                    quest: q,
                                    onToggle: () => provider.toggleQuest(q),
                                    onDelete: () => provider.deleteQuest(q),
                                  ))
                              .toList(),
                        ),
                ),
      ],
    );
  }
}

class _TabIndicator extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabIndicator({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.indigo : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.indigo : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.indigo : Colors.grey,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
