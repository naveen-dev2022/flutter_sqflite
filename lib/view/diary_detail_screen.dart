import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/view_state.dart';
import '../models/diary_entry.dart';
import '../viewmodels/diary_viewmodel.dart';
import 'diary_editor_screen.dart';

class DiaryDetailScreen extends StatefulWidget {
  final DiaryEntry entry;

  const DiaryDetailScreen({super.key, required this.entry});

  @override
  State<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<DiaryViewModel>();
      // We don't necessarily need to reload all entries if we passed one,
      // but keeping it for sync.
      if (vm.entries.isEmpty) {
        vm.loadEntries();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Selector<DiaryViewModel, ViewState>(
        selector: (_, vm) => vm.state,
        builder: (context, state, _) {
          return _buildContent(context);
        },
      ),
    );
  }

  // -----------------------------------------------------------
  Widget _buildContent(BuildContext context) {
    return Selector<DiaryViewModel, DiaryEntry?>(
      selector: (_, vm) => vm.getEntryById(widget.entry.id!),
      builder: (_, liveEntry, _) {
        if (liveEntry == null) {
          // Handle deletion gracefully
          return const Center(child: Text("Entry deleted"));
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [_buildAppBar(context, liveEntry), _buildBody(liveEntry)],
        );
      },
    );
  }

  // -----------------------------------------------------------
  Widget _buildAppBar(BuildContext context, DiaryEntry liveEntry) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      expandedHeight: 100,
      floating: false,
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.grey[50],
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.black87,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      actions: [
        Selector<DiaryViewModel, bool>(
          selector: (_, vm) =>
              vm.getEntryById(liveEntry.id!)?.isFavorite ?? false,
          builder: (_, isFav, __) {
            return IconButton(
              icon: Icon(
                isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                color: isFav ? Colors.amber : Colors.grey,
                size: 26,
              ),
              onPressed: () {
                context.read<DiaryViewModel>().toggleFavorite(liveEntry);
              },
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => _editEntry(context, liveEntry),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // -----------------------------------------------------------
  Widget _buildBody(DiaryEntry liveEntry) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meta Row
            Row(
              children: [
                Text(
                  DateFormat(
                    'MMMM d, yyyy',
                  ).format(liveEntry.date).toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.0,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getMoodColor(liveEntry.mood).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    liveEntry.mood,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getMoodColor(liveEntry.mood),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              liveEntry.title,
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                height: 1.2,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 32),

            // Content
            Text(
              liveEntry.content,
              style: GoogleFonts.inter(
                fontSize: 18,
                height: 1.8,
                color: const Color(0xFF334155),
              ),
            ),

            const SizedBox(height: 80),
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

  // -----------------------------------------------------------
  void _editEntry(BuildContext context, DiaryEntry liveEntry) async {
    final updatedEntry = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DiaryEditorScreen(entry: liveEntry)),
    );

    if (updatedEntry != null) {
      if (context.mounted) {
        await context.read<DiaryViewModel>().updateEntry(updatedEntry);
      }
    }
  }
}
