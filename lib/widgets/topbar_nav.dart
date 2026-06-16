import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class DropdownOption {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const DropdownOption({required this.icon, required this.title, required this.subtitle, required this.onTap});
}

class NavItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const NavItem({super.key, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: isActive ? AppColors.primary : Colors.transparent, width: 3)),
        ),
        child: Text(label, style: TextStyle(color: isActive ? AppColors.primary : AppColors.textSecondary, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, fontSize: 14)),
      ),
    );
  }
}

class NavDropdownItem extends StatelessWidget {
  final String label;
  final bool isOpen;
  final bool isActive;
  final VoidCallback onTap;
  const NavDropdownItem({super.key, required this.label, required this.isOpen, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isOpen ? const Color(0xFF1A3A6B) : Colors.transparent,
        ),
        child: Row(
          children: [
            Text(label, style: TextStyle(color: isOpen ? Colors.white : (isActive ? AppColors.primary : AppColors.textSecondary), fontWeight: (isActive || isOpen) ? FontWeight.w700 : FontWeight.w500, fontSize: 14)),
            const SizedBox(width: 6),
            Icon(isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16, color: isOpen ? Colors.white : (isActive ? AppColors.primary : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class DropdownPanel extends StatelessWidget {
  final String title;
  final List<DropdownOption> items;
  const DropdownPanel({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A3A6B),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Text(title.toUpperCase(), style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
          ),
          ...items.map((item) => InkWell(
            onTap: item.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Icon(item.icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                    Text(item.subtitle, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  ]),
                ],
              ),
            ),
          )),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
