enum SoriItemType { folder, note }

class SoriItem {
  final SoriItemType type;
  final String id;
  final String name;

  const SoriItem({required this.type, required this.id, required this.name});
}
