import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../state/crm_state.dart';
import 'dashboard_screen.dart';
import 'leads_screen.dart';
import 'tasks_screen.dart';
import 'campaigns_screen.dart';
import 'reports_screen.dart';
import 'templates_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const DashboardScreen(),
      const LeadsScreen(),
      const TasksScreen(),
      const MoreScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EB),
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: screens,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.black.withOpacity(0.08),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                _buildNavItem(index: 0, icon: LucideIcons.layoutDashboard, label: 'DASHBOARD'),
                _buildNavItem(index: 1, icon: LucideIcons.users, label: 'LEADS'),
                _buildNavItem(index: 2, icon: LucideIcons.checkSquare, label: 'TASKS'),
                _buildNavItem(index: 3, icon: LucideIcons.moreHorizontal, label: 'MORE'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isActive = index == _selectedIndex;
    final color = isActive ? const Color(0xFF1A1A1A) : const Color(0xFF94A3B8);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: color,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: color,
              ),
            ),
            if (isActive) ...[
              const SizedBox(height: 2),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  shape: BoxShape.circle,
                ),
              ),
            ] else
              const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(crmProvider);
    final user = state.currentUser;
    final isAdmin = user?.role == 'ADMIN' || user?.role == 'SUPERADMIN';

    final menuItems = [
      {'label': 'Profile & Settings', 'sub': '${user?.name ?? "Jane Cooper"} · ${user?.role ?? "Counselor"}', 'route': null, 'show': true},
      {'label': 'Institution', 'sub': user?.tenantId.isNotEmpty == true ? 'Tenant: ${user!.tenantId}' : 'Prestige Education Group', 'route': null, 'show': true},
      {'label': 'Campaigns', 'sub': 'Marketing channels and tracking', 'route': const CampaignsScreen(), 'show': isAdmin},
      {'label': 'Templates', 'sub': 'WhatsApp, Email, SMS templates', 'route': const TemplatesScreen(), 'show': true},
      {'label': 'Reports', 'sub': 'Analytics & Insights dashboard', 'route': const ReportsScreen(), 'show': isAdmin},
      {'label': 'Help & Support', 'sub': 'Contact system admin', 'route': null, 'show': true},
    ];

    final visibleItems = menuItems.where((item) => item['show'] == true).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EB),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            children: [
              // User header card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withOpacity(0.06)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        (user?.name.isNotEmpty == true) ? user!.name[0].toUpperCase() : 'J',
                        style: const TextStyle(
                          color: Color(0xFFF5F1EB),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Jane Cooper',
                            style: const TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            user?.role ?? 'Admission Counselor',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            user?.email ?? 'jane.cooper@centra.edu',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Menu Options list
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withOpacity(0.06)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: visibleItems.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: Colors.black.withOpacity(0.05),
                    ),
                    itemBuilder: (context, index) {
                      final item = visibleItems[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        title: Text(
                          item['label'] as String,
                          style: const TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          item['sub'] as String,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Color(0xFFCBD5E1),
                          size: 20,
                        ),
                        onTap: () {
                          if (item['route'] != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => item['route'] as Widget,
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(crmProvider.notifier).logout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF1F2),
                    foregroundColor: const Color(0xFFE11D48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFFECDD3)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(LucideIcons.logOut, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'LOG OUT',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
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
