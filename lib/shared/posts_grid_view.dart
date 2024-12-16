import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sarkari_result/models/post.dart';
import 'package:sarkari_result/shared/card_post.dart';

class PostsGridView extends StatefulWidget {
  final List<Post> posts;
  const PostsGridView({super.key, required this.posts});

  @override
  State<PostsGridView> createState() => _PostsGridViewState();
}

class _PostsGridViewState extends State<PostsGridView> {
  @override
  void initState() {
    _scrollController.addListener(() {
      double showOffset = 10.0;

      if (_scrollController.offset > showOffset) {
        showButton = true;
        setState(() {});
      } else {
        setState(() {
          showButton = false;
        });
        // setState(() {});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final int crossAxisCount = _getGridCount(context);

    return Scaffold(
        floatingActionButton: _scrollToTop(),
        body: GridView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 90.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount),
          itemCount: widget.posts.length,
          itemBuilder: (context, index) {
            return CardPost(post: widget.posts[index]);
          },
          controller: _scrollController,
        )
        // CustomScrollView(
        //   slivers: [
        //     const SliverAppBar.large(
        //       title: Text("Sarkari Result jobs list simplified"),
        //     ),

        //     SliverGrid(
        //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //         crossAxisCount: crossAxisCount,
        //       ),
        //       delegate: SliverChildBuilderDelegate(
        //         childCount: widget.posts.length,
        //         (context, index) {
        //           return CardPost(post: widget.posts[index]);
        //         },
        //       ),
        //     ),
        //     const SliverToBoxAdapter(
        //         child: SizedBox(
        //       height: 90,
        //     )),
        //   ],
        //   controller: _scrollController,
        // ),
        );
  }

  FloatingActionButton? _scrollToTop() {
    if (showButton) {
      return FloatingActionButton(
        onPressed: () {
          if (kDebugMode) {
            print("_scrollController.offset: ${_scrollController.offset}");
          }
          _scrollController.animateTo(0.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.linear);
          setState(() {
            showButton = false;
          });
        },
        child: const Icon(Icons.arrow_upward),
      );
    }
    return null;
  }

  int _getGridCount(BuildContext context) {
    if (kDebugMode) {
      double width = MediaQuery.sizeOf(context).width;
      double height = MediaQuery.sizeOf(context).height;
      print("Width: $width, Height: $height");
    }
    const int maxSize = 300;
    int gridCount = (MediaQuery.sizeOf(context).width / maxSize).toInt();
    return gridCount < 1 ? 1 : gridCount;
  }

  final _scrollController = ScrollController();
  bool showButton = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
