import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarkari_result/exceptions/post_parse.dart';
import 'package:sarkari_result/models/post.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as dom;

class PostDetailNotifier extends AsyncNotifier<Future<List<Post>>> {
  @override
  Future<List<Post>> build() async {
    return await _fetchJobs();
  }

  Future<List<Post>> _fetchJobs() async {
    http.Response response = await _response();

    if (kDebugMode) print("Today: $_today");

    return _parseJobs(response.body);
  }

  Future<http.Response> _response() async {
    Uri httpUrl = kDebugMode
        ? Uri.http('localhost:8000', '/index.html')
        : Uri.https('www.sarkariresult.com', '/latestjob/');
    if (kDebugMode) print("URL: $httpUrl");
    return await http
        .get(httpUrl)
        .timeout(const Duration(seconds: 10))
        .onError((error, stacktrace) {
      if (kDebugMode) {
        print(stacktrace.toString());
        print(error);
      }

      throw const SocketException("No connection");
    });
  }

  List<Post> _parseJobs(String html) {
    dom.Document document = dom.parse(html);
    dom.Element? postsContainer = document.getElementById('post');
    if (postsContainer == null) {
      throw PostParseException("Unable to get element id: post", body: html);
    }
    List<dom.Element> item = postsContainer.getElementsByTagName('li');
    if (item.isEmpty) {
      throw PostParseException("unable to get elements by tag: <li>",
          body: html);
    }
    List<Post> jobs = [];

    try {
      for (dom.Element item in item) {
        String title = item.getElementsByTagName('a')[0].innerHtml;
        List<String> date = item.innerHtml.split(':').last.split('/');
        DateTime? dateTime;
        if (date.length == 3) {
          String year = date.last.trim();
          String month = date[1].trim();
          String day = date.first.trim();
          dateTime = DateTime.parse("$year-$month-$day");
        }

        Uri? uri = Uri.tryParse(
            item.getElementsByTagName('a')[0].attributes['href'] ?? "");
        if (uri != null) {
          jobs.add(Post(title: title, lastDate: dateTime, uri: uri));
        }
      }
    } catch (e) {
      throw PostParseException("Unable to parse web page");
    }

    _allPosts = jobs;
    return jobs;
  }
}

final postDetailNotifierProvider =
    AsyncNotifierProvider<PostDetailNotifier, Future<List<Post>>>(() {
  return PostDetailNotifier();
});

List<Post> _allPosts = [];

final postsProvider = Provider((ref) {
  return _allPosts;
});

final availablePostsByDateProvider = Provider((ref) async {
  return await Future<List<Post>>(() {
    List<Post> posts = [
      for (Post post in _allPosts)
        // posts that are either after [_today] or equals to [_today.day]
        if (post.lastDate != null &&
            (post.lastDate!.isAfter(_today) || _isToday(post.lastDate!)))
          Post(title: post.title, lastDate: post.lastDate, uri: post.uri)
    ];
    posts.sort((a, b) => (a.lastDate!.difference(_today))
        .inDays
        .compareTo((b.lastDate!.difference(_today)).inDays));
    return posts;
  });
});

final notAvailablePostsProvider = Provider((ref) async {
  return await Future<List<Post>>(() {
    return [
      for (Post post in _allPosts)
        if (post.lastDate != null && !post.lastDate!.isAfter(_today))
          Post(title: post.title, lastDate: post.lastDate, uri: post.uri)
    ];
  });
});

final noDatePostsProvider = Provider((ref) async {
  return await Future<List<Post>>(() {
    return [
      for (Post post in _allPosts)
        if (post.lastDate == null)
          Post(title: post.title, lastDate: post.lastDate, uri: post.uri)
    ];
  });
});

bool _isToday(DateTime date) {
  return (date.day == _today.day &&
      date.month == _today.month &&
      date.year == _today.year);
}

DateTime _today = kDebugMode ? DateTime.parse("2024-11-30") : DateTime.now();
