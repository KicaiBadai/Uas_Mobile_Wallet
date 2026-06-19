import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'feature_icon.dart';

class AppTabBar extends StatelessWidget {
  final String active;
  final ValueChanged<String> onTab;
  final VoidCallback? onScan;

  const AppTabBar({
    super.key,
    required this.active,
    required this.onTab,
    this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        4,
        16,
        10 + MediaQuery.of(context).padding.bottom,
      ),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: AppColors.primary.withOpacity(0.04),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            _TabItem(icon: DkgIcons.home, label: 'Home', tabKey: 'home', active: active, onTap: onTab),
            _TabItem(icon: DkgIcons.history, label: 'Riwayat', tabKey: 'history', active: active, onTap: onTab),
            // Center scan button
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: onScan,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: AppColors.shadowPrimary,
                    ),
                    child: const Icon(DkgIcons.scan, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),
            _TabItem(icon: DkgIcons.gift, label: 'Promo', tabKey: 'promo', active: active, onTap: onTab),
            _TabItem(icon: DkgIcons.user, label: 'Akun', tabKey: 'akun', active: active, onTap: onTab),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tabKey;
  final String active;
  final ValueChanged<String> onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.tabKey,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = active == tabKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(tabKey),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isActive ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutBack,
              child: Icon(
                icon,
                size: isActive ? 24 : 22,
                color: isActive ? AppColors.primary : AppColors.slate400,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 10.5,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? AppColors.primary : AppColors.slate400,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: isActive ? 4 : 0,
              height: isActive ? 4 : 0,
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
