import 'package:collaby_app/models/orders_model/orders_models.dart';
import 'package:collaby_app/repository/order_repository/order_repository.dart';
import 'package:collaby_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrdersController extends GetxController {
  final OrdersRepository _ordersRepository = OrdersRepository();

  // Observable variables
  var selectedTab = 0.obs;
  var earningAvailable = 0.0.obs;
  var orders = <OrderModel>[].obs;
  var isLoading = false.obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var hasMoreData = true.obs;

  // Status counts from API
  var activeCount = 0.obs;
  var newCount = 0.obs;
  var completedCount = 0.obs;

  String? _statusForTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return 'InProgress'; // ACTIVE tab now uses InProgress
      case 1:
        return 'Requested'; // NEW tab
      case 2:
        return 'Completed,Declined'; // COMPLETED tab (includes declined)
      default:
        return null;
    }
  }

  // Computed properties
  List<OrderModel> get activeOrders => orders
      .where(
        (order) =>
            order.status == OrderStatus.inProgress ||
            order.status == OrderStatus.active ||
            order.status == OrderStatus.inRevision ||
            order.status == OrderStatus.delivered,
      )
      .toList();

  List<OrderModel> get newOrders =>
      orders.where((order) => order.status == OrderStatus.newOrder).toList();

  List<OrderModel> get completedOrders => orders
      .where(
        (order) =>
            order.status == OrderStatus.completed ||
            order.status == OrderStatus.declined,
      )
      .toList();

  @override
  void onInit() {
    super.onInit();
    fetchOrdersFromApi();
  }

  Future<void> fetchOrdersFromApi({
    bool refresh = false,
    String? status,
  }) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        orders.clear();
        hasMoreData.value = true;
      }

      isLoading.value = true;

      // If status not provided, derive it from the selected tab
      final String? filterStatus = status ?? _statusForTab(selectedTab.value);

      final response = await _ordersRepository.getCreatorOrders(
        page: currentPage.value,
        limit: 10,
        status: filterStatus,
      );

      if (response != null && response['statusCode'] == 200) {
        final List<dynamic> ordersData = response['data'] ?? [];
        final fetchedOrders = ordersData
            .map((orderJson) => OrderModel.fromJson(orderJson))
            .toList();

        if (refresh) {
          orders.value = fetchedOrders;
        } else {
          orders.addAll(fetchedOrders);
        }

        totalPages.value = response['totalPages'] ?? 1;
        hasMoreData.value = currentPage.value < totalPages.value;

        _updateStatusCounts(response['statusCounts']);
        earningAvailable.value =
            (response['walletBalance']?['availableBalance'] as num?)
                ?.toDouble() ??
            double.tryParse(
              response['walletBalance']?['availableBalance']?.toString() ?? '',
            ) ??
            0.0;
      } else {
        Utils.snackBar(
          'Error',
          response?['message'] ?? 'Failed to fetch orders',
        );
      }
    } catch (e) {
      print('Error fetching orders: $e');
      Utils.snackBar('Error', 'Failed to fetch orders: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// Update status counts from API response
  void _updateStatusCounts(List<dynamic>? statusCounts) {
    if (statusCounts == null) return;

    int activeTotal = 0;
    int newTotal = 0;
    int completedTotal = 0;

    for (var statusCount in statusCounts) {
      String status = statusCount['status'] ?? '';
      int count = statusCount['count'] ?? 0;

      // Active tab now counts InProgress status
      if (status == 'InProgress') {
        activeTotal += count;
      }
      // New tab includes: Requested
      else if (status == 'Requested') {
        newTotal += count;
      }
      // Completed tab includes: Completed, Declined
      else if (status == 'Completed' || status == 'Declined') {
        completedTotal += count;
      }
    }

    activeCount.value = activeTotal;
    newCount.value = newTotal;
    completedCount.value = completedTotal;
  }

  /// Load more orders (pagination)
  Future<void> loadMoreOrders() async {
    if (!hasMoreData.value || isLoading.value) return;

    currentPage.value++;
    await fetchOrdersFromApi();
  }

  /// Refresh orders
  Future<void> refreshOrders() async {
    await fetchOrdersFromApi(refresh: true);
  }

  /// Get order details
  Future<OrderModel?> getOrderDetails(String orderId) async {
    try {
      isLoading.value = true;

      final response = await _ordersRepository.getOrderDetails(orderId);

      if (response != null && response['statusCode'] == 200) {
        return OrderModel.fromJson(response['data']);
      } else {
        Utils.snackBar(
          'Error',
          response?['message'] ?? 'Failed to fetch order details',
        );
        return null;
      }
    } catch (e) {
      print('Error fetching order details: $e');
      Utils.snackBar('Error', 'Failed to fetch order details: ${e.toString()}');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update order status locally
  void updateOrderStatus(String orderId, OrderStatus status) {
    int index = orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      orders[index] = orders[index].copyWith(status: status);
      orders.refresh();
    }
  }

  /// Change tab
  void changeTab(int index) {
    if (selectedTab.value == index) return; // no-op if same tab
    selectedTab.value = index;

    // Reset pagination & list, then fetch with the new tab's status
    currentPage.value = 1;
    hasMoreData.value = true;
    orders.clear();

    fetchOrdersFromApi(
      refresh: true,
    ); // status will be derived from selectedTab
  }

  /// Boost profile
  void boostProfile() {
    Utils.snackBar(
      'Boost Profile',
      'Profile boost feature will be implemented',
    );
  }

  /// Get status text
  String getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.active:
        return 'Active';
      case OrderStatus.newOrder:
        return 'New';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.declined:
        return 'Declined';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.inRevision:
        return 'In Revision';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.draft:
        return 'Draft';
    }
  }

  /// Get status color
  Color getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.active:
        return Color(0xff8C6A08);
      case OrderStatus.newOrder:
        return Colors.green;
      case OrderStatus.completed:
        return Color(0xff4C1CAE);
      case OrderStatus.declined:
        return Colors.grey;
      case OrderStatus.inProgress:
        return Color(0xff8C6A08);
      case OrderStatus.inRevision:
        return Colors.orange;
      case OrderStatus.delivered:
        return Colors.blue;
      case OrderStatus.draft:
        return Colors.orange;
    }
  }
}
