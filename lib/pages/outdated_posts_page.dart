import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sarkari_result/shared/post_filter.dart';
import 'package:sarkari_result/shared/posts_grid_view.dart';

class OutdatedPostPage extends StatelessWidget {
  const OutdatedPostPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) print("[OutdatedPostPage] build()");
    return const PostsGridView(postSection: PostFilter.outdated);
  }
}
