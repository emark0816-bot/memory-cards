import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/entry.dart';
import '../utils/storage.dart';
import 'create_entry_screen.dart';

class EntryDetailScreen extends StatefulWidget {
  const EntryDetailScreen({
    super.key,
    required this.entry,
    required this.onUpdated,
    this.photoPath,
  });

  final Entry entry;
  final String? photoPath;
  final Future<void> Function(Entry) onUpdated;

  @override
  State<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen> {
  late Entry _entry = widget.entry;
  late String? _photoPath = widget.photoPath;

  Future<void> _edit() async {
    final updated = await Navigator.push<Entry>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEntryScreen(
          entry: _entry,
          photoPath: _photoPath,
        ),
      ),
    );
    if (updated == null) return;

    await widget.onUpdated(updated);
    final photos = await loadPhotos();
    if (!mounted) return;
    setState(() {
      _entry = updated;
      _photoPath = photos[updated.id];
    });
  }

  @override
  Widget build(BuildContext context) {
    final photo = _photoPath;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit memory',
            onPressed: _edit,
          ),
        ],
      ),
      body: SafeArea(
        // The card stretches over the whole page
        child: SizedBox.expand(
          child: Card(
            margin: const EdgeInsets.all(12),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (photo != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(photo),
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                      errorBuilder: (context, error, stack) =>
                      const Text('The photo could not be loaded'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  _entry.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('EEE, d MMM yyyy').format(_entry.date),
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Text(_entry.text, style: const TextStyle(fontSize: 16)),
                if (_entry.tags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _entry.tags.map((tag) {
                      return Chip(label: Text(tag));
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}