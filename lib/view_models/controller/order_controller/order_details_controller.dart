import 'dart:async';
import 'package:collaby_app/repository/order_repository/order_repository.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/utils/utils.dart';
import 'package:collaby_app/view_models/controller/chat_controller/websocket_controller.dart';
import 'package:get/get.dart';
import 'package:collaby_app/models/orders_model/orders_models.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class OrderDetailController extends GetxController {
  var selectedTab = 0.obs;
  var currentOrder = Rxn<OrderModel>();
  var chatMessages = <ChatMessage>[].obs;
  var isSubmitting = false.obs;
  var workDescription = ''.obs;
  var selectedFiles = <String>[].obs;
  var isOrderProcessed = false.obs;
  var messageController = TextEditingController();
  var workDescriptionController = TextEditingController();
  var orderChatMessages = <dynamic>[].obs;
  var isChatLoading = false.obs;
  var chatErrorMessage = ''.obs;
  var orderChatId = ''.obs;
  var currentUserId = ''.obs;
  var orderMessageController = TextEditingController();

  // Repository & Loading
  final OrdersRepository _ordersRepository = OrdersRepository();
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Activity Timeline management
  var activityEvents = <ActivityEvent>[].obs;
  var isActivityLoading = false.obs;

  // Timeline management (legacy)
  var timelineEvents = <TimelineEvent>[].obs;

  // File upload management with 4 video limit
  var uploadedFiles = <UploadedFile>[].obs;
  var isUploading = false.obs;
  final int maxFiles = 4;

  // Revision management
  var revisionFeature = ''.obs;
  var revisionPrice = ''.obs;
  var revisionDeliveryDays = ''.obs;
  var showRevisionForm = false.obs;

  // For decline functionality
  var selectedDeclineReason = ''.obs;
  var customDeclineReason = ''.obs;

  // For conditional sections display
  var showAttachments = false.obs;
  var showScript = false.obs;
  var showOrderQuestions = false.obs;
  var showOtherAttachments = false.obs;

  // Creator Actions - Button enable/disable
  var canDeliverNow = false.obs;
  var showCreatorActions = false.obs;

  final List<String> declineReasons = [
    'Out of Scope',
    'Availability Conflict',
    'Tight Deadline',
    'Client Requested Cancellation',
    'Other',
  ];

  OrderModel? passedOrder;
  @override
  void onInit() {
    super.onInit();
    _initializeOrder();
  }

  /// Helper getters you can use anywhere (UI or controller)
  String? get orderTitle => passedOrder?.title ?? currentOrder.value?.title;
  String? get orderThumb =>
      passedOrder?.gigThumbnail ?? currentOrder.value?.gigThumbnail;
  String? get orderNumber =>
      passedOrder?.orderNumber ?? currentOrder.value?.orderNumber;
  // Pick a date field that exists in your model:
  DateTime? get orderDate => passedOrder?.createdAt; // adjust to your model

  String? get orderId => passedOrder?.id ?? currentOrder.value?.id;

  /// Fetch and initialize order from API
  Future<void> _initializeOrder() async {
    // inside OrderDetailView
    final args = Get.arguments;
    final orderId = args['id'];
    final orderStatus = args['status'];
    passedOrder = args['order'] as OrderModel?;

    if (orderId == null || orderId.isEmpty) {
      errorMessage.value = 'Invalid order ID';
      Utils.snackBar('Error', 'Order ID not provided');
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (orderStatus == 'inProgress') {
        _initializeChatMessages();
        _initializeContentDisplay();

        // Fetch activity timeline
        await fetchActivityTimeline(orderId);
        // Fetch deliveries for inProgress orders
        await fetchDeliveries(orderId);
      } else {
        final responseData = await _ordersRepository.getOrderRequestDetails(
          orderId,
        );

        if (responseData != null) {
          final order = OrderModel.fromDetailJson(responseData);
          currentOrder.value = order;
        }
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Utils.snackBar('Error', 'Failed to load order: ${e.toString()}');
      debugPrint('Error in _initializeOrder: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchOrderRequestDetail(String orderId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Clear the previous order data before loading new order
      currentOrder.value = null;
      orderChatId.value = ''; // Clear previous chat ID

      // Fetch order details
      final responseData = await _ordersRepository.getOrderRequestDetails(
        orderId,
      );

      if (responseData != null) {
        final order = OrderModel.fromDetailJson(responseData);
        currentOrder.value = order;
        _initializeChatMessages();
        _initializeContentDisplay();

        // Fetch activity timeline
        await fetchActivityTimeline(orderId);
      } else {
        errorMessage.value = 'Failed to load order details';
        Utils.snackBar('Error', 'Could not fetch order details');
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Utils.snackBar('Error', 'Failed to load order: ${e.toString()}');
      debugPrint('Error in _initializeOrder: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch Activity Timeline from API
  Future<void> fetchActivityTimeline(String orderId) async {
    try {
      isActivityLoading.value = true;

      final response = await _ordersRepository.getOrderActivity(orderId);
      // print('response');
      // print(response['data']['orderInfo']);
      if (response != null && response['data'] != null) {
        final data = response['data'];

        // Parse activities
        if (data['activities'] != null) {
          activityEvents.value = (data['activities'] as List)
              .map((a) => ActivityEvent.fromJson(a))
              .toList();

          // Sort by date (newest first)
          activityEvents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        }

        // Parse orderInfo
        if (data['orderInfo'] != null) {
          final orderInfo = OrderInfo.fromJson(data['orderInfo']);
          orderChatId.value = orderInfo.chatId.toString();
          // Update current order with orderInfo
          if (currentOrder.value != null) {
            currentOrder.value = currentOrder.value!.copyWith(
              orderInfo: orderInfo,
              status: OrderModel.parseStatus(orderInfo.status),
            );
          }
        }

        // Parse creatorsActions
        if (data['creatorsActions'] != null) {
          final creatorActions = CreatorActions.fromJson(
            data['creatorsActions'],
          );

          // Update creator actions for button state
          canDeliverNow.value = creatorActions.deliverNow;
          showCreatorActions.value = creatorActions.showActions;

          // Update current order with creatorActions
          if (currentOrder.value != null) {
            currentOrder.value = currentOrder.value!.copyWith(
              creatorActions: creatorActions,
            );
          }
        }

        debugPrint('Activity timeline loaded: ${activityEvents.length} events');
        debugPrint('Can deliver now: ${canDeliverNow.value}');
        debugPrint('Show actions: ${showCreatorActions.value}');
      }
    } catch (e) {
      debugPrint('Error fetching activity timeline: $e');
      Utils.snackBar('Warning', 'Could not load activity timeline');
    } finally {
      isActivityLoading.value = false;
    }
  }

  // Deliveries Management
  var deliveries = <Delivery>[].obs;
  var revisionRequest = Rxn<RevisionRequest>();
  var deliveryOrderInfo = Rxn<DeliveryOrderInfo>();
  var isDeliveriesLoading = false.obs;

  /// Fetch Deliveries from API
  Future<void> fetchDeliveries(String orderId) async {
    try {
      isDeliveriesLoading.value = true;

      final response = await _ordersRepository.getOrderDeliveries(orderId);

      if (response != null && response['data'] != null) {
        final deliveryResponse = DeliveryResponse.fromJson(response);

        // Update deliveries list (sorted by date, newest first)
        deliveries.value = deliveryResponse.deliveries;
        deliveries.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        // Update revision request
        revisionRequest.value = deliveryResponse.revisionRequest;

        // Update delivery order info
        deliveryOrderInfo.value = deliveryResponse.orderInfo;

        debugPrint('Deliveries loaded: ${deliveries.length}');
        debugPrint(
          'Revision request: ${revisionRequest.value?.revisionReason}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching deliveries: $e');
      Utils.snackBar('Warning', 'Could not load deliveries');
    } finally {
      isDeliveriesLoading.value = false;
    }
  }

  /// Initialize chat messages with brand info
  void _initializeChatMessages() {
    final order = currentOrder.value;
    final brandName =
        order?.brandDetails?.profile.brandCompanyName ??
        order?.brandName ??
        'Brand';

    chatMessages.clear();
    chatMessages.addAll([
      ChatMessage(
        message: "Hello! I'm excited to work on this project with you.",
        isSender: false,
        timestamp: DateTime.now().subtract(Duration(hours: 2)),
        senderName: brandName,
        messageType: MessageType.text,
      ),
      ChatMessage(
        message: "Hi there! Looking forward to seeing your creative work.",
        isSender: true,
        timestamp: DateTime.now().subtract(Duration(hours: 1)),
        senderName: "You",
        messageType: MessageType.text,
      ),
      ChatMessage(
        message: order?.title ?? 'Project',
        isSender: false,
        timestamp: DateTime.now().subtract(Duration(minutes: 30)),
        senderName: brandName,
        messageType: MessageType.project,
        projectDescription: order?.workDescription,
        projectStatus: order?.status.toString().split('.').last ?? "Active",
        projectImage: order?.gigThumbnail,
        postedTime: "2 Days ago",
      ),
    ]);
  }

  /// Initialize content display based on order data
  void _initializeContentDisplay() {
    final order = currentOrder.value;

    showAttachments.value =
        order?.orderRequirements?.workDescriptionAttachments?.isNotEmpty ??
        false;
    showScript.value =
        order?.orderRequirements?.providedScript?.isNotEmpty ?? false;
    showOrderQuestions.value =
        order?.orderSpecificQuestionAnswers?.isNotEmpty ?? false;
    showOtherAttachments.value = false;
  }

  void changeTab(int index) {
    selectedTab.value = index;

    // Fetch appropriate data based on tab
    switch (index) {
      case 0: // New Jobs
        fetchActivityTimeline(orderId.toString());
        break;
      // case 1: // Saved Jobs
      //   fetchSavedJobs(refresh: true);
      //   break;
      case 2: // Applied Jobs
        fetchDeliveries(orderId.toString());
        break;
    }
  }

  void acceptOrder(OrderModel order) async {
    try {
      isSubmitting.value = true;

      final response = await _ordersRepository.acceptOrder(order.id);

      if (response != null) {
        order.status = OrderStatus.inProgress;
        currentOrder.value = order;

        isOrderProcessed.value = true;
        Utils.snackBar('Success', 'Order accepted successfully!');

        // Refresh activity timeline
        await fetchActivityTimeline(order.id);

        Future.delayed(Duration(seconds: 1), () {
          Get.offAllNamed(
            RouteName.bottomNavigationView,
            arguments: {'index': 1},
          );
        });
      } else {
        Utils.snackBar('Error', 'Failed to accept order');
      }
    } catch (e) {
      Utils.snackBar('Error', 'Failed to accept order: ${e.toString()}');
      debugPrint('Error in acceptOrder: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  void declineOrder(OrderModel order) async {
    try {
      isSubmitting.value = true;

      String reason = selectedDeclineReason.value == 'Other'
          ? customDeclineReason.value
          : selectedDeclineReason.value;

      if (reason.isEmpty) {
        Utils.snackBar('Error', 'Please select or enter a reason');
        isSubmitting.value = false;
        return;
      }

      final response = await _ordersRepository.declineOrder(order.id, reason);

      if (response != null) {
        order.status = OrderStatus.declined;
        order = order.copyWith(declinedReason: reason);
        currentOrder.value = order;

        isOrderProcessed.value = true;
        Get.offAllNamed(
          RouteName.bottomNavigationView,
          arguments: {'index': 1},
        );
        Utils.snackBar('Order Declined', 'Order has been declined');

        // Refresh activity timeline
        await fetchActivityTimeline(order.id);

        Future.delayed(Duration(seconds: 2), () {
          Get.back();
        });
      } else {
        Utils.snackBar('Error', 'Failed to decline order');
      }
    } catch (e) {
      Utils.snackBar('Error', 'Failed to decline order: ${e.toString()}');
      debugPrint('Error in declineOrder: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  bool canSubmit() {
    return workDescriptionController.text.trim().isNotEmpty &&
        uploadedFiles.isNotEmpty &&
        canDeliverNow.value; // Check if delivery is allowed
  }

  void simulateFileUpload(FileType type) {
    if (uploadedFiles.length >= maxFiles) {
      Utils.snackBar('Limit Reached', 'You can upload maximum $maxFiles files');
      return;
    }

    isUploading.value = true;

    var newFile = UploadedFile(
      name: _generateFileName(type),
      path: _generateFilePath(type),
      size: _generateFileSize(),
      progress: 0.0,
      type: type,
    );

    uploadedFiles.add(newFile);
    int fileIndex = uploadedFiles.length - 1;

    var uploadTimer = Stream.periodic(Duration(milliseconds: 100), (i) => i)
        .take(20)
        .listen((tick) {
          if (fileIndex < uploadedFiles.length) {
            var file = uploadedFiles[fileIndex];
            uploadedFiles[fileIndex] = UploadedFile(
              name: file.name,
              path: file.path,
              size: file.size,
              progress: (tick + 1) / 20,
              type: file.type,
            );
          }
        });

    uploadTimer.onDone(() {
      isUploading.value = false;
    });
  }

  String _generateFileName(FileType type) {
    switch (type) {
      case FileType.video:
        return "beauty_video_${uploadedFiles.length + 1}.mp4";
      case FileType.image:
        return "beauty_image_${uploadedFiles.length + 1}.jpg";
      default:
        return "document_${uploadedFiles.length + 1}.pdf";
    }
  }

  String _generateFilePath(FileType type) {
    switch (type) {
      case FileType.video:
        return "assets/sample_video.mp4";
      case FileType.image:
        return "assets/sample_image.jpg";
      default:
        return "assets/sample_document.pdf";
    }
  }

  String _generateFileSize() {
    Random random = Random();
    double size = 5 + random.nextDouble() * 20;
    return "${size.toStringAsFixed(1)} MB";
  }

  void removeUploadedFile(int index) {
    if (index < uploadedFiles.length) {
      uploadedFiles.removeAt(index);
    }
  }

  void toggleRevisionForm() {
    showRevisionForm.value = !showRevisionForm.value;
  }

  void resetDeclineForm() {
    selectedDeclineReason.value = '';
    customDeclineReason.value = '';
  }

  @override
  void dispose() {
    resetDeclineForm();
    messageController.dispose();
    workDescriptionController.dispose();
    if (Get.isRegistered<SocketService>() && orderChatId.value.isNotEmpty) {
      final socketService = Get.find<SocketService>();
      socketService.leaveChat(orderChatId.value);
    }

    // Dispose controllers
    orderMessageController.dispose();
    messageController.dispose();
    workDescriptionController.dispose();

    super.dispose();
  }
}
