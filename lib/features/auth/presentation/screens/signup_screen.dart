import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/auth_providers.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_login_button.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _courseController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _clubNameController = TextEditingController();
  final _clubDescriptionController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedRole = 'student';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _courseController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _clubNameController.dispose();
    _clubDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authControllerProvider.notifier).signUpWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          course: _courseController.text.trim(),
          role: _selectedRole,
          leaderClubName: _selectedRole == 'club_leader'
              ? _clubNameController.text.trim()
              : null,
          leaderClubDescription: _selectedRole == 'club_leader'
              ? _clubDescriptionController.text.trim()
              : null,
        );

    if (!mounted) return;
    final authState = ref.read(authControllerProvider);
    authState.when(
      data: (user) {
        if (user == null) return;
        if (user.role == 'club_leader') {
          context.go('/club-leader');
        } else {
          context.go('/student');
        }
      },
      error: (err, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      },
      loading: () {},
    );
  }

  Future<void> _signInWithGoogle() async {
    // Google sign-in not wired yet; show message instead of crashing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Google sign-in not configured'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );

    // No navigation for Google path until configured
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Welcome Text
            Text(
              'Create Account',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 100.ms, duration: 400.ms)
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: 8),

            Text(
              'Join our community and start your journey!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: 32),

            // Name Field
            CustomTextField(
              controller: _nameController,
              label: 'Full Name',
              hintText: 'Enter your full name',
              prefixIcon: Icons.person_outline,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                if (value.length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 400.ms)
                .slideX(begin: -0.2, end: 0),

            const SizedBox(height: 16),

            // Email Field
            CustomTextField(
              controller: _emailController,
              label: 'Email',
              hintText: 'Enter your email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 400.ms)
                .slideX(begin: -0.2, end: 0),

            const SizedBox(height: 16),

            // Course Field
            CustomTextField(
              controller: _courseController,
              label: 'Course/Department',
              hintText: 'Enter your course or department',
              prefixIcon: Icons.school_outlined,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your course';
                }
                return null;
              },
            )
                .animate()
                .fadeIn(delay: 500.ms, duration: 400.ms)
                .slideX(begin: -0.2, end: 0),

            const SizedBox(height: 16),

            // Role Selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Role',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Student'),
                        value: 'student',
                        groupValue: _selectedRole,
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Club Leader'),
                        value: 'club_leader',
                        groupValue: _selectedRole,
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ],
            )
                .animate()
                .fadeIn(delay: 600.ms, duration: 400.ms)
                .slideX(begin: -0.2, end: 0),

            const SizedBox(height: 16),

            // Club fields (shown only if Club Leader)
            if (_selectedRole == 'club_leader') ...[
              CustomTextField(
                controller: _clubNameController,
                label: 'Club Name',
                hintText: 'Enter the club name',
                prefixIcon: Icons.business_outlined,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (_selectedRole == 'club_leader') {
                    if (value == null || value.isEmpty) {
                      return 'Please enter club name';
                    }
                  }
                  return null;
                },
              )
                  .animate()
                  .fadeIn(delay: 520.ms, duration: 400.ms)
                  .slideX(begin: -0.2, end: 0),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _clubDescriptionController,
                label: 'Club Description',
                hintText: 'Describe the club',
                prefixIcon: Icons.description_outlined,
                textInputAction: TextInputAction.next,
                maxLines: 3,
                validator: (value) {
                  if (_selectedRole == 'club_leader') {
                    if (value == null || value.isEmpty) {
                      return 'Please enter club description';
                    }
                  }
                  return null;
                },
              )
                  .animate()
                  .fadeIn(delay: 540.ms, duration: 400.ms)
                  .slideX(begin: -0.2, end: 0),
              const SizedBox(height: 16),
            ],

            // Password Field
            CustomTextField(
              controller: _passwordController,
              label: 'Password',
              hintText: 'Enter your password',
              prefixIcon: Icons.lock_outline,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            )
                .animate()
                .fadeIn(delay: 700.ms, duration: 400.ms)
                .slideX(begin: -0.2, end: 0),

            const SizedBox(height: 16),

            // Confirm Password Field
            CustomTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              hintText: 'Confirm your password',
              prefixIcon: Icons.lock_outline,
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
              onFieldSubmitted: (_) => _signUp(),
            )
                .animate()
                .fadeIn(delay: 800.ms, duration: 400.ms)
                .slideX(begin: -0.2, end: 0),

            const SizedBox(height: 32),

            // Sign Up Button
            Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: authState.isLoading ? null : _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: authState.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            )
                .animate()
                .fadeIn(delay: 900.ms, duration: 400.ms)
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: 24),

            // Divider
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'or',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 1000.ms, duration: 400.ms),

            const SizedBox(height: 24),

            // Google Sign In
            SocialLoginButton(
              onPressed: authState.isLoading ? null : _signInWithGoogle,
              icon: Icons.g_mobiledata,
              label: 'Continue with Google',
              backgroundColor: Colors.white,
              textColor: theme.colorScheme.onSurface,
              borderColor: theme.colorScheme.outline.withOpacity(0.3),
            )
                .animate()
                .fadeIn(delay: 1100.ms, duration: 400.ms)
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
