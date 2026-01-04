import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/view_state.dart';
import '../models/diary_entry.dart';
import '../viewmodels/diary_viewmodel.dart';
import '../widgets/common_widgets.dart';
import '../widgets/mood_chip.dart';
import 'diary_editor_screen.dart';
import 'diary_detail_screen.dart';
import '../widgets/diary_entry_card.dart';
import 'package:google_fonts/google_fonts.dart';

class DiaryHomeScreen extends StatefulWidget {
  const DiaryHomeScreen({super.key});

  @override
  State<DiaryHomeScreen> createState() => _DiaryHomeScreenState();
}

class _DiaryHomeScreenState extends State<DiaryHomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<DiaryViewModel>();

      vm.loadEntries();
      vm.addListener(() {
        if (vm.errorMessage.isNotEmpty) {
          AppSnackBar.show(context, vm.errorMessage);
          vm.clearError(); // to avoid showing repeatedly
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fallback
      body: Stack(
        children: [
          // 1. Background
          _buildBackground(),

          // 2. Main Content
          CustomScrollView(
            slivers: [
              _buildAppBar(),
              _buildSearchBar(),
              _buildMoodChips(),
              const SliverPadding(padding: EdgeInsets.only(top: 8)),
              _buildContent(),
              const SliverPadding(
                padding: EdgeInsets.only(bottom: 100),
              ), // Space for FAB
            ],
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        backgroundColor: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
        shape: const StadiumBorder(),
        extendedPadding: EdgeInsets.zero,
        // Remove default padding
        label: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF6366F1),
                Color(0xFF8B5CF6),
              ], // Indigo to Violet
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: const [
              Icon(Icons.edit_outlined, color: Colors.white),
              SizedBox(width: 8),
              Text(
                "New Entry",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ---------------------------
  // BACKGROUND
  // ---------------------------
  Widget _buildBackground() {
    return Stack(
      children: [
        // Base light
        Container(color: const Color(0xFFF8F9FE)),

        // Top Left Orb (Blue-ish)
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF93C5FD).withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Bottom Right Orb (Purple-ish)
        Positioned(
          bottom: -50,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFC4B5FD).withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Center-Left (Pink-ish)
        Positioned(
          top: 200,
          left: -50,
          child: Container(
            width: 300,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFBCFE8).withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------
  // APP BAR
  // ---------------------------
  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      // Fully transparent
      pinned: true,
      floating: false,
      expandedHeight: 160,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 20),
        expandedTitleScale: 1.2,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Welcome Back,',
              style: GoogleFonts.outfit(
                color: const Color(0xFF64748B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'My Journal',
              style: GoogleFonts.outfit(
                color: const Color(0xFF1E293B),
                fontWeight: FontWeight.w800,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Selector<DiaryViewModel, bool>(
          selector: (_, vm) => vm.showFavoritesOnly,
          builder: (context, isFavOnly, _) {
            return Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  isFavOnly ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: isFavOnly
                      ? Colors.amber.shade400
                      : const Color(0xFF64748B),
                  size: 24,
                ),
                onPressed: () =>
                    context.read<DiaryViewModel>().toggleFavoritesFilter(),
              ),
            );
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  // ---------------------------
  // SEARCH BAR
  // ---------------------------
  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Selector<DiaryViewModel, String>(
          selector: (_, vm) => vm.searchQuery,
          builder: (_, query, __) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E293B).withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) =>
                    context.read<DiaryViewModel>().setSearchQuery(value),
                decoration: InputDecoration(
                  hintText: "Search memories...",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(
                    CupertinoIcons.search,
                    color: Colors.grey[400],
                    size: 22,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------------------------
  // MOOD CHIPS
  // ---------------------------
  Widget _buildMoodChips() {
    final moods = ["All", "Happy", "Sad", "Neutral", "Excited"];

    return SliverToBoxAdapter(
      child: Selector<DiaryViewModel, String>(
        selector: (_, vm) => vm.moodFilter,
        builder: (_, filter, __) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: moods.map((mood) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: MoodChip(
                    label: mood,
                    isSelected: filter == mood,
                    onTap: () =>
                        context.read<DiaryViewModel>().setMoodFilter(mood),
                    color: _getMoodColor(mood),
                  ),
                );
              }).toList(),
            ),
          );
        },
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

  // ---------------------------
  // CONTENT
  // ---------------------------
  Widget _buildContent() {
    return Selector<DiaryViewModel, ViewState>(
      selector: (_, vm) => vm.state,
      builder: (_, state, _) {
        switch (state) {
          case ViewState.loading:
            return const SliverFillRemaining(
              child: Center(child: CupertinoActivityIndicator(radius: 16)),
            );

          case ViewState.empty:
            return _emptyState();

          case ViewState.success:
            return Selector<DiaryViewModel, List<DiaryEntry>>(
              selector: (_, vm) => vm.entries,
              builder: (_, entries, _) {
                if (entries.isEmpty) return _emptyState();

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final entry = entries[index];
                    return DiaryEntryCard(
                      entry: entry,
                      index: index, // Staggered animation index
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DiaryDetailScreen(entry: entry),
                          ),
                        );
                      },
                    );
                  }, childCount: entries.length),
                );
              },
            );

          default:
            return const SliverToBoxAdapter();
        }
      },
    );
  }

  Widget _emptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: 48,
                color: Colors.indigo.shade100,
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text(
              "No Memories Yet",
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Start writing (or typing) your journey!",
              style: TextStyle(color: Colors.blueGrey[400], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _openEditor(BuildContext context) async {
    final newEntry = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DiaryEditorScreen()),
    );

    if (newEntry != null) {
      if (context.mounted) {
        context.read<DiaryViewModel>().addEntry(newEntry);
      }
    }
  }
}
