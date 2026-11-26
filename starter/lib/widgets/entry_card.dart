import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/entry.dart';

class EntryCard extends StatelessWidget {
  const EntryCard({
    super.key,
    required this.entry,
    this.photoPath,
    this.query = '',
  });

  final Entry entry;
  final String? photoPath;
  final String query;

  Color _tagColor(String tag) {
    const colors = {
      'Travel': Colors.blue,
      'Food': Colors.orange,
      'Erasmus': Colors.purple,
      'Ideas': Colors.green,
      'Culture': Colors.red,
      'Other': Colors.grey,
    };
    return colors[tag] ?? Colors.grey;
  }

  // Shows text with the parts matching the search highlighted
  Widget _highlight(String text, {TextStyle? style, int? maxLines}) {
    final search = query.trim();
    final matches = search.isEmpty
        ? <RegExpMatch>[]
        : RegExp(RegExp.escape(search), caseSensitive: false)
        .allMatches(text)
        .toList();

    final spans = <TextSpan>[];
    var end = 0;
    for (final match in matches) {
      spans.add(TextSpan(text: text.substring(end, match.start)));
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: const TextStyle(
          backgroundColor: Color(0xFFF28C9F), // highlight color
          color: Colors.black,
        ),
      ));
      end = match.end;
    }
    spans.add(TextSpan(text: text.substring(end)));

    // Show all lines if there is a match, so it isn't cut off
    final limit = matches.isEmpty ? maxLines : null;
    return Text.rich(
      TextSpan(children: spans),
      style: style,
      maxLines: limit,
      overflow: limit == null ? null : TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (photoPath != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(photoPath!),
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) =>
                    const Icon(Icons.broken_image),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              _highlight(
                entry.title,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (entry.text.isEmpty)
                const Text(
                  'No description',
                  style: TextStyle(color: Colors.grey),
                )
              else
                _highlight(entry.text, maxLines: 2),
              if (entry.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: entry.tags.map((tag) {
                    return Chip(
                      label: _highlight(tag),
                      backgroundColor: _tagColor(tag).withValues(alpha: 0.2),
                      side: BorderSide(color: _tagColor(tag)),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                DateFormat('d MMM yyyy').format(entry.date),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}