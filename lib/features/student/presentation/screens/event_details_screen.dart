import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../auth/providers/auth_providers.dart';
import '../../../../core/services/event_attendance_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../../models/event_model.dart';

class EventDetailsScreen extends ConsumerStatefulWidget {
  final String eventId;
  final String clubId;
  final String title;
  final String description;
  final DateTime dateTime;
  final String venue;
  final int maxParticipants;
  final String? imageUrl;

  const EventDetailsScreen({
    super.key,
    required this.eventId,
    required this.clubId,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.venue,
    required this.maxParticipants,
    this.imageUrl,
  });

  @override
  ConsumerState<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends ConsumerState<EventDetailsScreen> {
  bool _isMarkingAttendance = false;
  bool _hasAttended = false;
  int _attendanceCount = 0;

  @override
  void initState() {
    super.initState();
    _checkAttendance();
    _getAttendanceCount();
  }

  Future<void> _checkAttendance() async {
    final user = ref.read(currentUserProvider).value;
    if (user != null) {
      final attended = await EventAttendanceService.didUserAttendEvent(
        user.id,
        widget.eventId,
      );
      if (mounted) {
        setState(() {
          _hasAttended = attended;
        });
      }
    }
  }

  Future<void> _getAttendanceCount() async {
    final count = await EventAttendanceService.getEventAttendanceCount(widget.eventId);
    if (mounted) {
      setState(() {
        _attendanceCount = count;
      });
    }
  }

  Future<void> _markAttendance() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    setState(() {
      _isMarkingAttendance = true;
    });

    try {
      final success = await EventAttendanceService.markAttendance(
        userId: user.id,
        eventId: widget.eventId,
        clubId: widget.clubId,
      );

      if (success) {
        // Award points for attendance
        await _awardPoints(user.id);
        
        if (mounted) {
          setState(() {
            _hasAttended = true;
            _attendanceCount++;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Attendance marked! +10 points awarded'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to mark attendance'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isMarkingAttendance = false;
        });
      }
    }
  }

  Future<void> _awardPoints(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
        'points': FieldValue.increment(10),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error awarding points: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPastEvent = widget.dateTime.isBefore(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          if (!isPastEvent && !_hasAttended)
            IconButton(
              onPressed: _isMarkingAttendance ? null : _markAttendance,
              icon: _isMarkingAttendance
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            if (widget.imageUrl != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(widget.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(begin: const Offset(0.9, 0.9))
            else
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.event,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(begin: const Offset(0.9, 0.9)),

            const SizedBox(height: 24),

            // Event Title
            Text(
              widget.title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .slideX(begin: -0.2, end: 0),

            const SizedBox(height: 16),

            // Event Details
            _buildDetailRow(
              icon: Icons.schedule,
              label: 'Date & Time',
              value: _formatDateTime(widget.dateTime),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 400.ms)
                .slideX(begin: -0.2, end: 0),

            const SizedBox(height: 12),

            _buildDetailRow(
              icon: Icons.location_on,
              label: 'Venue',
              value: widget.venue,
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 400.ms)
                .slideX(begin: -0.2, end: 0),

            const SizedBox(height: 12),

            _buildDetailRow(
              icon: Icons.people,
              label: 'Capacity',
              value: '${_attendanceCount}/${widget.maxParticipants}',
            )
                .animate()
                .fadeIn(delay: 500.ms, duration: 400.ms)
                .slideX(begin: -0.2, end: 0),

            const SizedBox(height: 24),

            // Description
            Text(
              'Description',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            )
                .animate()
                .fadeIn(delay: 600.ms, duration: 400.ms)
                .slideX(begin: -0.2, end: 0),

            const SizedBox(height: 8),

            Text(
              widget.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
              ),
            )
                .animate()
                .fadeIn(delay: 700.ms, duration: 400.ms)
                .slideX(begin: -0.2, end: 0),

            const SizedBox(height: 24),

            // Attendance Status
            if (_hasAttended)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You attended this event!',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 800.ms, duration: 400.ms)
                  .scale(begin: const Offset(0.9, 0.9)),

            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.isNegative) {
      return 'Event has ended';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} from now';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} from now';
    } else {
      return 'Starting soon';
    }
  }
}