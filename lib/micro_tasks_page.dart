import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/micro_tasks_service.dart';

class MicroTasksPage extends StatefulWidget {
  const MicroTasksPage({Key? key}) : super(key: key);

  @override
  State<MicroTasksPage> createState() => _MicroTasksPageState();
}

class _MicroTasksPageState extends State<MicroTasksPage> {
  List<MicroTask> _tasks = [];
  bool _loading = true;
  int _completedCount = 0;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await MicroTasksService.getTodaysTasks();
    final stats = await MicroTasksService.getStats();
    
    if (mounted) {
      setState(() {
        _tasks = tasks;
        _completedCount = stats['completed'] ?? 0;
        _totalCount = stats['total'] ?? 0;
        _loading = false;
      });
    }
  }

  Future<void> _toggleTask(String taskId) async {
    await MicroTasksService.toggleTask(taskId);
    _loadTasks();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'physical':
        return Colors.green.shade400;
      case 'mental':
        return Colors.blue.shade400;
      case 'social':
        return Colors.purple.shade400;
      case 'self-care':
        return Colors.orange.shade400;
      default:
        return const Color(0xFF8B7355);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'physical':
        return Icons.directions_run;
      case 'mental':
        return Icons.psychology;
      case 'social':
        return Icons.people;
      case 'self-care':
        return Icons.spa;
      default:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EDE0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3EDE0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5D4E37)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Daily Tasks',
          style: GoogleFonts.abrilFatface(
            color: const Color(0xFF5D4E37),
            fontSize: 24,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF5D4E37),
              ),
            )
          : Column(
              children: [
                _buildProgressCard(),
                const SizedBox(height: 16),
                Expanded(child: _buildTasksList()),
              ],
            ),
    );
  }

  Widget _buildProgressCard() {
    final progress = _totalCount > 0 ? _completedCount / _totalCount : 0.0;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF5D4E37),
            const Color(0xFF8B7355),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Progress',
                    style: GoogleFonts.abrilFatface(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_completedCount of $_totalCount completed',
                    style: GoogleFonts.lato(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _completedCount == _totalCount && _totalCount > 0 ? '🎉' : '✨',
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          if (_completedCount == _totalCount && _totalCount > 0) ...[
            const SizedBox(height: 12),
            Text(
              'Amazing! All tasks completed! 🌟',
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTasksList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        final categoryColor = _getCategoryColor(task.category);
        final categoryIcon = _getCategoryIcon(task.category);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _toggleTask(task.id),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Checkbox
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: task.isCompleted
                              ? categoryColor
                              : const Color(0xFFDBC59C),
                          width: 2,
                        ),
                        color: task.isCompleted ? categoryColor : Colors.transparent,
                      ),
                      child: task.isCompleted
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    // Task content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: GoogleFonts.lato(
                              color: task.isCompleted
                                  ? const Color(0xFF8B7355)
                                  : const Color(0xFF5D4E37),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          if (task.description != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              task.description!,
                              style: GoogleFonts.lato(
                                color: const Color(0xFF8B7355),
                                fontSize: 14,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Category icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        categoryIcon,
                        color: categoryColor,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
