import 'package:flutter/material.dart';
import '../pages/notification_page.dart';
import '../theme/app_colors.dart';
import '../utils/logout.dart';

class SidebarItem {
  final IconData icon;
  final String label;
  const SidebarItem({required this.icon, required this.label});
}

class CyberScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget child;
  final Widget? bottomNavigationBar;

  final List<SidebarItem>? sidebarItems;
  final int selectedIndex;
  final Function(int)? onItemSelected;
  final List<String>? breadcrumbs;
  final String userName;
  final String userRole;

  const CyberScaffold({
    super.key,
    this.appBar,
    required this.child,
    this.bottomNavigationBar,
    this.sidebarItems,
    this.selectedIndex = 0,
    this.onItemSelected,
    this.breadcrumbs,
    this.userName = 'User',
    this.userRole = 'mahasiswa',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _ModernTopBar(
            userName: userName,
            userRole: userRole,
            breadcrumbs: breadcrumbs,
            onNotificationTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationPage(
                    userRole: userRole,
                    userName: userName,
                  ),
                ),
              );
            },
            onProfileTap: () => _showProfileMenu(context),
          ),
          Expanded(
            child: sidebarItems != null
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SidebarNav(
                        items: sidebarItems!,
                        selectedIndex: selectedIndex,
                        onItemSelected: onItemSelected,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 20, 40, 20),
                          child: child,
                        ),
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    child: child,
                  ),
          ),
        ],
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            _AvatarWithGlow(userName: userName),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userName,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  Text(userRole.toUpperCase(),
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text('Keluar',
                  style: TextStyle(color: AppColors.error,
                      fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(ctx);
                logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Modern Top Bar ────────────────────────────────────────────────────────────
class _ModernTopBar extends StatelessWidget {
  final String userName;
  final String userRole;
  final List<String>? breadcrumbs;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  const _ModernTopBar({
    required this.userName,
    required this.userRole,
    this.breadcrumbs,
    this.onNotificationTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gradStart, AppColors.gradEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x336C8AF7),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(40, 16, 40, 0),
      child: Column(
        children: [
          Row(
            children: [
              // University Logo and Name
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFF93A827),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.school, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SIM Akademik',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 11),
                    ),
                    const Text(
                      'Universitas Nusa Cendana',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Breadcrumbs
                    if (breadcrumbs != null && breadcrumbs!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          children: [
                            for (int i = 0; i < breadcrumbs!.length; i++) ...[
                              if (i > 0)
                                const Icon(Icons.chevron_right,
                                    color: Colors.white54, size: 14),
                              Text(
                                breadcrumbs![i],
                                style: TextStyle(
                                  color: i == breadcrumbs!.length - 1
                                      ? Colors.white
                                      : Colors.white60,
                                  fontSize: 11,
                                  fontWeight: i == breadcrumbs!.length - 1
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              // Notification Icon
              _TopBarIconButton(
                icon: Icons.notifications_none_rounded,
                onTap: onNotificationTap,
              ),
              const SizedBox(width: 8),
              _TopBarIconButton(
                icon: Icons.grid_view_rounded,
                onTap: null,
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: onProfileTap,
                child: _AvatarWithGlow(userName: userName),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

// ─── Top Bar Icon Button ───────────────────────────────────────────────────────
class _TopBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _TopBarIconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

// ─── Avatar With Glow ──────────────────────────────────────────────────────────
class _AvatarWithGlow extends StatelessWidget {
  final String userName;
  const _AvatarWithGlow({required this.userName});

  @override
  Widget build(BuildContext context) {
    String initials = 'U';
    if (userName.isNotEmpty) {
      final parts = userName.trim().split(' ');
      if (parts.length >= 2) {
        initials = (parts[0][0] + parts[1][0]).toUpperCase();
      } else {
        initials = parts[0][0].toUpperCase();
      }
    }

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Colors.white24, Colors.white38],
        ),
        border: Border.all(color: Colors.white54, width: 2),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }
}

// ─── Sidebar Navigation ────────────────────────────────────────────────────────
class _SidebarNav extends StatelessWidget {
  final List<SidebarItem> items;
  final int selectedIndex;
  final Function(int)? onItemSelected;

  const _SidebarNav({
    required this.items,
    required this.selectedIndex,
    this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: items.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  final isActive = i == selectedIndex;
                  return _SidebarNavItem(
                    icon: item.icon,
                    label: item.label,
                    isActive: isActive,
                    onTap: () => onItemSelected?.call(i),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 4),
          _SidebarNavItem(
            icon: Icons.logout_rounded,
            label: 'Keluar',
            isActive: false,
            isDestructive: true,
            onTap: () => logout(context),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Sidebar Nav Item ──────────────────────────────────────────────────────────
class _SidebarNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDestructive;
  final VoidCallback onTap;

  const _SidebarNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? AppColors.error
        : isActive
            ? AppColors.primary
            : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight:
                      isActive ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            if (isActive)
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
