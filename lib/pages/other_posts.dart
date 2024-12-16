import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarkari_result/providers/post_detail_provider.dart';
import 'package:sarkari_result/shared/posts_grid_view.dart';

class OtherPostsPage extends ConsumerWidget {
  const OtherPostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otherPosts = ref.watch(noDatePostsProvider);
    return FutureBuilder(
        future: otherPosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data != null) {
              return PostsGridView(posts: snapshot.data!);
            } else if (snapshot.hasError) {
              return Center(
                child: Text("Something went wrong!\n${snapshot.error}"),
              );
            }
          }
          return const CircularProgressIndicator();
        });
  }
}
