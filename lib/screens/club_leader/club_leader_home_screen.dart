import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/club_provider.dart';
import '../../providers/event_provider.dart';
import 'create_club_screen.dart';
import 'create_event_screen.dart';
import 'manage_registrations_screen.dart';
import 'event_history_screen.dart';
import 'club_profile_screen.dart';

class ClubLeaderHomeScreen extends StatefulWidget {
  const ClubLeaderHomeScreen({super.key});

  @override
  State<ClubLeaderHomeScreen> createState() => _ClubLeaderHomeScreenState();
}

class _ClubLeaderHomeScreenState extends State<ClubLeaderHomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const ClubProfileScreen(),
    const CreateEventScreen(),
    const ManageRegistrationsScreen(),
    const EventHistoryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final clubProvider = Provider.of<ClubProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    
    if (authProvider.user != null) {
      await clubProvider.loadCurrentClub(authProvider.user!.id);
      
      if (clubProvider.currentClub != null) {
        await eventProvider.loadEventsByClub(clubProvider.currentClub!.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group),
            label: 'Club Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Create Event',
          ),
          NavigationDestination(
            icon: Icon(Icons.manage_accounts_outlined),
            selectedIcon: Icon(Icons.manage_accounts),
            label: 'Manage',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
