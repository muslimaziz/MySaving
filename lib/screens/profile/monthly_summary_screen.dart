import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../database/database_helper.dart';
import '../../theme/app_theme.dart';
import '../../utils/format_helper.dart';
import '../../utils/goal_data_notifier.dart';
import '../../widgets/page_header.dart';

class MonthlySummaryScreen extends StatefulWidget {
  const MonthlySummaryScreen({super.key});

  @override
  State<MonthlySummaryScreen> createState() => _MonthlySummaryScreenState();
}

class _MonthlySummaryScreenState extends State<MonthlySummaryScreen> {
  late Future<List<_MonthTotal>> _summary;

  @override
  void initState() {
    super.initState();
    _summary = _loadSummary();
    goalDataVersion.addListener(_refresh);
  }

  @override
  void dispose() {
    goalDataVersion.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {
        _summary = _loadSummary();
      });
    }
  }

  Future<void> _pullToRefresh() async {
    final next = _loadSummary();
    setState(() {
      _summary = next;
    });
    try {
      await next;
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ringkasan gagal diperbarui.')),
      );
    }
  }

  Future<List<_MonthTotal>> _loadSummary() async {
    final now = DateTime.now();
    final firstMonth = DateTime(now.year, now.month - 5);
    final afterLastMonth = DateTime(now.year, now.month + 1);
    final rows = await DatabaseHelper.instance.getMonthlySavingSummary(
      fromDate: DateFormat('yyyy-MM-dd').format(firstMonth),
      untilDate: DateFormat('yyyy-MM-dd').format(afterLastMonth),
    );
    final totals = {
      for (final row in rows)
        row['month'] as String: (
          (row['total'] as num?)?.toDouble() ?? 0,
          (row['deposit_count'] as num?)?.toInt() ?? 0,
        ),
    };

    return List.generate(6, (index) {
      final month = DateTime(firstMonth.year, firstMonth.month + index);
      final key = DateFormat('yyyy-MM').format(month);
      final (total, count) = totals[key] ?? (0.0, 0);
      return _MonthTotal(month, total, count);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: 'Ringkasan Bulanan',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: FutureBuilder<List<_MonthTotal>>(
                future: _summary,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Ringkasan belum bisa dimuat.',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    );
                  }

                  final months = snapshot.data ?? const <_MonthTotal>[];
                  final current = months.isEmpty ? null : months.last;
                  final maxValue = months.fold<double>(
                    0,
                    (maximum, month) =>
                        month.total > maximum ? month.total : maximum,
                  );
                  final sixMonthTotal = months.fold<double>(
                    0,
                    (sum, month) => sum + month.total,
                  );

                  return RefreshIndicator(
                    onRefresh: _pullToRefresh,
                    triggerMode: RefreshIndicatorTriggerMode.anywhere,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                current == null
                                    ? 'BULAN INI'
                                    : DateFormat(
                                        'MMMM yyyy',
                                        'id_ID',
                                      ).format(current.month).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                AppFormat.rupiah(current?.total ?? 0.0),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 27,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${current?.count ?? 0} kali setoran bulan ini',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Container(
                                height: 1,
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total 6 bulan terakhir',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    AppFormat.rupiah(sixMonthTotal),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Setoran per bulan',
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Column(
                            children: [
                              for (var i = 0; i < months.length; i++) ...[
                                if (i > 0)
                                  Divider(height: 18, color: AppColors.divider),
                                _monthRow(months[i], maxValue),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Ringkasan dihitung dari tanggal setoran yang tersimpan di perangkat.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.faint,
                            fontSize: 11,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _monthRow(_MonthTotal item, double maxValue) {
    final ratio = maxValue <= 0 ? 0.0 : item.total / maxValue;
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            DateFormat('MMM', 'id_ID').format(item.month),
            style: TextStyle(
              color: AppColors.label,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: AppColors.track,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 98,
          child: Text(
            AppFormat.shortRupiah(item.total),
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.text,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _MonthTotal {
  final DateTime month;
  final double total;
  final int count;

  const _MonthTotal(this.month, this.total, this.count);
}
