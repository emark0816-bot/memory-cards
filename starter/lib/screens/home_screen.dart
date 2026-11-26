import 'package:flutter/material.dart';
import '../models/entry.dart';
import '../utils/storage.dart';
import '../widgets/entry_card.dart';
import 'create_entry_screen.dart';
import 'entry_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Entry> _entries = [];
  Map<String, String> _photos = {};
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final saved = await loadEntries();
    final photos = await loadPhotos();
    if (!mounted) return;
    setState(() {
      _entries = saved;
      _photos = photos;
    });
  }

  Future<void> _openCreateScreen() async {
    final newEntry = await Navigator.push<Entry>(
      context,
      MaterialPageRoute(builder: (context) => const CreateEntryScreen()),
    );
    if (newEntry == null) return;
    final photos = await loadPhotos();
    if (!mounted) return;
    setState(() {
      _photos = photos;
      _entries.insert(0, newEntry);
    });
    saveEntries(_entries);
  }

  void _openDetail(Entry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EntryDetailScreen(
          entry: entry,
          photoPath: _photos[entry.id],
          onUpdated: _updateEntry,
        ),
      ),
    );
  }

  // Saves an edited memory
  Future<void> _updateEntry(Entry updated) async {
    final photos = await loadPhotos();
    if (!mounted) return;
    setState(() {
      final index = _entries.indexWhere((e) => e.id == updated.id);
      if (index != -1) _entries[index] = updated;
      _photos = photos;
    });
    await saveEntries(_entries);
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  List<Entry> get _filteredEntries {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _entries;
    return _entries.where((e) {
      return e.title.toLowerCase().contains(query) ||
          e.text.toLowerCase().contains(query) ||
          e.tags.any((tag) => tag.toLowerCase().contains(query));
    }).toList();
  }

  Future<bool> _confirmDelete() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete entry?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Widget _emptyState(IconData icon, String message, {bool showButton = false}) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            if (showButton) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _openCreateScreen,
                icon: const Icon(Icons.add),
                label: const Text('Create a memory'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_entries.isEmpty) {
      return _emptyState(
        Icons.auto_stories_outlined,
        'Your story starts here.\nSave your first memory!',
        showButton: true,
      );
    }
    final results = _filteredEntries;
    if (results.isEmpty) {
      return _emptyState(Icons.search_off, 'No results found');
    }
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final entry = results[index];
        return Dismissible(
          key: ValueKey(entry.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) => _confirmDelete(),
          onDismissed: (direction) {
            setState(() => _entries.removeWhere((e) => e.id == entry.id));
            saveEntries(_entries);
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _openDetail(entry),
            child: EntryCard(
              entry: entry,
              photoPath: _photos[entry.id],
              query: _query,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memory Cards (${_entries.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: 'Search memories',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(child: _buildList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateScreen,
        tooltip: 'Add memory',
        child: const Icon(Icons.add),
      ),
    );
  }
}