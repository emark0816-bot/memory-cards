import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../data/sample_entries.dart';
import '../models/entry.dart';
import '../utils/storage.dart';

class CreateEntryScreen extends StatefulWidget {
  // If an entry is given, the screen edits it
  const CreateEntryScreen({super.key, this.entry, this.photoPath});

  final Entry? entry;
  final String? photoPath;

  @override
  State<CreateEntryScreen> createState() => _CreateEntryScreenState();
}

class _CreateEntryScreenState extends State<CreateEntryScreen> {
  final _titleController = TextEditingController();
  final _textController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final Set<String> _selectedTags = {};
  String? _photoPath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Fill in the form when editing
    final entry = widget.entry;
    if (entry != null) {
      _titleController.text = entry.title;
      _textController.text = entry.text;
      _selectedDate = entry.date;
      _selectedTags.addAll(entry.tags);
      _photoPath = widget.photoPath;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
      );
      if (picked == null) return;
      final folder = await getApplicationDocumentsDirectory();
      final name = '${DateTime.now().millisecondsSinceEpoch}_${picked.name}';
      final copy = await File(picked.path).copy('${folder.path}/$name');
      if (!mounted) return;
      setState(() => _photoPath = copy.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo error: $e')),
      );
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a title'),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }
    _saving = true;

    final newEntry = Entry(
      // Keep the same id when editing
      id: widget.entry?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      text: _textController.text.trim(),
      date: _selectedDate,
      tags: _selectedTags.toList(),
    );

    final photo = _photoPath;
    if (photo != null) await savePhoto(newEntry.id, photo);
    if (!mounted) return;
    Navigator.pop(context, newEntry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? 'New Memory' : 'Edit Memory'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Give this memory a name',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'What happened?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(DateFormat('EEE, d MMM yyyy').format(_selectedDate)),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickPhoto,
              icon: const Icon(Icons.photo),
              label: Text(_photoPath == null ? 'Add photo' : 'Change photo'),
            ),
            if (_photoPath != null) ...[
              const SizedBox(height: 8),
              Image.file(File(_photoPath!), height: 180, fit: BoxFit.cover),
            ],
            const SizedBox(height: 16),
            const Text('Tags', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: availableTags.map((tag) {
                return FilterChip(
                  label: Text(tag),
                  selected: _selectedTags.contains(tag),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}