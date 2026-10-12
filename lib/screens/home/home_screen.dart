import 'package:flutter/material.dart';

import '../../database/database_helper.dart';
import '../../models/goal.dart';
import '../../models/goal_summary.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_icons.dart';
import '../../utils/format_helper.dart';
import '../goals/goal_detail_screen.dart';
import '../goals/goal_form_screen.dart';
import '../../widgets/dashed_border.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/target_card.dart';
import '../../widgets/profile_avatar.dart';

/// Halaman Beranda ala desain:
/// header hijau tua + kartu total + 3 target + tombol dashed.
class HomeScreen extends StatefulWidget {
  /// Pindah ke tab lain (1 = Target, 2 = Profil).
  final void Function(int tab)? onSeeAllTargets;
  final int dataRevision;
  final String userName;
  final String? profileImage;

  const HomeScreen({
    super.key,
    required this.userName,
    this.dataRevision = 0,
    this.profileImage,
    this.onSeeAllTargets,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<_HomeData> _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = _loadData();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dataRevision != widget.dataRevision) _refresh();
  }

  Future<_HomeData> _loadData() async {
    final results = await Future.wait([
      GoalSummary.loadAll(),
      DatabaseHelper.instance.getGrandTotal(),
    ]);
    final summaries = results[0] as List<GoalSummary>;
    final total = results[1] as double;
    final goals = summaries.map((summary) => summary.goal).toList();
    return _HomeData(goals, total, summaries);
  }

  void _refresh() {
    setState(() {
      _futureData = _loadData();
    });
  }

  Future<void> _pullToRefresh() async {
    final next = _loadData();
    setState(() {
      _futureData = next;
    });
    try {
      await next;
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data tabungan gagal diperbarui.')),
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_HomeData>(
      future: _futureData,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final goals = data?.goals ?? [];
        final total = data?.total ?? 0.0;
        final summaries = data?.summaries ?? [];
        final activeCount = summaries.where((s) => !s.completed).length;

        return RefreshIndicator(
          onRefresh: _pullToRefresh,
          triggerMode: RefreshIndicatorTriggerMode.anywhere,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              _buildHeader(total: total, activeCount: activeCount),
              if (goals.isEmpty)
                EmptyState(onCreate: _openCreateGoal)
              else ...[
                _buildSectionHeader(),
                const SizedBox(height: 16),
                for (final summary in summaries.take(3))
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TargetCard(
                      goal: summary.goal,
                      saved: summary.saved,
                      onTap: () => _openDetail(summary.goal),
                    ),
                  ),
                if (summaries.length > 3) ...[
                  const SizedBox(height: 12),
                  _buildMoreButton(summaries.length - 3),
                ],
                const SizedBox(height: 20),
                _buildCreateButton(),
                const SizedBox(height: 28),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader({required double total, required int activeCount}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selamat datang,',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white60,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Halo, ${widget.userName}!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  _buildAvatar(),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0x17FFFFFF),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0x1AFFFFFF)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total tabunganmu',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white60,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppFormat.rupiah(total),
                                style: const TextStyle(
                                  fontSize: 29,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.lime,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: AppIcons.fromAsset(
                              AppIcons.wallet,
                              size: 20,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.only(top: 16),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0x1AFFFFFF)),
                        ),
                      ),
                      child: Row(
                        children: [
                          AppIcons.fromAsset(
                            AppIcons.trend,
                            size: 15,
                            color: AppColors.lime,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Tetap semangat',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.lime,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '•',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$activeCount target aktif',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => widget.onSeeAllTargets?.call(2),
        child: Container(
          width: 48,
          height: 48,
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: Color(0x1AFFFFFF),
            shape: BoxShape.circle,
          ),
          child: ProfileAvatar(
            name: widget.userName,
            imagePath: widget.profileImage,
            size: 44,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Target tabungan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Selangkah lebih dekat setiap hari',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
          TextButton(
            onPressed: () => widget.onSeeAllTargets?.call(1),
            child: Text(
              'Lihat semua',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.iconTileFg,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreButton(int remaining) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextButton(
        onPressed: () => widget.onSeeAllTargets?.call(1),
        child: Text(
          'Lihat $remaining target lainnya',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.iconTileFg,
          ),
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: _openCreateGoal,
          child: DashedBorder(
            radius: 22,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppShadows.small,
                  ),
                  child: Center(
                    child: AppIcons.fromAsset(
                      AppIcons.add,
                      size: 20,
                      color: AppColors.iconTileFg,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Buat target baru',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.iconTileFg,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Ubah impian jadi rencana nyata',
                        style: TextStyle(fontSize: 11, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeData {
  final List<Goal> goals;
  final double total;
  final List<GoalSummary> summaries;

  const _HomeData(this.goals, this.total, this.summaries);
}
