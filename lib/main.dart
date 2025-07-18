import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:microrealeaste/database/data_service.dart';
import 'package:microrealeaste/pages/landlord_home_page.dart';
import 'package:microrealeaste/pages/properties_page.dart';
import 'package:microrealeaste/pages/rent_payments_page.dart';
import 'package:microrealeaste/pages/tenants_page.dart';
import 'package:microrealeaste/pages/settings_page.dart';
import 'package:microrealeaste/pages/login_page.dart';
import 'package:microrealeaste/pages/more_page.dart';
import 'package:microrealeaste/providers/app_providers.dart';
import 'package:microrealeaste/providers/auth_provider.dart';
import 'package:microrealeaste/providers/theme_provider.dart';
import 'package:microrealeaste/database/models/organization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataService.initialize();
  runApp(
    ProviderScope(
      child: const PropertyManagerApp(),
    ),
  );
}

class PropertyManagerApp extends ConsumerWidget {
  const PropertyManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final appTheme = ref.watch(themeProvider);
    
    return MaterialApp(
      title: 'MicroRealEstate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: appTheme.primaryColor),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: appTheme.primaryColor, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: appTheme.mode,
      home: authState.isLoading
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : authState.isAuthenticated
              ? const MainNavigationPage()
              : const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationPage extends ConsumerWidget {
  const MainNavigationPage({super.key});

  List<Widget> get _pages => [
    const LanlordHomePage(),
    const PropertiesPage(),
    const TenantsPage(),
    const MorePage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(selectedNavIndexProvider);
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final orgs = user?.organizationIds ?? [];
    final currentOrgId = user?.currentOrganizationId;
    final allOrgs = orgs.map((id) => DataService.getOrganizationById(id)).whereType<Organization>().toList();
    return Scaffold(
      appBar: (orgs.length > 1)
          ? AppBar(
              title: Text('MicroRealEstate'),
              actions: [
                DropdownButton<String>(
                  value: currentOrgId,
                  items: allOrgs.map((org) => DropdownMenuItem(
                    value: org.id,
                    child: Text(org.name),
                  )).toList(),
                  onChanged: (value) async {
                    if (user != null && value != null && value != user.currentOrganizationId) {
                      final updatedUser = user.copyWith(currentOrganizationId: value);
                      await ref.read(authProvider.notifier).updateProfile(updatedUser);
                    }
                  },
                  underline: const SizedBox(),
                  icon: const Icon(Icons.business),
                ),
              ],
            )
          : null,
      body: IndexedStack(
        index: currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          final isLargeScreen = constraints.maxWidth > 900;

          final navItems = [
            _buildNavItem(
              icon: Icons.home,
              activeIcon: Icons.home,
              label: 'Home',
              index: 0,
              ref: ref,
              context: context,
              isTablet: isTablet,
            ),
            _buildNavItem(
              icon: Icons.apartment_outlined,
              activeIcon: Icons.apartment,
              label: 'Properties',
              index: 1,
              ref: ref,
              context: context,
              isTablet: isTablet,
            ),
            _buildNavItem(
              icon: Icons.people_outline,
              activeIcon: Icons.people,
              label: 'Tenants',
              index: 2,
              ref: ref,
              context: context,
              isTablet: isTablet,
            ),
            _buildNavItem(
              icon: Icons.more_horiz,
              activeIcon: Icons.more,
              label: 'More',
              index: 3,
              ref: ref,
              context: context,
              isTablet: isTablet,
            ),
          ];

          return Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isLargeScreen ? 32 : (isTablet ? 24 : 16),
                  vertical: isTablet ? 12 : 8
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: navItems.map((item) => Expanded(child: item)).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required WidgetRef ref,
    required BuildContext context,
    bool isTablet = false,
  }) {
    final theme = Theme.of(context);
    final currentIndex = ref.watch(selectedNavIndexProvider);
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => ref.read(selectedNavIndexProvider.notifier).state = index,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 16,
          vertical: isTablet ? 12 : 8
        ),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.6),
              size: isTablet ? 28 : 24,
            ),
            SizedBox(height: isTablet ? 6 : 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: (isTablet ? theme.textTheme.labelMedium : theme.textTheme.labelSmall)?.copyWith(
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                fontSize: isTablet ? null : 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
