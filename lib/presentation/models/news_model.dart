class News {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime date;

  News({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.date,
  });

  // Tambahkan metode bantu jika diperlukan, misalnya untuk parsing JSON
  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'date': date.toIso8601String(),
    };
  }
}
