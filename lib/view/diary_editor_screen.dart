import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/diary_entry.dart';
import '../widgets/common_widgets.dart';
import '../widgets/mood_chip.dart';

class DiaryEditorScreen extends StatefulWidget {
  final DiaryEntry? entry;

  const DiaryEditorScreen({super.key, this.entry});

  @override
  State<DiaryEditorScreen> createState() => _DiaryEditorScreenState();
}

class _DiaryEditorScreenState extends State<DiaryEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late DateTime _selectedDate;
  String _selectedMood = 'Neutral';

  final List<String> _moods = [
    'Happy',
    'Sad',
    'Neutral',
    'Excited',
    'Grateful',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title);
    _contentController = TextEditingController(text: widget.entry?.content);
    _selectedDate = widget.entry?.date ?? DateTime.now();
    _selectedMood = widget.entry?.mood ?? 'Neutral';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine title for navigation bar
    final displayDate = DiaryTheme.formatFullDate(_selectedDate);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey[100],
            child: IconButton(
              icon: const Icon(
                Icons.close_rounded,
                color: Colors.black87,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          displayDate,
          style: GoogleFonts.outfit(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: _saveEntry,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mood Selector Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _moods.map((mood) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: MoodChip(
                              label: mood,
                              isSelected: _selectedMood == mood,
                              onTap: () {
                                setState(() {
                                  _selectedMood = mood;
                                });
                              },
                              color: _getMoodColor(mood),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title Input
                    TextField(
                      controller: _titleController,
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                        height: 1.2,
                      ),
                      maxLines: null, // Allow wrapping
                      decoration: InputDecoration(
                        hintText: 'Title your day...',
                        hintStyle: GoogleFonts.outfit(
                          color: Colors.grey[300],
                          fontWeight: FontWeight.bold,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Content Input
                    TextField(
                      controller: _contentController,
                      maxLines: null,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        height: 1.6,
                        color: const Color(0xFF334155),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Start writing...',
                        hintStyle: GoogleFonts.inter(
                          color: Colors.grey[300],
                          height: 1.6,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                      ),
                    ),
                    const SizedBox(height: 100), // Bottom padding
                  ],
                ),
              ),
            ),

            // Bottom Toolbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[100]!)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    offset: const Offset(0, -4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _pickDateTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DiaryTheme.formatTime(_selectedDate),
                            style: GoogleFonts.inter(
                              color: Colors.grey[700],
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {}, // Placeholder for image attachment
                        icon: Icon(
                          Icons.image_outlined,
                          color: Colors.grey[400],
                        ),
                      ),
                      IconButton(
                        onPressed: () {}, // Placeholder for voice note
                        icon: Icon(
                          Icons.mic_none_rounded,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case "Happy":
        return Colors.orange;
      case "Sad":
        return Colors.blue;
      case "Excited":
        return Colors.purple;
      case "Neutral":
        return Colors.grey;
      default:
        return const Color(0xFF4F46E5);
    }
  }

  Future<void> _pickDateTime() async {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Change Date & Time",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.dateAndTime,
                initialDateTime: _selectedDate,
                onDateTimeChanged: (val) {
                  setState(() {
                    _selectedDate = val;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveEntry() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    final entry = DiaryEntry(
      id: widget.entry?.id,
      title: title.isEmpty ? 'Untitled' : title,
      content: content,
      mood: _selectedMood,
      date: _selectedDate,
      updatedAt: DateTime.now(),
      isFavorite: widget.entry?.isFavorite ?? false,
    );

    Navigator.of(context).pop(entry);
  }
}
