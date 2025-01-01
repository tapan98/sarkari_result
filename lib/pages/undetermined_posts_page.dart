import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sarkari_result/shared/post_filter.dart';
import 'package:sarkari_result/shared/posts_grid_view.dart';

class UndeterminedPostsPage extends StatelessWidget {
  const UndeterminedPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) print("[UndeterminedPostPage] build()");
    return const PostsGridView(postSection: PostFilter.undetermined);
  }
}
