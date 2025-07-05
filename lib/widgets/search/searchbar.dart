import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class ModernSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onFilterPressed;
  final VoidCallback? onClearFiltersPressed;
  final bool hasActiveFilters;
  final bool autofocus;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final bool showFilterButton;
  
  const ModernSearchBar({
    super.key,
    this.controller,
    this.hintText = "Ara...",
    this.onChanged,
    this.onSubmitted,
    this.onFilterPressed,
    this.onClearFiltersPressed,
    this.hasActiveFilters = false,
    this.autofocus = false,
    this.padding,
    this.borderRadius = 30.0,
    this.backgroundColor,
    this.showFilterButton = true,
  });

  @override
  State<ModernSearchBar> createState() => _ModernSearchBarState();
}

class _ModernSearchBarState extends State<ModernSearchBar> with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  
  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    
    // Setup animation for focus effect
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _animation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    // Track focus changes
    _focusNode.addListener(_onFocusChange);
    
    if (widget.autofocus) {
      // Give time for the widget to be built before requesting focus
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }
  }
  
  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    
    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }
  
  @override
  void dispose() {
    // Only dispose controller if it was created internally
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isFocused ? _animation.value : 1.0,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? theme.cardColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: _isFocused 
                    ? AppColors.primary.withOpacity(0.2) 
                    : AppColors.darkGrey.withOpacity(0.15),
                spreadRadius: _isFocused ? 1 : 2,
                blurRadius: _isFocused ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: (value) {
                  if (widget.onChanged != null) {
                    widget.onChanged!(value);
                  }
                  // Force rebuild to show/hide clear button
                  setState(() {});
                },
                onSubmitted: widget.onSubmitted,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: AppTextStyles.bodyL.copyWith(
                    color: AppColors.darkGrey,
                  ),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                  prefixIcon: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.only(left: 16.0, right: 10.0),
                    child: Icon(
                      Icons.search_rounded,
                      color: _isFocused ? AppColors.primary : AppColors.darkGrey,
                      size: 24,
                    ),
                  ),
                  suffixIcon: _buildSuffixIcon(),
                ),
                style: AppTextStyles.bodyL,
                textInputAction: TextInputAction.search,
                onTap: () {
                  // Add haptic feedback for better UX
                  HapticFeedback.selectionClick();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSuffixIcon() {
    // If text is not empty, show clear button
    if (_controller.text.isNotEmpty) {
      return IconButton(
        icon: const Icon(Icons.clear, color: AppColors.darkGrey),
        onPressed: () {
          HapticFeedback.lightImpact();
          _controller.clear();
          if (widget.onChanged != null) {
            widget.onChanged!('');
          }
          setState(() {});
        },
      );
    }
    
    // If no filter button should be shown, return empty container
    if (!widget.showFilterButton) {
      return const SizedBox.shrink();
    }
    
    // Show filter button(s)
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(
            Icons.filter_list_rounded,
            color: AppColors.darkGrey,
          ),
          tooltip: 'Filtrele',
          onPressed: () {
            HapticFeedback.mediumImpact();
            if (widget.onFilterPressed != null) {
              widget.onFilterPressed!();
            }
          },
        ),
        if (widget.hasActiveFilters && widget.onClearFiltersPressed != null)
          IconButton(
            icon: const Icon(
              Icons.filter_list_off_rounded,
              color: AppColors.error,
            ),
            tooltip: 'Filtreleri Temizle',
            onPressed: () {
              HapticFeedback.mediumImpact();
              if (widget.onClearFiltersPressed != null) {
                widget.onClearFiltersPressed!();
              }
            },
          ),
      ],
    );
  }
}

// Extension to add a search bar to any scaffold
extension ScaffoldWithSearchBar on Scaffold {
  Scaffold withSearchBar({
    required BuildContext context,
    required TextEditingController controller,
    String hintText = "Ara...",
    Function(String)? onChanged,
    Function(String)? onSubmitted,
    VoidCallback? onFilterPressed,
    VoidCallback? onClearFiltersPressed,
    bool hasActiveFilters = false,
    bool autofocus = false,
    EdgeInsetsGeometry? padding,
    double borderRadius = 30.0,
    Color? backgroundColor,
    bool showFilterButton = true,
  }) {
    return Scaffold(
      appBar: this.appBar,
      body: Column(
        children: [
          // Search bar at the top
          ModernSearchBar(
            controller: controller,
            hintText: hintText,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            onFilterPressed: onFilterPressed,
            onClearFiltersPressed: onClearFiltersPressed,
            hasActiveFilters: hasActiveFilters,
            autofocus: autofocus,
            padding: padding,
            borderRadius: borderRadius,
            backgroundColor: backgroundColor,
            showFilterButton: showFilterButton,
          ),
          // Original body in a Flexible widget
          Flexible(
            child: this.body ?? const SizedBox.shrink(),
          ),
        ],
      ),
      bottomNavigationBar: this.bottomNavigationBar,
      floatingActionButton: this.floatingActionButton,
      floatingActionButtonLocation: this.floatingActionButtonLocation,
      drawer: this.drawer,
      endDrawer: this.endDrawer,
      backgroundColor: this.backgroundColor,
      resizeToAvoidBottomInset: this.resizeToAvoidBottomInset,
    );
  }
}
