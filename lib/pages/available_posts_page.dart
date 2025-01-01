import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sarkari_result/shared/post_filter.dart';
import 'package:sarkari_result/shared/posts_grid_view.dart';

class AvailablePostPage extends StatelessWidget {
  const AvailablePostPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) print("[AvailablePostPage] build()");
    return const PostsGridView(
      postSection: PostFilter.available,
    );
  }
}
