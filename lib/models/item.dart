// Satu model untuk News (articles), Blog (blogs), dan Report (reports)
// karena field-nya sama. `type` menandai asalnya: 'articles' | 'blogs' | 'reports'
class Item {
  final int id;
  final String type;
  final String title;
  final String newsSite; // dipakai sebagai "author" + dasar filter chip
  final String imageUrl;
  final String url;
  final String summary;
  final String publishedAt;

  const Item({
    required this.id,
    required this.type,
    required this.title,
    required this.newsSite,
    required this.imageUrl,
    required this.url,
    required this.summary,
    required this.publishedAt,
  });

  // Dari JSON API
  factory Item.fromApi(String type, Map<String, dynamic> j) => Item(
        id: j['id'] as int,
        type: type,
        title: (j['title'] ?? '') as String,
        newsSite: (j['news_site'] ?? '-') as String,
        imageUrl: (j['image_url'] ?? '') as String,
        url: (j['url'] ?? '') as String,
        summary: (j['summary'] ?? '') as String,
        publishedAt: (j['published_at'] ?? '') as String,
      );

  // Dari/ke JSON lokal (untuk disimpan di SharedPreferences sebagai favourite)
  factory Item.fromJson(Map<String, dynamic> j) => Item(
        id: j['id'] as int,
        type: j['type'] as String,
        title: j['title'] as String,
        newsSite: j['newsSite'] as String,
        imageUrl: j['imageUrl'] as String,
        url: j['url'] as String,
        summary: j['summary'] as String,
        publishedAt: j['publishedAt'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'newsSite': newsSite,
        'imageUrl': imageUrl,
        'url': url,
        'summary': summary,
        'publishedAt': publishedAt,
      };
}
