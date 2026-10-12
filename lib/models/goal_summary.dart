import '../database/database_helper.dart';
import '../models/goal.dart';

/// Ringkasan target beserta nominal terkumpul
/// (untuk persentase, filter, dan badge Aktif/Selesai).
class GoalSummary {
  final Goal goal;
  final double saved;

  const GoalSummary(this.goal, this.saved);

  double get progress =>
      goal.targetPrice > 0 ? (saved / goal.targetPrice).clamp(0.0, 1.0) : 0.0;

  bool get completed => progress >= 1.0;

  static Future<GoalSummary> load(Goal goal) async {
    final saved = await DatabaseHelper.instance.getTotalProgressForGoal(
      goal.id!,
    );
    return GoalSummary(goal, saved);
  }

  /// Muat semua target beserta total setoran masing-masing.
  static Future<List<GoalSummary>> loadAll() async {
    final goals = await DatabaseHelper.instance.readAllGoals();
    final progress = await DatabaseHelper.instance.getProgressForGoals(
      goals.map((goal) => goal.id!).toList(),
    );
    return [
      for (final goal in goals) GoalSummary(goal, progress[goal.id] ?? 0),
    ];
  }
}
