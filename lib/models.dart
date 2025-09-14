class Tank {
  String name;
  List<Category> categories;

  Tank({required this.name, required this.categories});

  /// Total pounds in this tank (sum of all categories)
  int get total => categories.fold(0, (sum, c) => sum + c.pounds);
}

class Category {
  String name;
  int pounds;
  int dead;

  Category({required this.name, this.pounds = 0, this.dead = 0});
}
