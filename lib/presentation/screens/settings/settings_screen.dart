import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:focusmate/core/router/app_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile card placeholder
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.15),
                    child: Icon(
                      Icons.person_rounded,
                      size: 36,
                      color:
                          Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FocusMate User',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall,
                        ),
                        Text(
                          'Local account',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.5),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          Text(
            'General',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          _SettingsTile(
            icon: Icons.task_alt_rounded,
            title: 'Completed Tasks',
            onTap: () => context.push(AppRoutes.completedTasks),
          ),
          _SettingsTile(
            icon: Icons.repeat_rounded,
            title: 'Manage Routines',
            onTap: () => context.push(AppRoutes.routines),
          ),
          _SettingsTile(
            icon: Icons.notifications_rounded,
            title: 'Notification Settings',
            onTap: () {},
          ),

          const SizedBox(height: 16),
          Text(
            'Appearance',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          _SettingsTile(
            icon: Icons.dark_mode_rounded,
            title: 'Theme',
            trailing: const Text('System'),
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.text_fields_rounded,
            title: 'Text Size',
            onTap: () {},
          ),

          const SizedBox(height: 16),
          Text(
            'About',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'App Version',
            trailing: const Text('1.0.0'),
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon,
            color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        trailing: trailing ??
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.4),
            ),
        onTap: onTap,
      ),
    );
  }
}
