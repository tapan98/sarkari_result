import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarkari_result/models/post.dart';
import 'package:sarkari_result/providers/available_posts_provider.dart';
import 'package:sarkari_result/providers/outdated_posts_provider.dart';
import 'package:sarkari_result/providers/undetermined_posts_provider.dart';
import 'package:sarkari_result/shared/card_post.dart';
import 'package:sarkari_result/shared/post_filter.dart';
import 'package:sarkari_result/shared/post_sort.dart';

class PostsGridView extends ConsumerStatefulWidget {
  final PostFilter postSection;
  const PostsGridView({super.key, required this.postSection});

  @override
  ConsumerState<PostsGridView> createState() => _PostsGridViewState();
}

class _PostsGridViewState extends ConsumerState<PostsGridView> {
  @override
  void initState() {
    _scrollController.addListener(() {
      double showOffset = 10.0;

      if (_scrollController.offset > showOffset) {
        _showButton = true;
        setState(() {});
      } else {
        setState(() {
          _showButton = false;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // return _buildPostsList(context);
    Future<List<Post>>? postsRef = _selectPosts();

    debugPrint("build(): postRef $postsRef");
    return FutureBuilder(
      future: postsRef,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data != null) {
            // display list
            return _postsList(context, snapshot.data!);
          } else if (snapshot.hasError) {
            // display error
            return _displayError(snapshot.error);
          } else {
            return _somethingWrong();
          }
        }
        return _loadingList(snapshot.connectionState);
      },
    );
  }

  Future<List<Post>>? _selectPosts() {
    debugPrint("_selectPosts(): postSection ${widget.postSection}");
    switch (widget.postSection) {
      case PostFilter.available:
        return ref.watch(availablePostsNotifierProvider);

      case PostFilter.undetermined:
        return ref.watch(undeterminedPostsProvider);

      case PostFilter.outdated:
        return ref.watch(outdatedPostsProvider);
    }
  }

  Widget _postsList(BuildContext context, List<Post> posts) {
    final int crossAxisCount = _getGridCount(context);
    return Scaffold(
      floatingActionButton: _scrollToTop(),
      body: CustomScrollView(
        slivers: [
          if (widget.postSection == PostFilter.available)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Expanded(child: SizedBox()),
                    _createPopupMenu(),
                  ],
                ),
              ),
            ),
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
            ),
            delegate: SliverChildBuilderDelegate(
              childCount: posts.length,
              (context, index) {
                return CardPost(post: posts[index]);
              },
            ),
          ),
          const SliverToBoxAdapter(
              child: SizedBox(
            height: 90,
          )),
        ],
        controller: _scrollController,
      ),
    );
  }

  FloatingActionButton? _scrollToTop() {
    if (_showButton) {
      return FloatingActionButton(
        onPressed: () {
          _scrollController.animateTo(0.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.linear);
          setState(() {
            _showButton = false;
          });
        },
        child: const Icon(Icons.arrow_upward),
      );
    }
    return null;
  }

  int _getGridCount(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    if (kDebugMode) print("WxH: ${screenSize.width}x${screenSize.height}");
    const int maxSize = 300;
    int gridCount = (MediaQuery.sizeOf(context).width / maxSize).toInt();
    return gridCount < 1 ? 1 : gridCount;
  }

  PopupMenuButton _createPopupMenu() {
    return PopupMenuButton(
      icon: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(_selectedSortBy()),
          const SizedBox(width: 10),
          const Icon(Icons.tune),
        ],
      ),
      itemBuilder: (context) => _sortByList,
      onSelected: (value) {
        if (PostSort.byDate == value) {
          ref
              .read(availablePostsNotifierProvider.notifier)
              .sortBy(PostSort.byDate);
          _popupSelected = value;
        } else if (PostSort.byNew == value) {
          ref
              .read(availablePostsNotifierProvider.notifier)
              .sortBy(PostSort.byNew);
          _popupSelected = value;
        }
        setState(() {});
      },
    );
  }

  String _selectedSortBy() {
    String sortBy = "Sort By:";
    switch (_popupSelected) {
      case PostSort.byNew:
        sortBy = ("$sortBy New");
      case PostSort.byDate:
        sortBy = ("$sortBy Date");
    }
    return sortBy;
  }

  Widget _displayError(Object? error) {
    return Center(
      child: Text("Error!\n$error"),
    );
  }

  Widget _somethingWrong() {
    return const Center(
      child: Text("Something went wrong!"),
    );
  }

  Widget _loadingList(ConnectionState connectionState) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: CircularProgressIndicator(),
        ),
        SizedBox(
          height: 10.0,
        ),
        Center(
          child: Text("Loading posts list..."),
        )
      ],
    );
  }

  final _scrollController = ScrollController();
  bool _showButton = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  PostSort _popupSelected = PostSort.byNew;

  final List<PopupMenuItem> _sortByList = const [
    PopupMenuItem(value: PostSort.byDate, child: Text("Sort by Date")),
    PopupMenuItem(value: PostSort.byNew, child: Text("Sort by New")),
  ];

  void debugPrint(String msg) {
    if (kDebugMode) {
      print("[PostGridView] $msg");
    }
  }
}
