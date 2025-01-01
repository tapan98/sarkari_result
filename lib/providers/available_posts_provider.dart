import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarkari_result/models/post.dart';
import 'package:sarkari_result/providers/all_posts_provider.dart';
import 'package:sarkari_result/shared/data/date.dart';
import 'package:sarkari_result/shared/post_sort.dart';

class AvailablePostsNotifier extends Notifier<Future<List<Post>>> {
  @override
  Future<List<Post>> build() async {
    return await Future(() {
      return ref.watch(availablePosts);
    });
  }

  void sortBy(PostSort sortBy) {
    switch (sortBy) {
      case PostSort.byDate:
        state = getByDate();
        break;
      case PostSort.byNew:
        state = getByNew();

        break;
    }
  }

  Future<List<Post>> getByDate() {
    return Future(() {
      final posts = ref.watch(availablePosts);
      posts.sort((a, b) => (a.lastDate!.difference(today))
          .inDays
          .compareTo((b.lastDate!.difference(today)).inDays));
      return posts;
    });
  }

  Future<List<Post>> getByNew() {
    return Future(() {
      return [
        for (Post post in ref.watch(postsProvider))
          // posts that are either after [today] or equals to [today.day]
          if (post.lastDate != null &&
              (post.lastDate!.isAfter(today) || isToday(post.lastDate!)))
            Post(title: post.title, lastDate: post.lastDate, uri: post.uri)
      ];
    });
  }
}

final availablePostsNotifierProvider =
    NotifierProvider<AvailablePostsNotifier, Future<List<Post>>>(() {
  return AvailablePostsNotifier();
});

/// sorted by new
final availablePosts = Provider((ref) {
  final allPosts = ref.watch(postsProvider);
  return [
    for (Post post in allPosts)
      // posts that are either after [today] or equals to [today.day]
      if (post.lastDate != null &&
          (post.lastDate!.isAfter(today) || isToday(post.lastDate!)))
        Post(title: post.title, lastDate: post.lastDate, uri: post.uri)
  ];
});

final availablePostsByDate = Provider((ref) {
  final posts = ref.watch(availablePosts);
  posts.sort((a, b) => (a.lastDate!.difference(today))
      .inDays
      .compareTo((b.lastDate!.difference(today)).inDays));
  return posts;
});
