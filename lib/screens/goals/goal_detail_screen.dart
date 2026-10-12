import 'dart:io';

import 'package:flutter/material.dart';

import '../../database/database_helper.dart';
import '../../models/goal.dart';
import '../../models/transaction_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_icons.dart';
import '../../utils/format_helper.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_progress_bar.dart';
import '../../widgets/page_header.dart';
import 'add_transaction_screen.dart';
import 'goal_form_screen.dart';

class GoalDetailScreen extends StatefulWidget {
  final Goal goal;

  const GoalDetailScreen({super.key, required this.goal});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  late Future<_GoalDetailData> _data;
  late Goal _goal;
  final Set<int> _deletedTransactionIds = {};

  @override
  void initState() {
    super.initState();
    _goal = widget.goal;
    _data = _loadData();
  }

  Future<_GoalDetailData> _loadData() async {
    final id = _goal.id!;
    final goal = await DatabaseHelper.instance.readGoalById(id) ?? _goal;
    final saved = await DatabaseHelper.instance.getTotalProgressForGoal(id);
    final transactions = await DatabaseHelper.instance.getTransactionsForGoal(
      id,
    );
    return _GoalDetailData(goal, saved, transactions);
  }

  Future<void> _refresh() async {
    try {
      final refreshed = await _loadData();
      if (!mounted) return;
      setState(() {
        _goal = refreshed.goal;
        _data = Future.value(refreshed);
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data target gagal diperbarui.')),
      );
    }
  }

  Future<void> _pullToRefresh() => _refresh();

  Future<void> _editGoal() async {
    final result = await showModalBottomSheet<Object?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GoalFormScreen(goal: _goal),
    );
    if (!mounted) return;
    if (result is Goal) {
      setState(() => _goal = result);
    } else if (result == 'delete') {
      await _deleteGoal();
    }
  }

  Future<void> _deleteGoal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus target?', style: TextStyle(color: AppColors.text)),
        content: Text(
          'Target "${_goal.name}" dan semua riwayatnya akan dihapus.',
          style: TextStyle(color: AppColors.label),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: TextStyle(color: AppColors.text)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await DatabaseHelper.instance.deleteGoal(_goal.id!);
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _addSaving() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddTransactionScreen(goal: _goal)),
    );
    if (result == true) await _refresh();
  }

  Future<void> _editTransaction(TransactionModel transaction) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddTransactionScreen(goal: _goal, transaction: transaction),
      ),
    );
    if (result == true) await _refresh();
  }

  Future<void> _deleteTransaction(TransactionModel tx) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hapus transaksi?',
          style: TextStyle(color: AppColors.text),
        ),
        content: Text(
          'Hapus setoran ${AppFormat.rupiah(tx.amount)}?',
          style: TextStyle(color: AppColors.label),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: TextStyle(color: AppColors.text)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final deleted = await DatabaseHelper.instance.deleteTransaction(tx.id!);
    if (deleted > 0 && mounted) {
      setState(() => _deletedTransactionIds.add(tx.id!));
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppThemeRebuilder(
      builder: (context) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              PageHeader(
                title: _goal.name,
                onBack: () => Navigator.pop(context),
                right: PopupMenuButton<String>(
                  icon: AppIcons.fromAsset(
                    AppIcons.more,
                    color: AppColors.iconTileFg,
                  ),
                  onSelected: (value) =>
                      value == 'edit' ? _editGoal() : _deleteGoal(),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit target')),
                    PopupMenuItem(value: 'delete', child: Text('Hapus target')),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<_GoalDetailData>(
                  future: _data,
                  builder: (context, snapshot) {
                    final data = snapshot.data ?? _GoalDetailData(_goal, 0, []);
                    final hiddenAmount = data.transactions
                        .where(
                          (transaction) =>
                              _deletedTransactionIds.contains(transaction.id),
                        )
                        .fold<double>(
                          0,
                          (sum, transaction) => sum + transaction.amount,
                        );
                    final saved = data.saved - hiddenAmount;
                    final progress = _goal.targetPrice <= 0
                        ? 0.0
                        : (saved / _goal.targetPrice).clamp(0.0, 1.0);
                    final transactions =
                        data.transactions
                            .where(
                              (transaction) => !_deletedTransactionIds.contains(
                                transaction.id,
                              ),
                            )
                            .toList()
                          ..sort(
                            (a, b) =>
                                b.transactionDate.compareTo(a.transactionDate),
                          );
                    return RefreshIndicator(
                      onRefresh: _pullToRefresh,
                      triggerMode: RefreshIndicatorTriggerMode.anywhere,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: AppShadows.card,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 190,
                                  width: double.infinity,
                                  child:
                                      _goal.image != null &&
                                          _goal.image!.isNotEmpty
                                      ? Image.file(
                                          File(_goal.image!),
                                          fit: BoxFit.cover,
                                          cacheWidth: 1170,
                                        )
                                      : Container(
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFFE7EFE7),
                                                Color(0xFFC9DDCE),
                                              ],
                                            ),
                                          ),
                                          child: Center(
                                            child: AppIcons.fromAsset(
                                              AppIcons.target,
                                              size: 54,
                                              color: AppColors.iconTileFg,
                                            ),
                                          ),
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Progress tabungan',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.label,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '${(progress * 100).round()}%',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.accentDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      AppProgressBar(value: progress),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            AppFormat.rupiah(saved),
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          Text(
                                            'dari ${AppFormat.rupiah(_goal.targetPrice)}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.muted,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Target ${AppFormat.prettyDate(_goal.targetDate)}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.muted,
                                        ),
                                      ),
                                      if (_goal.note?.isNotEmpty == true) ...[
                                        const SizedBox(height: 16),
                                        Text(
                                          _goal.note!,
                                          style: TextStyle(
                                            fontSize: 13,
                                            height: 1.5,
                                            color: AppColors.label,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Riwayat tabungan',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.text,
                                ),
                              ),
                              Text(
                                '${transactions.length} transaksi',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: transactions.isEmpty
                                ? Padding(
                                    padding: EdgeInsets.all(24),
                                    child: Text(
                                      'Belum ada riwayat tabungan.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  )
                                : Column(
                                    children: [
                                      for (
                                        var i = 0;
                                        i < transactions.length;
                                        i++
                                      ) ...[
                                        if (i > 0)
                                          Divider(
                                            height: 1,
                                            indent: 68,
                                            color: AppColors.divider,
                                          ),
                                        _transactionTile(transactions[i]),
                                      ],
                                    ],
                                  ),
                          ),
                          const SizedBox(height: 20),
                          AppButton(
                            label: 'Tambah Tabungan',
                            icon: AppIcons.add,
                            onPressed: _addSaving,
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
      ),
    );
  }

  Widget _transactionTile(TransactionModel tx) {
    DateTime? date;
    try {
      date = DateTime.parse(tx.transactionDate);
    } catch (_) {}
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.iconTileBg,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: AppIcons.fromAsset(
                AppIcons.trend,
                size: 18,
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
                  tx.note?.isNotEmpty == true ? tx.note! : 'Menabung',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  date == null
                      ? tx.transactionDate
                      : AppFormat.prettyDate(date.toIso8601String()),
                  style: TextStyle(fontSize: 10, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Text(
            '+${AppFormat.shortRupiah(tx.amount)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.iconTileFg,
            ),
          ),
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            icon: Icon(Icons.more_vert, size: 18, color: AppColors.muted),
            onSelected: (value) {
              if (value == 'edit') _editTransaction(tx);
              if (value == 'delete') _deleteTransaction(tx);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Hapus')),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalDetailData {
  final Goal goal;
  final double saved;
  final List<TransactionModel> transactions;

  const _GoalDetailData(this.goal, this.saved, this.transactions);
}
