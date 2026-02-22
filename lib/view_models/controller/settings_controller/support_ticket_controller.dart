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

  final RxList<dynamic> tickets = <dynamic>[].obs;
  final Rxn<Map<String, dynamic>> selectedTicket = Rxn<Map<String, dynamic>>();
  final RxString selectedCategory = 'general'.obs;

  @override
  void onInit() {
    super.onInit();
    loadTickets();
  }

  @override
  void onClose() {
    subjectController.dispose();
    descriptionController.dispose();
    replyController.dispose();
    super.onClose();
  }

  Future<void> loadTickets({bool silent = false}) async {
    if (!silent) isListLoading.value = true;
    try {
      final response = await _repository.getMyTickets();
      final statusCode = response?['statusCode'];
      if (statusCode == 200) {
        final items = response?['data']?['items'];
        tickets.value = items is List ? items : <dynamic>[];
      } else {
        Utils.snackBar(
          'error'.tr,
          (response?['message'] ?? 'support_ticket_load_error'.tr).toString(),
        );
      }
    } catch (e) {
      Utils.snackBar('error'.tr, 'support_ticket_load_error'.tr);
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
        final ticket = response?['data'];
        if (ticket is Map) {
          selectedTicket.value = Map<String, dynamic>.from(ticket);
        } else {
          selectedTicket.value = null;
        }
      } else {
        Utils.snackBar(
          'error'.tr,
          (response?['message'] ?? 'support_ticket_load_error'.tr).toString(),
        );
      }
    } catch (e) {
      Utils.snackBar('error'.tr, 'support_ticket_load_error'.tr);
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
      );
      final statusCode = response?['statusCode'];
      if (statusCode == 200 || statusCode == 201) {
        Utils.snackBar('success'.tr, 'support_ticket_created'.tr);
        subjectController.clear();
        descriptionController.clear();
        selectedCategory.value = 'general';
        await loadTickets(silent: true);
      } else {
        Utils.snackBar(
          'error'.tr,
          (response?['message'] ?? 'support_ticket_create_error'.tr).toString(),
        );
      }
    } catch (e) {
      Utils.snackBar('error'.tr, 'support_ticket_create_error'.tr);
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
        Utils.snackBar('success'.tr, 'support_ticket_reply_sent'.tr);
        replyController.clear();
        await openTicket(id);
        await loadTickets(silent: true);
      } else {
        Utils.snackBar(
          'error'.tr,
          (response?['message'] ?? 'support_ticket_reply_error'.tr).toString(),
        );
      }
    } catch (e) {
      Utils.snackBar('error'.tr, 'support_ticket_reply_error'.tr);
    } finally {
      isReplyLoading.value = false;
    }
  }
}
