import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarkari_result/exceptions/post_parse.dart';
import 'package:sarkari_result/models/post.dart';
import 'package:sarkari_result/pages/available_posts_page.dart';
import 'package:sarkari_result/pages/outdated_posts_page.dart';
import 'package:sarkari_result/pages/undetermined_posts_page.dart';
import 'package:sarkari_result/providers/all_posts_provider.dart';
import 'package:sarkari_result/shared/navigation_item.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  AsyncValue<Future<List<Post>>>? jobs;
  @override
  Widget build(BuildContext context) {
    jobs = ref.watch(postDetailNotifierProvider);
    return Scaffold(
      appBar: _appBar(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: FutureBuilder(
        future: jobs?.value,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData &&
              snapshot.data != null) {
            return _buildDisplay(context);
          } else if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasError) {
            if (snapshot.error.runtimeType == PostParseException) {
              return SingleChildScrollView(
                child: Center(
                  child: Text(
                    "Unable to parse the web page\n${snapshot.error}",
                  ),
                ),
              );
            } else if (snapshot.error.runtimeType == SocketException) {
              return _unableToConnect(snapshot.error);
            }
            return Center(
              child: Text("Error!\n${snapshot.error}"),
            );
          }

          return _fetchingData();
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _unableToConnect(Object? error) {
    return LayoutBuilder(
      builder: (context, constraints) => RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          children: [
            Container(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Text("Unable to connect\n$error"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    return Future.delayed(const Duration(seconds: 0), () {
      try {
        ref.read(postDetailNotifierProvider.notifier).refresh();
        setState(() {});
      } catch (e) {
        if (kDebugMode) print("[ERROR] _refresh(): $e");
      }
    });
  }

  Widget _buildDisplay(BuildContext context) {
    final mainContent = IndexedStack(
      index: _activePage,
      children:
          _navigationDestinations.map((item) => item.destination).toList(),
    );

    if (_isLandScape(context)) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNavigationRail(),
          const VerticalDivider(),
          Expanded(child: mainContent),
        ],
      );
    }

    return mainContent;
  }

  bool _isLandScape(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (kDebugMode) print("width: $width");
    return width > 600;
  }

  NavigationRail _buildNavigationRail() {
    return NavigationRail(
      destinations: _navigationDestinations
          .map((item) => NavigationRailDestination(
              icon: item.icon, label: Text(item.label)))
          .toList(),
      selectedIndex: _activePage,
      groupAlignment: 0.0,
      extended: (MediaQuery.sizeOf(context)).width > 1000,
      onDestinationSelected: (index) {
        setState(() {
          _activePage = index;
        });
      },
    );
  }

  NavigationBar? _buildBottomNavigationBar() {
    if (_isLandScape(context)) return null;
    return NavigationBar(
      destinations: _navigationDestinations
          .map((item) =>
              NavigationDestination(icon: item.icon, label: item.label))
          .toList(),
      selectedIndex: _activePage,
      onDestinationSelected: (index) {
        setState(() {
          _activePage = index;
        });
      },
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: const Text("Sarkari Result: simplified"),
      centerTitle: true,
    );
  }

  Widget _fetchingData() {
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
          child: Text("Fetching jobs list..."),
        )
      ],
    );
  }

  int _activePage = 0;

  final List<NavigationItem> _navigationDestinations = [
    NavigationItem(
        label: "Available",
        icon: const Icon(Icons.event_available),
        destination: const AvailablePostPage()),
    NavigationItem(
        label: "Undetermined",
        icon: const Icon(Icons.calendar_today),
        destination: const UndeterminedPostsPage()),
    NavigationItem(
        label: "Outdated",
        icon: const Icon(Icons.event_busy),
        destination: const OutdatedPostPage()),
  ];
}
