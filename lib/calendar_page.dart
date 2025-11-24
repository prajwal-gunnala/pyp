import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:pyph/services/wellness_service.dart';
import 'package:pyph/chatbot.dart';
import 'package:pyph/micro_tasks_page.dart';
import 'package:pyph/diary_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DailyActivity? _selectedDayActivity;
  bool _isLoading = false;
  Map<DateTime, bool> _activityDates = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadActivityDates();
    _loadSelectedDayActivity();
  }

  /// Load all dates with activity in current month
  Future<void> _loadActivityDates() async {
    setState(() => _isLoading = true);
    
    final dates = await WellnessService.getActivityDatesInMonth(
      _focusedDay.year,
      _focusedDay.month,
    );
    
    final Map<DateTime, bool> activityMap = {};
    for (var date in dates) {
      activityMap[DateTime(date.year, date.month, date.day)] = true;
    }
    
    setState(() {
      _activityDates = activityMap;
      _isLoading = false;
    });
  }

  /// Load activity for selected day
  Future<void> _loadSelectedDayActivity() async {
    if (_selectedDay == null) return;
    
    setState(() => _isLoading = true);
    
    final activity = await WellnessService.getActivityForDate(_selectedDay!);
    
    setState(() {
      _selectedDayActivity = activity;
      _isLoading = false;
    });
  }

  /// Check if date has activity
  bool _hasActivity(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _activityDates[normalized] == true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EDE0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3EDE0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Calendar',
          style: GoogleFonts.abrilFatface(
            fontSize: 22,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: () {
              _loadActivityDates();
              _loadSelectedDayActivity();
            },
          ),
        ],
      ),
      body: _isLoading && _selectedDayActivity == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Calendar Widget
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      calendarFormat: CalendarFormat.month,
                      startingDayOfWeek: StartingDayOfWeek.sunday,
                      
                      // Styling
                      calendarStyle: CalendarStyle(
                        // Today
                        todayDecoration: BoxDecoration(
                          color: const Color(0xFF8B7355),
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        
                        // Selected day
                        selectedDecoration: BoxDecoration(
                          color: const Color(0xFF5D4E37),
                          shape: BoxShape.circle,
                        ),
                        selectedTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        
                        // Markers (activity dots)
                        markerDecoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                        markersMaxCount: 1,
                        
                        // Default days
                        defaultTextStyle: GoogleFonts.lato(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        
                        // Weekend days
                        weekendTextStyle: GoogleFonts.lato(
                          fontSize: 14,
                          color: const Color(0xFF8B7355),
                        ),
                        
                        // Outside days
                        outsideTextStyle: GoogleFonts.lato(
                          fontSize: 14,
                          color: Colors.black26,
                        ),
                      ),
                      
                      // Header style
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: GoogleFonts.abrilFatface(
                          fontSize: 18,
                          color: const Color(0xFF5D4E37),
                        ),
                        leftChevronIcon: const Icon(
                          Icons.chevron_left,
                          color: Color(0xFF5D4E37),
                        ),
                        rightChevronIcon: const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF5D4E37),
                        ),
                      ),
                      
                      // Day of week style
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: GoogleFonts.lato(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF5D4E37),
                        ),
                        weekendStyle: GoogleFonts.lato(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8B7355),
                        ),
                      ),
                      
                      // Event markers
                      eventLoader: (day) {
                        return _hasActivity(day) ? [day] : [];
                      },
                      
                      // Callbacks
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                        _loadSelectedDayActivity();
                      },
                      
                      onPageChanged: (focusedDay) {
                        setState(() {
                          _focusedDay = focusedDay;
                        });
                        _loadActivityDates();
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Selected Day Summary
                  if (_selectedDayActivity != null)
                    _buildDaySummary(_selectedDayActivity!)
                  else
                    _buildEmptyState(),
                ],
              ),
            ),
    );
  }

  /// Build day summary panel
  Widget _buildDaySummary(DailyActivity activity) {
    final score = activity.calculateScore();
    final rating = activity.getRating();
    final hasActivity = activity.hasActivity();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header
          Text(
            _formatSelectedDate(),
            style: GoogleFonts.abrilFatface(
              fontSize: 18,
              color: const Color(0xFF5D4E37),
            ),
          ),
          
          const SizedBox(height: 16),
          
          if (!hasActivity)
            _buildNoActivityMessage()
          else ...[
            // Wellness Score
            Row(
              children: [
                Text(
                  '📊 Wellness Score: ',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '$score%',
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(score),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: score / 100,
                minHeight: 12,
                backgroundColor: const Color(0xFFE0D5C7),
                valueColor: AlwaysStoppedAnimation(_getScoreColor(score)),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Rating
            Text(
              rating,
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _getScoreColor(score),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Activity summary
            _buildActivitySummary(activity),
            
            const SizedBox(height: 20),
            
            // View Details button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to DayDetailPage
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Detailed view coming soon!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D4E37),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View Details',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 20),
          
          // Quick Actions
          _buildQuickActions(),
        ],
      ),
    );
  }

  /// Build activity summary
  Widget _buildActivitySummary(DailyActivity activity) {
    return Column(
      children: [
        _buildSummaryRow(
          icon: '💬',
          label: 'Conversations:',
          value: '${activity.conversations.length}',
        ),
        const SizedBox(height: 12),
        _buildSummaryRow(
          icon: '✅',
          label: 'Tasks Completed:',
          value: '${activity.tasksCompleted.values.where((c) => c).length}/${activity.tasksCompleted.length}',
        ),
        const SizedBox(height: 12),
        _buildSummaryRow(
          icon: '📖',
          label: 'Journal Entry:',
          value: activity.journalEntry != null ? '✓' : '✗',
        ),
      ],
    );
  }

  /// Build summary row
  Widget _buildSummaryRow({
    required String icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5D4E37),
          ),
        ),
      ],
    );
  }

  /// Build quick actions
  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EDE0),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Add',
            style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5D4E37),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickActionButton(
                label: '+ Task',
                icon: Icons.check_circle_outline,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MicroTasksPage()),
                  );
                },
              ),
              _buildQuickActionButton(
                label: '+ Journal',
                icon: Icons.book_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DiaryPage()),
                  );
                },
              ),
              _buildQuickActionButton(
                label: '💬 Chat',
                icon: Icons.chat_bubble_outline,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatBot()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build quick action button
  Widget _buildQuickActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8B7355),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: label.startsWith('+') || label.startsWith('💬')
          ? Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            )
          : Icon(icon, size: 20),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '📭',
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          Text(
            'No activity on this day',
            style: GoogleFonts.abrilFatface(
              fontSize: 18,
              color: const Color(0xFF5D4E37),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your wellness journey today',
            style: GoogleFonts.lato(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          _buildQuickActions(),
        ],
      ),
    );
  }

  /// Build no activity message
  Widget _buildNoActivityMessage() {
    return Column(
      children: [
        const Text(
          '📭',
          style: TextStyle(fontSize: 48),
        ),
        const SizedBox(height: 16),
        Text(
          'No activity on this day',
          style: GoogleFonts.lato(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  /// Format selected date
  String _formatSelectedDate() {
    if (_selectedDay == null) return '';
    
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${months[_selectedDay!.month - 1]} ${_selectedDay!.day}, ${_selectedDay!.year}';
  }

  /// Get score color
  Color _getScoreColor(int score) {
    if (score >= 90) return const Color(0xFF4CAF50); // Green
    if (score >= 75) return const Color(0xFF8BC34A); // Light Green
    if (score >= 60) return const Color(0xFFC107); // Yellow
    if (score >= 40) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFF44336); // Red
  }
}
