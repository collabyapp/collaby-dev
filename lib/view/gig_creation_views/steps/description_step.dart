import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view_models/controller/gig_creation_controller/create_gig_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';

class DescriptionStep extends GetView<CreateGigController> {
  const DescriptionStep({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Service Description', style: AppTextStyles.h6Bold),
          const SizedBox(height: 6),
          Text(
            'Tell us about the services you offer and introduce yourself briefly.',
            style: AppTextStyles.extraSmallText.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final count = controller.descriptionWordCount.value;
            final min = controller.descriptionMinWords;
            final ok = count >= min;
            return Text(
              'Word count: $count / $min',
              style: AppTextStyles.extraSmallText.copyWith(
                color: ok ? const Color(0xff2E7D32) : Colors.grey.shade600,
              ),
            );
          }),
          const SizedBox(height: 10),

          Container(
            height: 420,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: QuillEditor.basic(
                      controller: controller.quillController,
                      focusNode: controller.descriptionFocusNode,
                      config: QuillEditorConfig(
                        padding: EdgeInsets.zero,
                        onTapOutsideEnabled: true,
                        onTapOutside: (event, node) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        showCursor: true,
                        customStyles: DefaultStyles(),
                        placeholder: 'Write what you offer, what the client gets, and any important notes...',
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: QuillSimpleToolbar(
                    controller: controller.quillController,
                    config: const QuillSimpleToolbarConfig(
                      showListBullets: true,
                      showBoldButton: true,
                      showItalicButton: true,
                      showUnderLineButton: true,
                      showFontFamily: false,
                      showFontSize: false,
                      showSubscript: false,
                      showSuperscript: false,
                      showStrikeThrough: false,
                      showInlineCode: false,
                      showColorButton: false,
                      showBackgroundColorButton: false,
                      showClearFormat: false,
                      showAlignmentButtons: false,
                      showHeaderStyle: false,
                      showListNumbers: false,
                      showListCheck: false,
                      showCodeBlock: false,
                      showQuote: false,
                      showIndent: false,
                      showLink: false,
                      showUndo: false,
                      showRedo: false,
                      showSearchButton: false,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
