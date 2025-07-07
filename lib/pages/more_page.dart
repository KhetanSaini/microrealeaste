import 'package:flutter/material.dart';
import 'package:microrealeaste/widgets/framework_page.dart';
import 'package:microrealeaste/widgets/custom_buttons.dart';
import 'package:microrealeaste/pages/settings_page.dart';
import 'package:microrealeaste/pages/rent_payments_page.dart';

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

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FrameworkPage(
      title: 'More',
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: Column(
              children: [
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