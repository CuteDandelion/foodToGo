import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodbegood/config/routes.dart';
import 'package:foodbegood/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:foodbegood/shared/services/mock_data_service.dart';

/// Profile page with digital ID card
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()..add(const ProfileLoad()),
      child: const _ProfilePageContent(),
    );
  }
}

class _ProfilePageContent extends StatelessWidget {
  const _ProfilePageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.goStudentDashboard();
            }
          },
        ),
        title: const Text('My Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.goSettings(),
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state.status == ProfileStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ProfileStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? 'An error occurred',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProfileBloc>().add(const ProfileLoad());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.user == null) {
            return const Center(child: Text('No profile data'));
          }

          final user = state.user;
          if (user == null) {
            return const Center(child: Text('No profile data available'));
          }

          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Digital ID Card
                _DigitalIDCard(user: user),

                const SizedBox(height: 24),

                // Stats Section
                _StatsSection(state: state),

                const SizedBox(height: 24),

                // Quick Actions
                _QuickActions(),

                const SizedBox(height: 24),

                // Account Information
                _AccountInfo(user: user),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Digital ID Card widget
class _DigitalIDCard extends StatelessWidget {
  final User user;

  const _DigitalIDCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withAlpha(204),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withAlpha(77),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(26),
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(26),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.school,
                            color: Colors.white.withAlpha(230),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'MRU Student ID',
                            style: textTheme.titleMedium?.copyWith(
                                  color: Colors.white.withAlpha(230),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(51),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Active',
                          style: textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Profile Photo and Name
                  Row(
                    children: [
                      // Profile Photo
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(51),
                          border: Border.all(
                            color: Colors.white.withAlpha(128),
                            width: 3,
                          ),
                          image: user.profile.photoPath != null
                              ? DecorationImage(
                                  image: NetworkImage(user.profile.photoPath!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: user.profile.photoPath == null
                            ? Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white.withAlpha(230),
                              )
                            : null,
                      ),

                      const SizedBox(width: 16),

                      // Name and Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.profile.fullName,
                              style: textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.profile.department ?? 'Student',
                              style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withAlpha(204),
                                  ),
                            ),
                            if (user.profile.yearOfStudy != null)
                        Text(
                          'Year ${user.profile.yearOfStudy}',
                          style: textTheme.bodySmall?.copyWith(
                                color: Colors.white.withAlpha(179),
                              ),
                        ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Student ID
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          color: Colors.white.withAlpha(204),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Student ID',
                                style: textTheme.bodySmall?.copyWith(
                                      color: Colors.white.withAlpha(179),
                                    ),
                              ),
                              Text(
                                user.studentId,
                                style: textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // QR Code
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // Simulated QR code
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CustomPaint(
                              size: const Size(120, 120),
                              painter: _MiniQRCodePainter(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Scan for verification',
                            style: textTheme.bodySmall?.copyWith(
                                  color: Colors.black54,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stats section widget
class _StatsSection extends StatelessWidget {
  final ProfileState state;

  const _StatsSection({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.restaurant,
            value: '${state.totalMeals}',
            label: 'Meals Saved',
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.trending_up,
            value: state.monthlyAverage.toStringAsFixed(1),
            label: 'Avg/Month',
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department,
            value: '${state.currentStreak}',
            label: 'Day Streak',
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}

/// Individual stat card
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Quick actions section
class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.history,
                label: 'Meal History',
                onTap: () => context.goMealHistory(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.qr_code,
                label: 'My QR Code',
                onTap: () {
                  // Navigate to QR code page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('QR Code feature coming soon!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.edit,
                label: 'Edit Profile',
                onTap: () {
                  // Show edit profile dialog
                  _showEditProfileDialog(context);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: const Text('Profile editing will be available in the next update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Action button widget
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Account information section
class _AccountInfo extends StatelessWidget {
  final User user;

  const _AccountInfo({required this.user});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _InfoTile(
            icon: Icons.person_outline,
            title: 'Full Name',
            subtitle: user.profile.fullName,
          ),
          const Divider(height: 1),
          _InfoTile(
            icon: Icons.badge_outlined,
            title: 'Student ID',
            subtitle: user.studentId,
          ),
          const Divider(height: 1),
          _InfoTile(
            icon: Icons.school_outlined,
            title: 'Department',
            subtitle: user.profile.department ?? 'Not specified',
          ),
          if (user.profile.yearOfStudy != null) ...[
            const Divider(height: 1),
            _InfoTile(
              icon: Icons.calendar_today_outlined,
              title: 'Year of Study',
              subtitle: 'Year ${user.profile.yearOfStudy}',
            ),
          ],
          const Divider(height: 1),
          _InfoTile(
            icon: Icons.verified_user_outlined,
            title: 'Account Type',
            subtitle: user.role.displayName,
          ),
        ],
      ),
    );
  }
}

/// Info tile widget
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withAlpha(153),
                      ),
                ),
                Text(
                  subtitle,
                  style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mini QR code painter for ID card
class _MiniQRCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final cellSize = size.width / 21;

    // Draw finder patterns
    _drawFinderPattern(canvas, paint, Offset(cellSize, cellSize), cellSize * 7);
    _drawFinderPattern(canvas, paint, Offset(size.width - 8 * cellSize, cellSize), cellSize * 7);
    _drawFinderPattern(canvas, paint, Offset(cellSize, size.height - 8 * cellSize), cellSize * 7);

    // Draw some data modules
    for (var row = 0; row < 21; row++) {
      for (var col = 0; col < 21; col++) {
        if ((row < 8 && col < 8) ||
            (row < 8 && col > 12) ||
            (row > 12 && col < 8)) {
          continue;
        }

        if ((row + col) % 3 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(
              col * cellSize,
              row * cellSize,
              cellSize - 0.5,
              cellSize - 0.5,
            ),
            paint,
          );
        }
      }
    }
  }

  void _drawFinderPattern(Canvas canvas, Paint paint, Offset offset, double size) {
    canvas.drawRect(
      Rect.fromLTWH(offset.dx, offset.dy, size, size),
      paint,
    );

    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(offset.dx + size * 0.15, offset.dy + size * 0.15, size * 0.7, size * 0.7),
      whitePaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(offset.dx + size * 0.3, offset.dy + size * 0.3, size * 0.4, size * 0.4),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
