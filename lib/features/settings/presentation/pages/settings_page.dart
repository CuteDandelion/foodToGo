import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../config/routes.dart';
import '../bloc/theme_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          // Profile Header
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50.r,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    size: 50.w,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Zain Ul Ebad',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  'Student at MRU',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 32.h),

          // Settings Options
          _buildSettingTile(
            context,
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English',
            onTap: () {},
          ),
          _buildSettingTile(
            context,
            icon: Icons.person_outline,
            title: 'Account Management',
            onTap: () => context.goProfile(),
          ),
          _buildSettingTile(
            context,
            icon: Icons.history,
            title: 'Meal History',
            onTap: () => context.goMealHistory(),
          ),
          _buildSettingTile(
            context,
            icon: Icons.description_outlined,
            title: 'Regulations & Terms',
            onTap: () {},
          ),

          // Dark Mode Toggle
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    state.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(
                  'Dark Mode',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                value: state.isDarkMode,
                onChanged: (_) {
                  context.read<ThemeBloc>().add(ThemeToggled());
                },
              );
            },
          ),

          _buildSettingTile(
            context,
            icon: Icons.share_outlined,
            title: 'Social Media',
            onTap: () {},
          ),

          SizedBox(height: 32.h),

          // Sign Out Button
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 56.h),
            ),
            child: const Text('Sign Out'),
          ),

          SizedBox(height: 16.h),

          // Version
          Center(
            child: Text(
              'FoodBeGood v1.0.0',
              style: TextStyle(
                fontSize: 12.sp,
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 13.sp,
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
              ),
            )
          : null,
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16.w,
        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.4),
      ),
      onTap: onTap,
    );
  }
}
