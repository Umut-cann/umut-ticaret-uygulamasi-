
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/order.dart';
import '../../widgets/order/order_card.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Order> _allOrders = [];
  bool _isLoading = true;
  int _selectedTab = 0;
  final _animationDuration = const Duration(milliseconds: 300);
  
  // Controller for tab indicator animation
  late AnimationController _indicatorController;
  late Animation<double> _indicatorAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    
    // Initialize animation controller for smooth animations
    _indicatorController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );
    
    _indicatorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _indicatorController,
      curve: Curves.easeOutCubic,
    ));
    
    // Simulate loading with a slight delay for smoother UX
    Future.delayed(const Duration(milliseconds: 800), () {
      _loadOrders();
    });
  }
  
  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedTab = _tabController.index;
      });
      _indicatorController.forward(from: 0.0);
    }
  }

  void _loadOrders() {
    // Simulate network request
    setState(() {
      _isLoading = true;
    });
    
    // Add a small delay to simulate loading
    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        _allOrders = Order.createDummyOrders(20);
        _isLoading = false;
      });
      // Start animation after loading
      _indicatorController.forward();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _indicatorController.dispose();
    super.dispose();
  }

  // Belirli duruma göre siparişleri filtrele
  List<Order> _getOrdersByStatus(List<OrderStatus> statuses) {
    // Çift return ifadesi kaldırıldı
    return _allOrders
        .where((order) => statuses.contains(order.status))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // Filter orders by status
    final activeOrders = _getOrdersByStatus([
      OrderStatus.pending,
      OrderStatus.processing,
      OrderStatus.shipped,
    ]);
    final deliveredOrders = _getOrdersByStatus([
      OrderStatus.delivered,
    ]);
    final cancelledReturnedOrders = _getOrdersByStatus([
      OrderStatus.cancelled,
      OrderStatus.returned,
    ]);
    
    // Safe bottom padding to avoid overlap with navigation bar
    final bottomPadding = MediaQuery.of(context).padding.bottom + 80;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,

        automaticallyImplyLeading: Navigator.canPop(context),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        // Use a flexible space instead of bottom for better styling
      ),
      body: Stack(
        children: [
          // Background design elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ),
          
          // Main content
          Column(
            children: [
              const SizedBox(height: kToolbarHeight + 16),
              
              // Custom Tab Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildCustomTabBar(),
              ),
              
              // Main content area
              Expanded(
                child: _isLoading
                  ? _buildLoadingIndicator()
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        // Active Orders Tab
                        _buildOrderList(
                          activeOrders, 
                          'Aktif siparişiniz bulunmuyor.',
                          bottomPadding
                        ),
                        // Delivered Orders Tab
                        _buildOrderList(
                          deliveredOrders,
                          'Teslim edilmiş siparişiniz bulunmuyor.',
                          bottomPadding
                        ),
                        // Cancelled/Returned Orders Tab
                        _buildOrderList(
                          cancelledReturnedOrders,
                          'İptal veya iade edilmiş siparişiniz bulunmuyor.',
                          bottomPadding
                        ),
                      ],
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Animated indicator
            AnimatedBuilder(
              animation: _indicatorAnimation,
              builder: (context, _) {
                return Positioned(
                  left: (_selectedTab * (MediaQuery.of(context).size.width - 32) / 3),
                  bottom: 0,
                  child: Container(
                    height: 54,
                    width: (MediaQuery.of(context).size.width - 32) / 3,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1 * _indicatorAnimation.value),
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                );
              },
            ),
            
            // Tab buttons
            Row(
              children: [
                _buildTabButton("Aktif", 0, Icons.pending_actions_outlined),
                _buildTabButton("Tamamlanan", 1, Icons.check_circle_outline),
                _buildTabButton("İptal/İade", 2, Icons.cancel_outlined),
              ],
            ),
            
            // Bottom indicator line
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _indicatorAnimation,
                builder: (context, _) {
                  return Container(
                    height: 3,
                    child: Stack(
                      children: [
                        Positioned(
                          left: (_selectedTab * (MediaQuery.of(context).size.width - 32) / 3) + 
                                 ((MediaQuery.of(context).size.width - 32) / 6) - 20,
                          width: 40,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTabButton(String title, int index, IconData icon) {
    bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _tabController.animateTo(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
        },
        child: Container(
          height: 54,
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.darkGrey.withOpacity(0.7),
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: AppTextStyles.bodyS.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.darkGrey.withOpacity(0.7),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Siparişleriniz yükleniyor...",
            style: AppTextStyles.bodyM.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Widget to display order list
  Widget _buildOrderList(List<Order> orders, String emptyMessage, double bottomPadding) {
    if (orders.isEmpty) {
      return AnimatedOpacity(
        opacity: _isLoading ? 0.0 : 1.0,
        duration: _animationDuration,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.receipt_long_outlined,
                    size: 60,
                    color: AppColors.primary.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Henüz Sipariş Yok",
                        style: AppTextStyles.h6,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        emptyMessage,
                        style: AppTextStyles.bodyM.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to home or products page
                          HapticFeedback.mediumImpact();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text('Alışverişe Başla'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AnimatedOpacity(
      opacity: _isLoading ? 0.0 : 1.0,
      duration: _animationDuration,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, bottomPadding),
        itemCount: orders.length,
        itemBuilder: (ctx, index) {
          // Add a staggered animation effect
          final delay = (index / orders.length) * 500;
          return FutureBuilder(
            future: Future.delayed(Duration(milliseconds: delay.toInt())),
            builder: (context, snapshot) {
              return AnimatedOpacity(
                opacity: snapshot.connectionState == ConnectionState.done ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                child: AnimatedSlide(
                  offset: snapshot.connectionState == ConnectionState.done 
                    ? const Offset(0, 0) 
                    : const Offset(0, 0.1),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: OrderCard(order: orders[index]),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
