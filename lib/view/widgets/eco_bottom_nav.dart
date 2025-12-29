import 'package:flutter/material.dart';

class EcoNavItem {
  const EcoNavItem({
    required this.index,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final int index;
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class EcoBottomNavBar extends StatelessWidget {
  const EcoBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.centerGapAt,
    this.height = 60,
    this.activeColor = const Color(0xFF2D9F5D),
    this.inactiveColor = Colors.grey,
    this.notched = false,
  });

  final int currentIndex;
  final List<EcoNavItem> items;
  final ValueChanged<int> onTap;
  final int? centerGapAt;
  final double height;
  final Color activeColor;
  final Color inactiveColor;
  final bool notched;

  @override
  Widget build(BuildContext context) {
    final ordered = [...items]..sort((a, b) => a.index.compareTo(b.index));
    final children = <Widget>[];
    bool gapInserted = false;

    for (final item in ordered) {
      if (centerGapAt != null && !gapInserted && item.index > centerGapAt!) {
        children.add(const SizedBox(width: 48));
        gapInserted = true;
      }
      children.add(
        _NavItem(
          isActive: currentIndex == item.index,
          icon: item.icon,
          activeIcon: item.activeIcon,
          label: item.label,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          onTap: () => onTap(item.index),
        ),
      );
    }

    if (centerGapAt != null && !gapInserted) {
      children.add(const SizedBox(width: 48));
    }

    return BottomAppBar(
      shape: notched ? const CircularNotchedRectangle() : null,
      notchMargin: notched ? 8 : 0,
      child: SizedBox(
        height: height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: children,
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.isActive,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  final bool isActive;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? activeIcon : icon,
            color: isActive ? activeColor : inactiveColor,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? activeColor : inactiveColor,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
