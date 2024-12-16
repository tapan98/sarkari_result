class PostParseException implements Exception {
  String cause;
  String? body;
  PostParseException(this.cause, {this.body});

  @override
  String toString() {
    if (body != null) {
      return "$cause\nRaw body: $body";
    }
    return cause;
  }
}
