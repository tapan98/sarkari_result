import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sarkari_result/models/post.dart';
import 'package:url_launcher/url_launcher.dart';

class CardPost extends StatelessWidget {
  final Post post;
  const CardPost({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = post.title;
    final date = post.lastDate != null
        ? DateFormat("d MMMM y").format(post.lastDate!)
        : null;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          launchUrl(post.uri);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.secondaryContainer,
          foregroundColor: theme.colorScheme.onSecondaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (date != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Last Date: $date"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
