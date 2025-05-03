enum PostSort {
  byDate(
    title: "Last date",
  ),
  byNew(
    title: "New posts",
  );

  final String title;

  const PostSort({
    required this.title,
});
}
