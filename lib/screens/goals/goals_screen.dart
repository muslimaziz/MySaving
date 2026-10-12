import 'package:flutter/material.dart';

import '../../models/goal.dart';
import '../../models/goal_summary.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_icons.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/target_card.dart';
import 'goal_detail_screen.dart';
import 'goal_form_screen.dart';

/// Halaman Target ala desain:
/// kartu ringkasan kuning + filter (Semua/Aktif/Selesai) + daftar target.
class GoalsScreen extends StatefulWidget {
  final int dataRevision;

  const GoalsScreen({super.key, this.dataRevision = 0});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

enum _Filter { all, active, done }

class _GoalsScreenState extends State<GoalsScreen> {
  _Filter _filter = _Filter.all;
  late Future<List<GoalSummary>> _futureSummaries;

  @override
  void initState() {
    super.initState();
    _futureSummaries = GoalSummary.loadAll();
  }

  @override
  void didUpdateWidget(covariant GoalsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dataRevision != widget.dataRevision) _refresh();
  }

  void _refresh() {
    setState(() {
      _futureSummaries = GoalSummary.loadAll();
    });
  }

  Future<void> _pullToRefresh() async {
    final next = GoalSummary.loadAll();
    setState(() {
      _futureSummaries = next;
    });
    try {
      await next;
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data target gagal diperbarui.')),
      );
    }
  }

  Future<void> _openCreateGoal() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GoalFormScreen()),
    );
    if (mounted) _refresh();
  }

  Future<void> _openDetail(Goal goal) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GoalDetailScreen(goal: goal)),
    );
    if (mounted) _refresh();
  }

  List<GoalSummary> _filterList(List<GoalSummary> all) {
    return all.where((summary) {
      return switch (_filter) {
        _Filter.all => true,
        _Filter.active => !summary.completed,
        _Filter.done => summary.completed,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          PageHeader(
            title: 'Target Saya',
            right: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _openCreateGoal,
                  child: Center(
                    child: AppIcons.fromAsset(
                      AppIcons.add,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<GoalSummary>>(
              future: _futureSummaries,
              builder: (context, snapshot) {
                final summaries = snapshot.data ?? [];
                final filtered = _filterList(summaries);

                return RefreshIndicator(
                  onRefresh: _pullToRefresh,
                  triggerMode: RefreshIndicatorTriggerMode.anywhere,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: filtered.isEmpty ? 7 : filtered.length + 6,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const SizedBox(height: 16);
                      }
                      if (index == 1) {
                        return _buildSummaryCard(summaries.length);
                      }
                      if (index == 2) {
                        return const SizedBox(height: 20);
                      }
                      if (index == 3) {
                        return _buildFilterChips();
                      }
                      if (index == 4) {
                        return const SizedBox(height: 20);
                      }
                      if (filtered.isEmpty) {
                        if (index == 5) {
                          return EmptyState(onCreate: _openCreateGoal);
                        }
                        return const SizedBox(height: 28);
                      }
                      if (index == filtered.length + 5) {
                        return const SizedBox(height: 28);
                      }

                      final summary = filtered[index - 5];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TargetCard(
                          goal: summary.goal,
                          saved: summary.saved,
                          onTap: () => _openDetail(summary.goal),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int count) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total impian',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xA63F2E13),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$count target',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF3F2E13),
                ),
              ),
            ],
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0x40FFFFFF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: AppIcons.fromAsset(
                AppIcons.target,
                size: 27,
                color: const Color(0xFF3F2E13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final chips = [
      (_Filter.all, 'Semua'),
      (_Filter.active, 'Aktif'),
      (_Filter.done, 'Selesai'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.chipBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            for (final (filter, label) in chips)
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _filter = filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _filter == filter
                            ? AppColors.card
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: _filter == filter ? AppShadows.small : null,
                      ),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _filter == filter
                              ? AppColors.primary
                              : const Color(0xFF89938F),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
