class Goal {
  final int? id;
  final String name;
  final double targetPrice;
  final String targetDate;
  final String? note;
  final String? image;
  final String status; // Active, Completed, Missed
  final String createdAt;
  final String updatedAt;

  Goal({
    this.id,
    required this.name,
    required this.targetPrice,
    required this.targetDate,
    this.note,
    this.image,
    this.status = 'Active',
    required this.createdAt,
    required this.updatedAt,
  });

  // Mengubah objek menjadi Map untuk disimpan ke SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target_price': targetPrice,
      'target_date': targetDate,
      'note': note,
      'image': image,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Mengubah data dari SQLite (Map) kembali menjadi objek Goal
  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] as int?,
      name: map['name'] as String,
      targetPrice: (map['target_price'] as num).toDouble(),
      targetDate: map['target_date'] as String,
      note: map['note'] as String?,
      image: map['image'] as String?,
      status: map['status'] as String,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }
}
