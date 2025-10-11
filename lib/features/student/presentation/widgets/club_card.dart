import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ClubCard extends StatelessWidget {
  final String name;
  final String description;
  final int memberCount;
  final String? logoUrl;
  final VoidCallback onTap;
  final VoidCallback? onJoin;
  final String? membershipStatus; // 'member', 'pending', 'rejected', null
  final String? joinButtonText;

  const ClubCard({
    super.key,
    required this.name,
    required this.description,
    required this.memberCount,
    this.logoUrl,
    required this.onTap,
    this.onJoin,
    this.membershipStatus,
    this.joinButtonText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Club Logo
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.8),
                          theme.colorScheme.secondary.withOpacity(0.6),
                        ],
                      ),
                    ),
                    child: logoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: logoUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => _buildLogoPlaceholder(theme),
                              errorWidget: (context, url, error) => _buildLogoPlaceholder(theme),
                            ),
                          )
                        : _buildLogoPlaceholder(theme),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.people,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$memberCount members',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),

              // Description
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Join Button
              GestureDetector(
                onTap: _getButtonAction(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: _getButtonGradient(theme),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getButtonBorderColor(theme),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _getButtonText(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: _getButtonTextColor(theme),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoPlaceholder(ThemeData theme) {
    return Icon(
      Icons.groups,
      color: Colors.white,
      size: 24,
    );
  }

  VoidCallback? _getButtonAction() {
    if (membershipStatus == 'member' || membershipStatus == 'leader') {
      return onTap; // Navigate to club details
    } else if (membershipStatus == 'pending') {
      return null; // Disabled
    } else {
      return onJoin; // Join club
    }
  }

  String _getButtonText() {
    if (joinButtonText != null) return joinButtonText!;
    
    switch (membershipStatus) {
      case 'member':
      case 'leader':
        return 'View Details';
      case 'pending':
        return 'Request Pending';
      case 'rejected':
        return 'Request Rejected';
      default:
        return 'Join';
    }
  }

  LinearGradient _getButtonGradient(ThemeData theme) {
    switch (membershipStatus) {
      case 'member':
      case 'leader':
        return LinearGradient(
          colors: [
            Colors.green.withOpacity(0.1),
            Colors.green.withOpacity(0.05),
          ],
        );
      case 'pending':
        return LinearGradient(
          colors: [
            Colors.orange.withOpacity(0.1),
            Colors.orange.withOpacity(0.05),
          ],
        );
      case 'rejected':
        return LinearGradient(
          colors: [
            Colors.red.withOpacity(0.1),
            Colors.red.withOpacity(0.05),
          ],
        );
      default:
        return LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.1),
          ],
        );
    }
  }

  Color _getButtonBorderColor(ThemeData theme) {
    switch (membershipStatus) {
      case 'member':
      case 'leader':
        return Colors.green.withOpacity(0.3);
      case 'pending':
        return Colors.orange.withOpacity(0.3);
      case 'rejected':
        return Colors.red.withOpacity(0.3);
      default:
        return theme.colorScheme.primary.withOpacity(0.3);
    }
  }

  Color _getButtonTextColor(ThemeData theme) {
    switch (membershipStatus) {
      case 'member':
      case 'leader':
        return Colors.green.shade700;
      case 'pending':
        return Colors.orange.shade700;
      case 'rejected':
        return Colors.red.shade700;
      default:
        return theme.colorScheme.primary;
    }
  }
}
