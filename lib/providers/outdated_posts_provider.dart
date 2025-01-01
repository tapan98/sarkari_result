import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarkari_result/models/post.dart';
import 'package:sarkari_result/providers/all_posts_provider.dart';
import 'package:sarkari_result/shared/data/date.dart';

final outdatedPostsProvider = Provider((ref) {
  return Future(() {
    final allPosts = ref.watch(postsProvider);
    return [
      for (Post post in allPosts)
        if (post.lastDate != null && post.lastDate!.isBefore(today))
          Post(title: post.title, lastDate: post.lastDate, uri: post.uri)
    ];
  });
});
