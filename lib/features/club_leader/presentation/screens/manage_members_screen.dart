import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../auth/providers/auth_providers.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/models/user_model.dart';
// Removed dependency on legacy ClubProvider; write directly to Firestore

class ManageMembersScreen extends ConsumerStatefulWidget {
  const ManageMembersScreen({super.key});

  @override
  ConsumerState<ManageMembersScreen> createState() =>
      _ManageMembersScreenState();
}

class _ManageMembersScreenState extends ConsumerState<ManageMembersScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Membership Requests'),
      ),
      body: currentUser.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Not signed in'));
          }

          final clubQuery = FirebaseFirestore.instance
              .collection('clubs')
              .where('leaderId', isEqualTo: user.id)
              .limit(1)
              .snapshots();

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: clubQuery,
            builder: (context, clubSnap) {
              if (clubSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (clubSnap.hasError) {
                return Center(child: Text('Error: ${clubSnap.error}'));
              }
              if (clubSnap.data == null || clubSnap.data!.docs.isEmpty) {
                return const Center(
                    child: Text('No club found for this leader'));
              }

              final clubDoc = clubSnap.data!.docs.first;
              final clubId = clubDoc.id;

              final pendingMembersStream = FirebaseFirestore.instance
                  .collection('clubs')
                  .doc(clubId)
                  .collection('members')
                  .where('role', isEqualTo: 'pending')
                  .snapshots();

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: pendingMembersStream,
                builder: (context, membersSnap) {
                  if (membersSnap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (membersSnap.hasError) {
                    return Center(child: Text('Error: ${membersSnap.error}'));
                  }

                  var docs = membersSnap.data?.docs ?? [];
                  // Sort client-side by requestedAt desc to avoid composite index requirement
                  docs.sort((a, b) {
                    final ra = a.data()['requestedAt'];
                    final rb = b.data()['requestedAt'];
                    final da = ra is Timestamp ? ra.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
                    final db = rb is Timestamp ? rb.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
                    return db.compareTo(da);
                  });
                  if (docs.isEmpty) {
                    return const Center(child: Text('No pending requests'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final d = docs[index];
                      final memberId = d.id;
                      final requestedAt = d.data()['requestedAt'];
                      final requestedAtText = requestedAt is Timestamp
                          ? _formatDate(requestedAt.toDate())
                          : '-';

                      return FutureBuilder<UserModel?>(
                        future: UserService.getUserById(memberId),
                        builder: (context, userSnapshot) {
                          final user = userSnapshot.data;
                          
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: theme.colorScheme.primary,
                                  child: user != null
                                      ? Text(
                                          user.initials,
                                          style: TextStyle(
                                            color: theme.colorScheme.onPrimary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : const Icon(Icons.person),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user?.name ?? 'Loading...',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (user != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          user.email,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          user.course,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 4),
                                      Text(
                                        'Requested: $requestedAtText',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                    ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () async {
                                    try {
                                      await FirebaseFirestore.instance
                                          .collection('clubs')
                                          .doc(clubId)
                                          .collection('members')
                                          .doc(memberId)
                                          .set({
                                        'role': 'rejected',
                                        'approvedAt': null,
                                        'joinedAt': null,
                                      }, SetOptions(merge: true));
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                              content: Text('Request rejected')),
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Failed: $e')),
                                        );
                                      }
                                    }
                                  },
                                ),
                                IconButton(
                                  icon:
                                      const Icon(Icons.check, color: Colors.green),
                                  onPressed: () async {
                                    try {
                                      await FirebaseFirestore.instance
                                          .collection('clubs')
                                          .doc(clubId)
                                          .collection('members')
                                          .doc(memberId)
                                          .set({
                                        'role': 'member',
                                        'approvedAt': FieldValue.serverTimestamp(),
                                        'joinedAt': FieldValue.serverTimestamp(),
                                      }, SetOptions(merge: true));
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                              content: Text('Request approved')),
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Failed: $e')),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: docs.length,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}

// Legacy ClubProvider removed
