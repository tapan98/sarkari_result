class Post {
  String title;
  DateTime? lastDate;
  Uri uri;

  Post({required this.title, required this.lastDate, required this.uri});

  @override
  String toString() {
    return "Title: $title\nLast Date: $lastDate\n URI: $uri";
  }
}
