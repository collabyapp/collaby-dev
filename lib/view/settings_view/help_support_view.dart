import 'package:collaby_app/view_models/controller/settings_controller/support_ticket_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HelpSupportView extends StatelessWidget {
  HelpSupportView({super.key});

  final SupportTicketController controller = Get.put(SupportTicketController());

  final List<String> _categories = const [
    'general',
    'account_billing',
    'order_issue',
    'technical',
    'content_policy',
  ];

  String _statusLabel(String status) {
    switch (status) {
      case 'in_progress':
        return 'support_ticket_status_in_progress'.tr;
      case 'resolved':
        return 'support_ticket_status_resolved'.tr;
      case 'closed':
        return 'support_ticket_status_closed'.tr;
      default:
        return 'support_ticket_status_open'.tr;
    }
  }

  String _categoryLabel(String category) {
    switch (category) {
      case 'account_billing':
        return 'support_ticket_cat_account_billing'.tr;
      case 'order_issue':
        return 'support_ticket_cat_order_issue'.tr;
      case 'technical':
        return 'support_ticket_cat_technical'.tr;
      case 'content_policy':
        return 'support_ticket_cat_content_policy'.tr;
      default:
        return 'support_ticket_cat_general'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('support_ticket_title'.tr), centerTitle: true),
      body: Obx(() {
        return RefreshIndicator(
          onRefresh: controller.loadTickets,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'support_ticket_subtitle'.tr,
                style: const TextStyle(color: Color(0xff6B7280)),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (controller.relatedOrderNumber.value.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xffF4F1FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xffD9D1FF)),
                        ),
                        child: Text(
                          'support_ticket_linked_order'.trParams({
                            'order': controller.relatedOrderNumber.value,
                          }),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    Text('support_ticket_category'.tr),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: controller.selectedCategory.value,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: _categories
                          .map(
                            (c) => DropdownMenuItem<String>(
                              value: c,
                              child: Text(_categoryLabel(c)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) controller.selectedCategory.value = v;
                      },
                    ),
                    const SizedBox(height: 12),
                    Text('support_ticket_subject'.tr),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller.subjectController,
                      decoration: InputDecoration(
                        hintText: 'support_ticket_subject_hint'.tr,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('support_ticket_description'.tr),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller.descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'support_ticket_description_hint'.tr,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.isCreateLoading.value
                            ? null
                            : controller.createTicket,
                        child: Text(
                          controller.isCreateLoading.value
                              ? 'support_ticket_creating'.tr
                              : 'support_ticket_create'.tr,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'support_ticket_my_tickets'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              if (controller.isListLoading.value)
                const Center(child: CircularProgressIndicator())
              else if (controller.isSupportUnavailable.value)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xffE5E7EB)),
                  ),
                  child: Text('support_ticket_unavailable'.tr),
                )
              else if (controller.tickets.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xffE5E7EB)),
                  ),
                  child: Text('support_ticket_empty'.tr),
                )
              else
                ...controller.tickets.map((ticket) {
                  final id = (ticket['_id'] ?? '').toString();
                  final subject = (ticket['subject'] ?? '').toString();
                  final status = (ticket['status'] ?? 'open').toString();
                  final category = (ticket['category'] ?? 'general').toString();
                  final createdAt = (ticket['createdAt'] ?? '').toString();
                  final selectedId =
                      (controller.selectedTicket.value?['_id'] ?? '')
                          .toString();
                  final isSelected = selectedId.isNotEmpty && selectedId == id;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xffF4F1FF)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xff7B61FF)
                            : const Color(0xffE5E7EB),
                      ),
                    ),
                    child: ListTile(
                      onTap: () => controller.openTicket(id),
                      title: Text(
                        subject,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${_categoryLabel(category)} - $createdAt',
                      ),
                      trailing: Text(
                        _statusLabel(status),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 8),
              if (controller.selectedTicket.value != null) ...[
                const Divider(height: 24),
                Text(
                  (controller.selectedTicket.value?['subject'] ?? '')
                      .toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  (controller.selectedTicket.value?['description'] ?? '')
                      .toString(),
                ),
                const SizedBox(height: 10),
                if (controller.isDetailLoading.value)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  ...((controller.selectedTicket.value?['replies'] as List?) ??
                          const [])
                      .map((reply) {
                        final role = (reply['senderRole'] ?? '').toString();
                        final msg = (reply['message'] ?? '').toString();
                        final date = (reply['createdAt'] ?? '').toString();
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xffF9FAFB),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xffE5E7EB)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                role,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(msg),
                              const SizedBox(height: 4),
                              Text(
                                date,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xff6B7280),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller.replyController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'support_ticket_reply_hint'.tr,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: controller.isReplyLoading.value
                          ? null
                          : controller.sendReply,
                      child: Text(
                        controller.isReplyLoading.value
                            ? 'support_ticket_sending_reply'.tr
                            : 'support_ticket_send_reply'.tr,
                      ),
                    ),
                  ),
                ],
              ] else
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'support_ticket_select_ticket'.tr,
                    style: const TextStyle(color: Color(0xff6B7280)),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
