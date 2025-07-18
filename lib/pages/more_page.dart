import 'package:flutter/material.dart';
import 'package:microrealeaste/widgets/framework_page.dart';
import 'package:microrealeaste/widgets/custom_buttons.dart';
import 'package:microrealeaste/pages/settings_page.dart';
import 'package:microrealeaste/pages/rent_payments_page.dart';
import 'package:microrealeaste/pages/organization_management_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:microrealeaste/providers/auth_provider.dart';
import 'package:microrealeaste/database/models/user.dart';

PageRouteBuilder _fadeRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isOrgAdmin = user != null && (
      user.role == UserRole.superAdmin ||
      user.rolesByOrg.values.contains(UserRole.organizationAdmin) ||
      user.role == UserRole.organizationAdmin
    );
    return FrameworkPage(
      title: 'More',
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: Column(
              children: [
                if (isOrgAdmin)
                  CustomActionButton(
                    label: 'Organization Management',
                    icon: Icons.business,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const OrganizationManagementPage()),
                    ),
                  ),
                if (isOrgAdmin) const SizedBox(height: 24),
                CustomActionButton(
                  label: 'Settings & Customization',
                  icon: Icons.settings,
                  onTap: () => Navigator.of(context).push(_fadeRoute(const SettingsPage())),
                ),
                const SizedBox(height: 24),
                CustomActionButton(
                  label: 'Payments',
                  icon: Icons.payment,
                  onTap: () => Navigator.of(context).push(_fadeRoute(const RentPaymentsPage())),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
} 