import 'package:hive/hive.dart';
import '../utils/constants.dart';

part 'contact_model.g.dart';

/// A contact entry with separate display and real phone number fields.
///
/// The UI shows [displayName] and [displayNumber] while calls are routed
/// to [realNumber]. All data is persisted locally via Hive.
@HiveType(typeId: HiveTypeIds.contactModel)
class ContactModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String displayName;

  @HiveField(2)
  final String displayNumber;

  @HiveField(3)
  final String realNumber;

  @HiveField(4)
  final String? imagePath;

  @HiveField(5)
  final String? notes;

  @HiveField(6)
  final List<String> tags;

  @HiveField(7)
  final String? category;

  @HiveField(8)
  final bool isFavorite;

  @HiveField(9)
  final bool isHidden;

  @HiveField(10)
  final bool isPinned;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final DateTime updatedAt;

  ContactModel({
    required this.id,
    required this.displayName,
    required this.displayNumber,
    required this.realNumber,
    this.imagePath,
    this.notes,
    List<String>? tags,
    this.category,
    this.isFavorite = false,
    this.isHidden = false,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
  }) : tags = tags ?? [];

  /// Creates a copy of this contact with the given fields replaced.
  ContactModel copyWith({
    String? id,
    String? displayName,
    String? displayNumber,
    String? realNumber,
    String? Function()? imagePath,
    String? Function()? notes,
    List<String>? tags,
    String? Function()? category,
    bool? isFavorite,
    bool? isHidden,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContactModel(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      displayNumber: displayNumber ?? this.displayNumber,
      realNumber: realNumber ?? this.realNumber,
      imagePath: imagePath != null ? imagePath() : this.imagePath,
      notes: notes != null ? notes() : this.notes,
      tags: tags ?? this.tags,
      category: category != null ? category() : this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      isHidden: isHidden ?? this.isHidden,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ContactModel) return false;
    return id == other.id &&
        displayName == other.displayName &&
        displayNumber == other.displayNumber &&
        realNumber == other.realNumber &&
        imagePath == other.imagePath &&
        notes == other.notes &&
        _listEquals(tags, other.tags) &&
        category == other.category &&
        isFavorite == other.isFavorite &&
        isHidden == other.isHidden &&
        isPinned == other.isPinned &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        displayName,
        displayNumber,
        realNumber,
        imagePath,
        notes,
        Object.hashAll(tags),
        category,
        isFavorite,
        isHidden,
        isPinned,
        createdAt,
        updatedAt,
      );

  @override
  String toString() =>
      'ContactModel(id: $id, displayName: $displayName, displayNumber: $displayNumber)';

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
