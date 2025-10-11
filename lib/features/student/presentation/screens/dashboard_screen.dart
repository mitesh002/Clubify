import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';

import '../../../auth/providers/auth_providers.dart';
import '../widgets/event_card.dart';
import '../widgets/club_card.dart';
import '../../../event/providers/event_providers.dart';
import '../../../club/providers/club_providers.dart';
import '../widgets/stats_card.dart';
import '../widgets/quick_action_card.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/services/club_membership_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();

  Future<void> _onRefresh() async {
    // No-op: streams auto-refresh; small delay for pull-to-refresh UX
    await Future.delayed(const Duration(milliseconds: 350));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.background,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Enhanced App Bar
              SliverAppBar(
                expandedHeight: 180,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                          theme.colorScheme.tertiary,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Row with Notifications
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Welcome Text
                                Expanded(
                                  child: currentUser.when(
                                    data: (user) => Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Hello,',
                                          style: theme.textTheme.titleLarge?.copyWith(
                                            color: Colors.white.withOpacity(0.9),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${user?.displayName ?? 'Student'}! 👋',
                                          style: theme.textTheme.headlineMedium?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 28,
                                          ),
                                        ),
                                      ],
                                    ),
                                    loading: () => Text(
                                      'Loading...',
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    error: (_, __) => Text(
                                      'Dashboard',
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                // Notification Icon
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      // TODO: Implement notifications
                                    },
                                    icon: Badge(
                                      smallSize: 8,
                                      backgroundColor: Colors.red,
                                      child: Icon(
                                        Icons.notifications_outlined,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Subtitle with decorative elements
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _getCurrentDate(),
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.school,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Student Portal',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Stats Cards
                    _buildStatsSection(),

                    const SizedBox(height: 24),

                    // Quick Actions
                    _buildQuickActionsSection(),

                    const SizedBox(height: 24),

                    // Upcoming Events
                    _buildUpcomingEventsSection(),

                    const SizedBox(height: 24),

                    // Popular Clubs
                    _buildPopularClubsSection(),

                    const SizedBox(
                        height: 100), // Bottom padding for navigation bar
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Stats',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 400.ms)
            .slideX(begin: -0.2, end: 0),
        const SizedBox(height: 16),
        currentUser.when(
          loading: () => _buildStatsShimmer(),
          error: (_, __) => _buildStatsShimmer(),
          data: (user) {
            if (user == null) return _buildStatsShimmer();
            
            return Row(
              children: [
                Expanded(
                  child: StatsCard(
                    title: 'Points',
                    value: '${user.points}',
                    icon: Icons.star,
                    color: theme.colorScheme.primary,
                    trend: '+15%',
                  )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 400.ms)
                      .slideY(begin: 0.3, end: 0),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FutureBuilder<int>(
                    future: UserService.getUserEventCount(user.id),
                    builder: (context, snapshot) {
                      final eventCount = snapshot.data ?? 0;
                      return StatsCard(
                        title: 'Events',
                        value: '$eventCount',
                        icon: Icons.event,
                        color: theme.colorScheme.secondary,
                        trend: '+2',
                      )
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 400.ms)
                          .slideY(begin: 0.3, end: 0);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FutureBuilder<int>(
                    future: UserService.getUserRank(user.id),
                    builder: (context, snapshot) {
                      final rank = snapshot.data ?? 0;
                      return StatsCard(
                        title: 'Rank',
                        value: rank > 0 ? '#$rank' : 'N/A',
                        icon: Icons.leaderboard,
                        color: theme.colorScheme.tertiary,
                        trend: '+3',
                      )
                          .animate()
                          .fadeIn(delay: 500.ms, duration: 400.ms)
                          .slideY(begin: 0.3, end: 0);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        )
            .animate()
            .fadeIn(delay: 600.ms, duration: 400.ms)
            .slideX(begin: -0.2, end: 0),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                title: 'Browse Events',
                icon: Icons.event_available,
                color: theme.colorScheme.primary,
                onTap: () {
                  // Navigate to announcements as a global feed shortcut
                  context.go('/student/announcements');
                },
              )
                  .animate()
                  .fadeIn(delay: 700.ms, duration: 400.ms)
                  .slideY(begin: 0.3, end: 0),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionCard(
                title: 'Directory',
                icon: Icons.explore,
                color: theme.colorScheme.secondary,
                onTap: () {
                  context.go('/student/directory');
                },
              )
                  .animate()
                  .fadeIn(delay: 800.ms, duration: 400.ms)
                  .slideY(begin: 0.3, end: 0),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUpcomingEventsSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Events',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to all events
              },
              child: const Text('View All'),
            ),
          ],
        )
            .animate()
            .fadeIn(delay: 900.ms, duration: 400.ms)
            .slideX(begin: -0.2, end: 0),
        const SizedBox(height: 16),
        Consumer(builder: (context, ref, _) {
          final upcoming = ref.watch(upcomingEventsProvider);
          return upcoming.when(
            loading: () => _buildEventsShimmer(),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Failed to load events: $e'),
            ),
            data: (events) {
              if (events.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('No upcoming events',
                      style: Theme.of(context).textTheme.bodyMedium),
                );
              }
              return SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final e = events[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index < events.length - 1 ? 16 : 0,
                      ),
                      child: SizedBox(
                        width: 280,
                        child: EventCard(
                          title: e.title,
                          clubName:
                              e.clubId, // could map to club name if needed
                          dateTime: e.dateTime,
                          venue: e.venue,
                          imageUrl: e.imageUrl,
                          onTap: () {
                            final queryParams = {
                              'clubId': e.clubId,
                              'title': e.title,
                              'description': e.description,
                              'dateTime': e.dateTime.toIso8601String(),
                              'venue': e.venue,
                              'maxParticipants': e.maxParticipants.toString(),
                              if (e.imageUrl != null) 'imageUrl': e.imageUrl!,
                            };
                            final queryString = queryParams.entries
                                .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
                                .join('&');
                            context.go('/student/event/${e.id}?$queryString');
                          },
                        ),
                      ),
                    );
                  },
                )
                    .animate()
                    .fadeIn(delay: 1000.ms, duration: 400.ms)
                    .slideX(begin: 0.3, end: 0),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildPopularClubsSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Popular Clubs',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to all clubs
              },
              child: const Text('View All'),
            ),
          ],
        )
            .animate()
            .fadeIn(delay: 1100.ms, duration: 400.ms)
            .slideX(begin: -0.2, end: 0),
        const SizedBox(height: 16),
        Consumer(builder: (context, ref, _) {
          final clubs = ref.watch(approvedClubsProvider);
          return clubs.when(
            loading: () => _buildClubsShimmer(),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Failed to load clubs: $e'),
            ),
            data: (list) {
              if (list.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('No clubs available',
                      style: Theme.of(context).textTheme.bodyMedium),
                );
              }
              return SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final club = list[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index < list.length - 1 ? 16 : 0,
                      ),
                      child: SizedBox(
                        width: 200,
                        child: FutureBuilder<Map<String, dynamic>>(
                          future: _getClubData(club.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return ClubCard(
                                name: club.name,
                                description: club.description,
                                memberCount: 0,
                                logoUrl: club.imageUrl,
                                onTap: () {},
                                membershipStatus: null,
                              );
                            }
                            
                            final data = snapshot.data ?? {};
                            final memberCount = data['memberCount'] ?? 0;
                            final membershipStatus = data['membershipStatus'];
                            
                            return ClubCard(
                              name: club.name,
                              description: club.description,
                              memberCount: memberCount,
                              logoUrl: club.imageUrl,
                              membershipStatus: membershipStatus,
                              onTap: () {
                                // TODO: Navigate to club details
                              },
                              onJoin: () async {
                                final user = ref.read(currentUserProvider).value;
                                if (user == null) return;
                                
                                final result = await ClubMembershipService.requestClubMembership(
                                  userId: user.id,
                                  clubId: club.id,
                                );
                                
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(result['message']),
                                      backgroundColor: result['success'] ? Colors.green : Colors.red,
                                    ),
                                  );
                                  
                                  if (result['success']) {
                                    // Refresh the widget
                                    setState(() {});
                                  }
                                }
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                )
                    .animate()
                    .fadeIn(delay: 1200.ms, duration: 400.ms)
                    .slideX(begin: 0.3, end: 0),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildStatsShimmer() {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventsShimmer() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: index < 2 ? 16 : 0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 280,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildClubsShimmer() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: index < 2 ? 16 : 0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _getClubData(String clubId) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) {
      return {
        'memberCount': 0,
        'membershipStatus': null,
      };
    }

    final memberCount = await UserService.getClubMemberCount(clubId);
    final membershipStatus = await ClubMembershipService.getUserClubStatus(user.id, clubId);

    return {
      'memberCount': memberCount,
      'membershipStatus': membershipStatus,
    };
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 
      'Friday', 'Saturday', 'Sunday'
    ];
    
    final weekday = weekdays[now.weekday - 1];
    final month = months[now.month - 1];
    final day = now.day;
    
    return '$weekday, $month $day';
  }
}
