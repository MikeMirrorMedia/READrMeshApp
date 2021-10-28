import 'package:readr/models/baseModel.dart';

class Category {
  String id;
  String name;
  String slug;
  DateTime? latestPostTime;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.latestPostTime,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json[BaseModel.idKey],
      name: json[BaseModel.nameKey],
      slug: json[BaseModel.slugKey],
    );
  }

  Map<String, dynamic> toJson() => {
        BaseModel.idKey: id,
        BaseModel.nameKey: name,
        BaseModel.slugKey: slug,
      };

  bool isLatestCategory() {
    return id == 'latest';
  }

  bool isFeaturedCategory() {
    return id == 'featured';
  }

  static bool checkIsLatestCategoryBySlug(String? slug) {
    return slug == 'latest';
  }

  @override
  int get hashCode => Category(id: id, name: name, slug: slug).hashCode;

  @override
  bool operator ==(covariant Category other) {
    // compare this to other
    return id == other.id;
  }
}
