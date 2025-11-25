import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'services/diary_service.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  List<DiaryEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = await DiaryService.getEntries();
    if (mounted) {
      setState(() {
        _entries = entries;
        _loading = false;
      });
    }
  }

  void _showAddEntryDialog({DiaryEntry? editEntry}) {
    final isEditing = editEntry != null;
    final contentController = TextEditingController(text: editEntry?.content ?? '');
    String? selectedMood = editEntry?.mood;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFFF3EDE0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEditing ? 'Edit Entry' : 'New Entry',
            style: GoogleFonts.abrilFatface(
              color: const Color(0xFF5D4E37),
              fontSize: 24,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mood selector
                Text(
                  'How are you feeling?',
                  style: GoogleFonts.lato(
                    color: const Color(0xFF5D4E37),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildMoodChip('😊', 'happy', selectedMood, (mood) {
                      setDialogState(() => selectedMood = mood);
                    }),
                    _buildMoodChip('😌', 'calm', selectedMood, (mood) {
                      setDialogState(() => selectedMood = mood);
                    }),
                    _buildMoodChip('😔', 'sad', selectedMood, (mood) {
                      setDialogState(() => selectedMood = mood);
                    }),
                    _buildMoodChip('😰', 'anxious', selectedMood, (mood) {
                      setDialogState(() => selectedMood = mood);
                    }),
                    _buildMoodChip('😡', 'angry', selectedMood, (mood) {
                      setDialogState(() => selectedMood = mood);
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                // Entry text
                TextField(
                  controller: contentController,
                  maxLines: 8,
                  autofocus: true,
                  style: GoogleFonts.lato(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'What\'s on your mind?',
                    hintStyle: GoogleFonts.lato(
                      color: Colors.black38,
                      fontSize: 16,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.lato(
                  color: const Color(0xFF8B7355),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final content = contentController.text.trim();
                if (content.isEmpty) return;

                if (isEditing) {
                  await DiaryService.updateEntry(
                    id: editEntry.id,
                    content: content,
                    mood: selectedMood,
                  );
                } else {
                  await DiaryService.addEntry(
                    content: content,
                    mood: selectedMood,
                  );
                }

                if (!mounted) return;
                Navigator.pop(context);
                _loadEntries();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D4E37),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isEditing ? 'Update' : 'Save',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodChip(
    String emoji,
    String mood,
    String? selectedMood,
    Function(String?) onTap,
  ) {
    final isSelected = selectedMood == mood;
    return GestureDetector(
      onTap: () => onTap(isSelected ? null : mood),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5D4E37) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF5D4E37),
            width: 1.5,
          ),
        ),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  void _confirmDelete(DiaryEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF3EDE0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Entry?',
          style: GoogleFonts.abrilFatface(
            color: const Color(0xFF5D4E37),
            fontSize: 20,
          ),
        ),
        content: Text(
          'This entry will be permanently deleted.',
          style: GoogleFonts.lato(
            color: const Color(0xFF5D4E37),
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.lato(
                color: const Color(0xFF8B7355),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await DiaryService.deleteEntry(entry.id);
              if (!mounted) return;
              Navigator.pop(context);
              _loadEntries();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.lato(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMoodEmoji(String? mood) {
    switch (mood) {
      case 'happy':
        return '😊';
      case 'calm':
        return '😌';
      case 'sad':
        return '😔';
      case 'anxious':
        return '😰';
      case 'angry':
        return '😡';
      default:
        return '📝';
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
          'My Journal',
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
          : _entries.isEmpty
              ? _buildEmptyState()
              : _buildEntriesList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEntryDialog(),
        backgroundColor: const Color(0xFF5D4E37),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Write',
          style: GoogleFonts.lato(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.book_outlined,
                size: 64,
                color: Color(0xFF8B7355),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your journal is empty',
              style: GoogleFonts.abrilFatface(
                color: const Color(0xFF5D4E37),
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Writing helps process emotions and\ntrack your wellness journey',
              style: GoogleFonts.lato(
                color: const Color(0xFF8B7355),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntriesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        final entry = _entries[index];
        final dateFormat = DateFormat('MMM d, y');
        final timeFormat = DateFormat('h:mm a');
        
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
              onTap: () => _showAddEntryDialog(editEntry: entry),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _getMoodEmoji(entry.mood),
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dateFormat.format(entry.timestamp),
                                style: GoogleFonts.lato(
                                  color: const Color(0xFF5D4E37),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                timeFormat.format(entry.timestamp),
                                style: GoogleFonts.lato(
                                  color: const Color(0xFF8B7355),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: const Color(0xFF8B7355),
                          onPressed: () => _confirmDelete(entry),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      entry.content,
                      style: GoogleFonts.lato(
                        color: Colors.black87,
                        fontSize: 15,
                        height: 1.5,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
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
