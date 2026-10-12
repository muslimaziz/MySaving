import 'package:flutter/foundation.dart';

/// Memberi tahu layar ringkasan saat target atau setoran berubah.
final ValueNotifier<int> goalDataVersion = ValueNotifier<int>(0);

void notifyGoalDataChanged() {
  goalDataVersion.value++;
}
