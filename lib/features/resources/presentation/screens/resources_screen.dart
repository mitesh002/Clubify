import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResourcesScreen extends ConsumerStatefulWidget {
  final String clubId;
  const ResourcesScreen({super.key, required this.clubId});

  @override
  ConsumerState<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends ConsumerState<ResourcesScreen> {
  String _category = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final base = FirebaseFirestore.instance
        .collection('clubs')
        .doc(widget.clubId)
        .collection('resources')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources'),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _category,
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All')),
                DropdownMenuItem(value: 'Guides', child: Text('Guides')),
                DropdownMenuItem(value: 'Minutes', child: Text('Minutes')),
                DropdownMenuItem(value: 'EventKits', child: Text('EventKits')),
                DropdownMenuItem(value: 'Branding', child: Text('Branding')),
                DropdownMenuItem(value: 'Media', child: Text('Media')),
              ],
              onChanged: (v) => setState(() => _category = v ?? 'All'),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: base.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load: ${snapshot.error}'));
          }
          final docsAll = snapshot.data?.docs ?? [];
          final docs = docsAll.where((d) {
            final cat = (d.data()['category'] ?? '').toString();
            return _category == 'All' || cat == _category;
          }).toList();

          if (docs.isEmpty) {
            return Center(child: Text('No resources', style: theme.textTheme.bodyLarge));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final d = docs[index].data();
              final name = (d['name'] ?? '') as String;
              final type = (d['type'] ?? '') as String;
              final category = (d['category'] ?? '') as String;
              final path = (d['storagePath'] ?? d['linkUrl'] ?? '') as String;
              final visibility = (d['visibility'] ?? 'members') as String;

              return ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: theme.colorScheme.surface,
                leading: _buildTypeIcon(type, theme),
                title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text('$category · $visibility', maxLines: 1),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: open file/link
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(path.isNotEmpty ? path : 'No file')),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTypeIcon(String type, ThemeData theme) {
    switch (type) {
      case 'pdf':
        return Icon(Icons.picture_as_pdf, color: theme.colorScheme.primary);
      case 'image':
        return Icon(Icons.image, color: theme.colorScheme.primary);
      case 'video':
        return Icon(Icons.videocam, color: theme.colorScheme.primary);
      case 'doc':
        return Icon(Icons.description, color: theme.colorScheme.primary);
      case 'slide':
        return Icon(Icons.slideshow, color: theme.colorScheme.primary);
      case 'link':
        return Icon(Icons.link, color: theme.colorScheme.primary);
      default:
        return Icon(Icons.insert_drive_file, color: theme.colorScheme.primary);
    }
  }
}


