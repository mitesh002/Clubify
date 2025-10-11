import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/event_provider.dart';
import '../../providers/club_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/registration_model.dart';
import '../../models/event_model.dart';

class ManageRegistrationsScreen extends StatefulWidget {
  const ManageRegistrationsScreen({super.key});

  @override
  State<ManageRegistrationsScreen> createState() => _ManageRegistrationsScreenState();
}

class _ManageRegistrationsScreenState extends State<ManageRegistrationsScreen> {
  List<EventModel> _clubEvents = [];
  EventModel? _selectedEvent;
  List<RegistrationModel> _eventRegistrations = [];

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
        
        if (mounted) {
          setState(() {
            _clubEvents = eventProvider.events;
            if (_clubEvents.isNotEmpty) {
              _selectedEvent = _clubEvents.first;
              _loadEventRegistrations(_clubEvents.first.id);
            }
          });
        }
      }
    }
  }

  Future<void> _loadEventRegistrations(String eventId) async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    await eventProvider.loadRegistrationsForEvent(eventId);
    
    if (mounted) {
      setState(() {
        _eventRegistrations = eventProvider.registrations;
      });
    }
  }

  Future<void> _updateRegistrationStatus(
    String registrationId,
    String status,
    String? notes,
  ) async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    
    final success = await eventProvider.updateRegistrationStatus(
      registrationId: registrationId,
      status: status,
      notes: notes,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration $status successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      if (_selectedEvent != null) {
        await _loadEventRegistrations(_selectedEvent!.id);
      }
    } else if (mounted && eventProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(eventProvider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRegistrationDialog(RegistrationModel registration) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Manage Registration'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Student ID: ${registration.studentId}'),
              const SizedBox(height: 8),
              Text('Status: ${registration.status}'),
              const SizedBox(height: 8),
              Text('Registered: ${DateFormat('MMM dd, yyyy • hh:mm a').format(registration.registeredAt)}'),
              if (registration.notes != null && registration.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Notes: ${registration.notes}'),
              ],
            ],
          ),
          actions: [
            if (registration.status == 'registered') ...[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _updateRegistrationStatus(registration.id, 'approved', null);
                },
                child: const Text('Approve'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _updateRegistrationStatus(registration.id, 'rejected', 'Registration rejected');
                },
                child: const Text('Reject'),
              ),
            ],
            if (registration.status == 'approved') ...[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _updateRegistrationStatus(registration.id, 'attended', null);
                },
                child: const Text('Mark as Attended'),
              ),
            ],
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Registrations'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Consumer<ClubProvider>(
        builder: (context, clubProvider, child) {
          if (clubProvider.currentClub == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.group_off,
                      size: 80,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Club Found',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please create a club first to manage registrations',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          if (_clubEvents.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 80,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Events Found',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create events to manage registrations',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              // Event Selector
              Container(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<EventModel>(
                  value: _selectedEvent,
                  decoration: const InputDecoration(
                    labelText: 'Select Event',
                    border: OutlineInputBorder(),
                  ),
                  items: _clubEvents.map((event) {
                    return DropdownMenuItem(
                      value: event,
                      child: Text(event.title),
                    );
                  }).toList(),
                  onChanged: (EventModel? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedEvent = newValue;
                      });
                      _loadEventRegistrations(newValue.id);
                    }
                  },
                ),
              ),

              // Registrations List
              Expanded(
                child: _eventRegistrations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No registrations yet',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Students will appear here when they register',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _eventRegistrations.length,
                        itemBuilder: (context, index) {
                          final registration = _eventRegistrations[index];
                          return _buildRegistrationCard(context, registration);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRegistrationCard(BuildContext context, RegistrationModel registration) {
    Color statusColor;
    IconData statusIcon;
    
    switch (registration.status) {
      case 'registered':
        statusColor = Theme.of(context).colorScheme.primary;
        statusIcon = Icons.event_available;
        break;
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'attended':
        statusColor = Colors.blue;
        statusIcon = Icons.event;
        break;
      default:
        statusColor = Theme.of(context).colorScheme.outline;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showRegistrationDialog(registration),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: statusColor.withOpacity(0.1),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Student ID: ${registration.studentId}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Registered: ${DateFormat('MMM dd, yyyy • hh:mm a').format(registration.registeredAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    if (registration.approvedAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Approved: ${DateFormat('MMM dd, yyyy • hh:mm a').format(registration.approvedAt!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  registration.status.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
