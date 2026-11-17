import 'package:hive/hive.dart';
import '../utils/constants.dart';

part 'category_model.g.dart';

/// A user-defined category for organizing contacts into groups.
@HiveType(typeId: HiveTypeIds.categoryModel)
class CategoryModel extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final DateTime createdAt;

  CategoryModel({
    required this.name,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CategoryModel) return false;
    return name == other.name && createdAt == other.createdAt;
  }

  @override
  int get hashCode => Object.hash(name, createdAt);

  @override
  String toString() => 'CategoryModel(name: $name, createdAt: $createdAt)';
}
