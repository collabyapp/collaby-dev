import 'package:collaby_app/repository/support_ticket_repository/support_ticket_repository.dart';
import 'package:collaby_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SupportTicketController extends GetxController {
  final SupportTicketRepository _repository = SupportTicketRepository();

  final TextEditingController subjectController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController replyController = TextEditingController();

  final RxBool isListLoading = false.obs;
  final RxBool isCreateLoading = false.obs;
  final RxBool isDetailLoading = false.obs;
  final RxBool isReplyLoading = false.obs;
  final RxBool isSupportUnavailable = false.obs;

  final RxList<dynamic> tickets = <dynamic>[].obs;
  final Rxn<Map<String, dynamic>> selectedTicket = Rxn<Map<String, dynamic>>();
  final RxString selectedCategory = 'general'.obs;
  final RxString relatedOrderId = ''.obs;
  final RxString relatedOrderNumber = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _hydrateFromArgs();
    loadTickets();
  }

  @override
  void onClose() {
    subjectController.dispose();
    descriptionController.dispose();
    replyController.dispose();
    super.onClose();
  }

  void _hydrateFromArgs() {
    final args = Get.arguments;
    if (args is! Map) return;

    final category = (args['category'] ?? '').toString().trim();
    if (category.isNotEmpty) {
      selectedCategory.value = category;
    }

    final subject = (args['subject'] ?? '').toString().trim();
    if (subject.isNotEmpty) {
      subjectController.text = subject;
    }

    final description = (args['description'] ?? '').toString().trim();
    if (description.isNotEmpty) {
      descriptionController.text = description;
    }

    relatedOrderId.value = (args['relatedOrderId'] ?? '').toString().trim();
    relatedOrderNumber.value = (args['relatedOrderNumber'] ?? '')
        .toString()
        .trim();
  }

  bool _isEndpointUnavailableMessage(String message) {
    final m = message.toLowerCase();
    final mentionsSupportRoute =
        m.contains('/support-tickets') ||
        m.contains('/support-ticket') ||
        m.contains('support-tickets') ||
        m.contains('support-ticket') ||
        m.contains('support ticket');
    final genericSupportContext =
        m.contains('support') && (m.contains('ticket') || m.contains('tickets'));
    final missingRoute = mentionsSupportRoute || genericSupportContext;
    final gatewayUnavailable =
        m.contains('bad gateway') ||
        m.contains('gateway') ||
        m.contains('upstream') ||
        m.contains('status 502') ||
        m.contains('statuscode":502') ||
        m.contains('statuscode: 502');
    return m.contains('error code: 502') ||
        m.contains('error code: 404') ||
        m.contains('statuscode: 404') ||
        ((m.contains('cannot get') || m.contains('not found')) &&
            missingRoute) ||
        (missingRoute && gatewayUnavailable);
  }

  String _normalizeMessage(dynamic message, String fallbackKey) {
    final msg = message is List
        ? message.map((e) => e.toString()).join(', ').trim()
        : (message ?? '').toString().trim();
    if (msg.isEmpty) return fallbackKey.tr;
    final lowered = msg.toLowerCase();
    if (lowered.contains('cannot get /support-tickets') ||
        lowered.contains('cannot get /api/support-tickets') ||
        lowered.contains('/support-tickets/me')) {
      return 'support_ticket_unavailable'.tr;
    }
    if (_isEndpointUnavailableMessage(msg)) {
      return 'support_ticket_unavailable'.tr;
    }
    return msg;
  }

  Future<void> loadTickets({bool silent = false}) async {
    if (!silent) isListLoading.value = true;
    try {
      final response = await _repository.getMyTickets();
      final statusCode = response?['statusCode'];
      if (statusCode == 200) {
        isSupportUnavailable.value = false;
        final items = response?['data']?['items'];
        tickets.value = items is List ? items : <dynamic>[];
      } else {
        final normalized = _normalizeMessage(
          response?['message'] ?? response?['error'] ?? response,
          'support_ticket_load_error',
        );
        isSupportUnavailable.value =
            normalized == 'support_ticket_unavailable'.tr;
        if (isSupportUnavailable.value) {
          tickets.clear();
          selectedTicket.value = null;
          return;
        }
        Utils.snackBar('error'.tr, normalized);
      }
    } catch (e) {
      final normalized = _normalizeMessage(
        e.toString(),
        'support_ticket_load_error',
      );
      isSupportUnavailable.value =
          normalized == 'support_ticket_unavailable'.tr;
      if (isSupportUnavailable.value) {
        tickets.clear();
        selectedTicket.value = null;
        return;
      }
      Utils.snackBar('error'.tr, normalized);
    } finally {
      if (!silent) isListLoading.value = false;
    }
  }

  Future<void> openTicket(String ticketId) async {
    isDetailLoading.value = true;
    try {
      final response = await _repository.getMyTicket(ticketId);
      final statusCode = response?['statusCode'];
      if (statusCode == 200) {
        isSupportUnavailable.value = false;
        final ticket = response?['data'];
        if (ticket is Map) {
          selectedTicket.value = Map<String, dynamic>.from(ticket);
        } else {
          selectedTicket.value = null;
        }
      } else {
        final normalized = _normalizeMessage(
          response?['message'] ?? response?['error'] ?? response,
          'support_ticket_load_error',
        );
        isSupportUnavailable.value =
            normalized == 'support_ticket_unavailable'.tr;
        if (isSupportUnavailable.value) {
          selectedTicket.value = null;
          return;
        }
        Utils.snackBar('error'.tr, normalized);
      }
    } catch (e) {
      final normalized = _normalizeMessage(
        e.toString(),
        'support_ticket_load_error',
      );
      isSupportUnavailable.value =
          normalized == 'support_ticket_unavailable'.tr;
      if (isSupportUnavailable.value) {
        selectedTicket.value = null;
        return;
      }
      Utils.snackBar('error'.tr, normalized);
    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<void> createTicket() async {
    final subject = subjectController.text.trim();
    final description = descriptionController.text.trim();

    if (subject.length < 3 || description.length < 10) {
      Utils.snackBar('error'.tr, 'support_ticket_create_error'.tr);
      return;
    }

    isCreateLoading.value = true;
    try {
      final response = await _repository.createTicket(
        subject: subject,
        description: description,
        category: selectedCategory.value,
        relatedOrderId: relatedOrderId.value,
        relatedOrderNumber: relatedOrderNumber.value,
      );
      final statusCode = response?['statusCode'];
      if (statusCode == 200 || statusCode == 201) {
        isSupportUnavailable.value = false;
        Utils.snackBar('success'.tr, 'support_ticket_created'.tr);
        subjectController.clear();
        descriptionController.clear();
        selectedCategory.value = 'general';
        await loadTickets(silent: true);
      } else {
        Utils.snackBar(
          'error'.tr,
          _normalizeMessage(
            response?['message'] ?? response?['error'] ?? response,
            'support_ticket_create_error',
          ),
        );
      }
    } catch (e) {
      Utils.snackBar(
        'error'.tr,
        _normalizeMessage(e.toString(), 'support_ticket_create_error'),
      );
    } finally {
      isCreateLoading.value = false;
    }
  }

  Future<void> sendReply() async {
    final message = replyController.text.trim();
    final id = selectedTicket.value?['_id']?.toString() ?? '';

    if (id.isEmpty || message.isEmpty) return;

    isReplyLoading.value = true;
    try {
      final response = await _repository.replyMyTicket(
        ticketId: id,
        message: message,
      );
      final statusCode = response?['statusCode'];
      if (statusCode == 200 || statusCode == 201) {
        isSupportUnavailable.value = false;
        Utils.snackBar('success'.tr, 'support_ticket_reply_sent'.tr);
        replyController.clear();
        await openTicket(id);
        await loadTickets(silent: true);
      } else {
        Utils.snackBar(
          'error'.tr,
          _normalizeMessage(
            response?['message'] ?? response?['error'] ?? response,
            'support_ticket_reply_error',
          ),
        );
      }
    } catch (e) {
      Utils.snackBar(
        'error'.tr,
        _normalizeMessage(e.toString(), 'support_ticket_reply_error'),
      );
    } finally {
      isReplyLoading.value = false;
    }
  }
}
