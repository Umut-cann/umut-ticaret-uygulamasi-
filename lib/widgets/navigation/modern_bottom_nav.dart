import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:badges/badges.dart' as badges;

import '../../constants/app_colors.dart';

class ModernBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<ModernBottomNavItem> items;
  
  const ModernBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate safe bottom padding
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selected tab indicator
          SizedBox(
            height: 3,
            child: Stack(
              children: [
                Positioned(
                  left: (currentIndex * (MediaQuery.of(context).size.width / items.length)) +
                      ((MediaQuery.of(context).size.width / items.length) / 2) - 15,
                  child: Container(
                    width: 30,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Nav bar items
          Container(
            height: 65,
            padding: EdgeInsets.only(bottom: bottomPadding > 0 ? bottomPadding - 5 : 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                items.length,
                (index) {
                  final item = items[index];
                  final isSelected = currentIndex == index;
                  return _buildNavItem(
                    isSelected: isSelected,
                    item: item,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onTap(index);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required bool isSelected,
    required ModernBottomNavItem item,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Badge wrapper if the item has a badge
            item.badgeCount != null && item.badgeCount! > 0
                ? badges.Badge(
                    badgeContent: Text(
                      item.badgeCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    badgeStyle: const badges.BadgeStyle(
                      badgeColor: AppColors.accent,
                      padding: EdgeInsets.all(4),
                    ),
                    child: _buildIcon(isSelected, item),
                  )
                : _buildIcon(isSelected, item),
            
            // Optional label
            if (item.label != null) ...[              
              const SizedBox(height: 4),
              Text(
                item.label!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected 
                      ? AppColors.primary 
                      : AppColors.darkGrey.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(bool isSelected, ModernBottomNavItem item) {
    // Non-animated version for better performance
    return Container(
      height: 26,
      width: 26,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Center(
        child: Icon(
          isSelected ? item.filledIcon : item.outlinedIcon,
          color: isSelected ? AppColors.primary : AppColors.darkGrey.withOpacity(0.7),
          size: 24,
        ),
      ),
    );
  }
}

class ModernBottomNavItem {
  final IconData outlinedIcon;
  final IconData filledIcon;
  final String? label;
  final int? badgeCount;

  const ModernBottomNavItem({
    required this.outlinedIcon,
    required this.filledIcon,
    this.label,
    this.badgeCount,
  });
}
