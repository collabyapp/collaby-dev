import 'package:collaby_app/models/create_gig_model/additional_feature.dart';
import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/colors/app_color.dart';
import 'package:collaby_app/res/components/Button.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/utils/utils.dart';
import 'package:collaby_app/view_models/controller/gig_creation_controller/create_gig_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PricingStep extends GetView<CreateGigController> {
  const PricingStep({super.key});

  String _presetLabel(String name) {
    switch (name) {
      case 'Additional revision':
        return 'preset_additional_revision'.tr;
      case 'Rush delivery':
        return 'preset_rush_delivery'.tr;
      case 'Add logo':
        return 'preset_add_logo'.tr;
      case '4K export':
        return 'preset_4k_export'.tr;
      case 'Custom request':
        return 'preset_custom_request'.tr;
      default:
        return name;
    }
  }

  String _dayLabel(int days) {
    if (days == 1) {
      return '$days ${'day_singular'.tr}';
    }
    return '$days ${'day_plural'.tr}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('pricing_title'.tr, style: AppTextStyles.h6Bold),
            const SizedBox(height: 6),
            Text(
              'pricing_subtitle'.tr,
              style: AppTextStyles.extraSmallText.copyWith(
                color: const Color(0xff77787A),
              ),
            ),
            const SizedBox(height: 12),
            _buildAllTierPrices(),
            const SizedBox(height: 24),

            // Extras
            Text('extras_title'.tr, style: AppTextStyles.h6Bold),
            const SizedBox(height: 10),
            _coreMinimalExtras(),

            const SizedBox(height: 24),

            // Custom extras
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('custom_extras_title'.tr, style: AppTextStyles.h6Bold),
                GestureDetector(
                  onTap: () => _openAddGlobalExtraSheet(existing: null),
                  child: const Icon(Icons.add_circle_outline, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Obx(() {
              final extras = controller.globalExtras;
              if (extras.isEmpty) {
                return Text(
                  'no_custom_extras'.tr,
                  style: AppTextStyles.extraSmallText.copyWith(
                    color: Colors.grey.shade600,
                  ),
                );
              }
              return Column(
                children: extras.map((e) => _globalExtraTile(e)).toList(),
              );
            }),

            const SizedBox(height: 32),

            // Preview
            Obx(() => _buildPackagePreview()),
          ],
        ),
      ),
    );
  }

  // ===================== Prices for all tiers =====================
  Widget _buildAllTierPrices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('currency_label'.tr, style: AppTextStyles.smallText),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _showCurrencySelector,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Obx(
                  () => Text(
                    controller.selectedCurrency.value,
                    style: AppTextStyles.smallText,
                  ),
                ),
                const SizedBox(width: 22),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                  color: Color(0xff3F4146),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _tierLabel('tier_15'.tr)),
            const SizedBox(width: 8),
            Expanded(child: _tierLabel('tier_30'.tr)),
            const SizedBox(width: 8),
            Expanded(child: _tierLabel('tier_60'.tr)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _tierPriceField(0)),
            const SizedBox(width: 8),
            Expanded(child: _tierPriceField(1)),
            const SizedBox(width: 8),
            Expanded(child: _tierPriceField(2)),
          ],
        ),
        const SizedBox(height: 18),
        Text('delivery_time'.tr, style: AppTextStyles.smallText),
        const SizedBox(height: 12),
        _deliveryTimeSelector(),
        const SizedBox(height: 15),
        Text('revisions_label'.tr, style: AppTextStyles.smallText),
        const SizedBox(height: 12),
        _revisionsField(),
      ],
    );
  }

  Widget _tierLabel(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xffD9CCFF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          title,
          style: AppTextStyles.extraSmallText.copyWith(
            color: const Color(0xff5E5E5E),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _tierPriceField(int tierIndex) {
    return TextField(
      controller: controller.priceControllers[tierIndex],
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
      ],
      decoration: InputDecoration(
        hintText: 'price_hint'.tr,
        hintStyle: AppTextStyles.smallText.copyWith(
          color: Colors.grey.shade500,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColor.primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      onChanged: (value) {
        final price = double.tryParse(value) ?? 0;
        controller.updatePackagePrice(tierIndex, price);
      },
    );
  }

  Widget _deliveryTimeSelector() {
    return Obx(() {
      final delivery = controller.packages[0].value.deliveryTime;
      return GestureDetector(
        onTap: () => _showDeliveryTimeSelector(0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                delivery.isEmpty ? 'select_delivery_time'.tr : delivery,
                style: AppTextStyles.smallText.copyWith(
                  color: delivery.isEmpty ? Colors.grey.shade500 : Colors.black,
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_sharp,
                size: 18,
                color: Color(0xff3F4146),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _revisionsField() {
    return TextField(
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      decoration: InputDecoration(
        hintText: 'type_number'.tr,
        hintStyle: AppTextStyles.smallText.copyWith(
          color: Colors.grey.shade500,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColor.primaryColor),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      controller: controller.revisionsController,
      onChanged: (value) {
        final revisions = int.tryParse(value) ?? 0;
        controller.updatePackageRevisions(revisions);
      },
    );
  }

  // ===================== Only Tier Price Form =====================
  Widget _buildTierPriceForm(int tierIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('price_label'.tr, style: AppTextStyles.smallText),
        const SizedBox(height: 12),
        Row(
          children: [
            GestureDetector(
              onTap: _showCurrencySelector,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 23,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Obx(
                      () => Text(
                        controller.selectedCurrency.value,
                        style: AppTextStyles.smallText,
                      ),
                    ),
                    const SizedBox(width: 22),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                      color: Color(0xff3F4146),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller.priceControllers[tierIndex],
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                ],
                decoration: InputDecoration(
                  hintText: 'type_price_hint'.tr,
                  hintStyle: AppTextStyles.smallText.copyWith(
                    color: Colors.grey.shade500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColor.primaryColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                ),
                onChanged: (value) {
                  final price = double.tryParse(value) ?? 0;
                  controller.updatePackagePrice(tierIndex, price);
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // delivery time and revisions -> use tier 0 as "shared source"
        // Keep UI minimal: still allow edit but it applies "shared" in payload (controller uses tier 0)
        Text('delivery_time_shared'.tr, style: AppTextStyles.smallText),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _showDeliveryTimeSelector(0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.packages[0].value.deliveryTime.isEmpty
                      ? 'select_delivery_time'.tr
                      : controller.packages[0].value.deliveryTime,
                  style: AppTextStyles.smallText.copyWith(
                    color: controller.packages[0].value.deliveryTime.isEmpty
                        ? Colors.grey.shade500
                        : Colors.black,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_sharp,
                  size: 18,
                  color: Color(0xff3F4146),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 15),

        Text('revisions_shared'.tr, style: AppTextStyles.smallText),
        const SizedBox(height: 12),
        TextField(
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          decoration: InputDecoration(
            hintText: 'type_number'.tr,
            hintStyle: AppTextStyles.smallText.copyWith(
              color: Colors.grey.shade500,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColor.primaryColor),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          controller: TextEditingController(
            text: controller.packages[0].value.revisions == 0
                ? ''
                : controller.packages[0].value.revisions.toString(),
          ),
          onChanged: (value) {
            final revisions = int.tryParse(value) ?? 0;
            controller.updatePackageRevisions(revisions);
          },
        ),

        const SizedBox(height: 6),
        Text(
          'applies_all_durations'.tr,
          style: AppTextStyles.extraSmallText.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // ===================== Core minimal extras (script/raw/subtitles) =====================
  Widget _coreMinimalExtras() {
    return Column(
      children: [
        _coreRow(
          title: 'extra_commercial'.tr,
          includedObs: controller.coreCommercialIncluded,
          onToggle: controller.setCoreCommercialIncluded,
          priceController: controller.coreCommercialPriceController,
        ),
        const SizedBox(height: 10),
        _coreRow(
          title: 'extra_script'.tr,
          includedObs: controller.coreScriptIncluded,
          onToggle: controller.setCoreScriptIncluded,
          priceController: controller.coreScriptPriceController,
        ),
        const SizedBox(height: 10),
        _coreRow(
          title: 'extra_raw'.tr,
          includedObs: controller.coreRawIncluded,
          onToggle: controller.setCoreRawIncluded,
          priceController: controller.coreRawPriceController,
        ),
        const SizedBox(height: 10),
        _coreRow(
          title: 'extra_subtitles'.tr,
          includedObs: controller.coreSubtitlesIncluded,
          onToggle: controller.setCoreSubtitlesIncluded,
          priceController: controller.coreSubtitlesPriceController,
        ),
      ],
    );
  }

  Widget _coreRow({
    required String title,
    required RxBool includedObs,
    required void Function(bool) onToggle,
    required TextEditingController priceController,
  }) {
    return Obx(() {
      final included = includedObs.value;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xffF4F7FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.smallText.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Switch(value: included, onChanged: onToggle),
              ],
            ),
            if (!included) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}$'),
                        ),
                      ],
                      decoration: InputDecoration(
                        hintText: 'extra_price_hint'.tr,
                        hintStyle: AppTextStyles.smallText.copyWith(
                          color: Colors.grey.shade500,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppColor.primaryColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'extra_price_note'.tr,
                  style: AppTextStyles.extraSmallText.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  // ===================== Global extras list tile =====================
  Widget _globalExtraTile(AdditionalFeature e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xffF4F7FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.name,
                  style: AppTextStyles.smallText.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(
                  () => Text(
                    'custom_extra_summary'.trParams({
                      'currency': controller.selectedCurrency.value,
                      'price': e.price.toStringAsFixed(2),
                      'days': '${e.extraDays}',
                    }),
                    style: AppTextStyles.extraSmallText.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _openAddGlobalExtraSheet(existing: e),
            icon: const Icon(Icons.edit, size: 18),
          ),
          IconButton(
            onPressed: () => controller.removeGlobalExtra(e.id),
            icon: const Icon(Icons.delete_outline, size: 18),
          ),
        ],
      ),
    );
  }

  // ===================== Add/Edit Global Extra Sheet =====================
  void _openAddGlobalExtraSheet({AdditionalFeature? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final priceCtrl = TextEditingController(
      text: existing?.price.toString() ?? '',
    );
    final daysCtrl = TextEditingController(
      text: existing?.extraDays.toString() ?? '',
    );

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(Get.context!).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                existing == null
                    ? 'add_custom_extra'.tr
                    : 'edit_custom_extra'.tr,
                style: AppTextStyles.h6Bold,
              ),
              const SizedBox(height: 14),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'quick_add'.tr,
                  style: AppTextStyles.extraSmallMediumText,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, i) {
                    final t = controller.extraPresets[i];
                    return GestureDetector(
                      onTap: () => nameCtrl.text = t,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _presetLabel(t),
                          style: AppTextStyles.extraSmallText,
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemCount: controller.extraPresets.length,
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'extra_name'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: priceCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                ],
                decoration: InputDecoration(
                  labelText: 'extra_price_label'.trParams({
                    'currency': controller.selectedCurrency.value,
                  }),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: daysCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'extra_days'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
                    final days = int.tryParse(daysCtrl.text.trim()) ?? 0;

                    if (name.isEmpty || price <= 0) {
                      Utils.snackBar(
                        'invalid_input'.tr,
                        'enter_name_valid_price'.tr,
                      );
                      return;
                    }

                    controller.addOrUpdateGlobalExtra(
                      id: existing?.id,
                      name: name,
                      price: price,
                      extraDays: days,
                    );

                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'save'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ===================== Currency Selector =====================
  void _showCurrencySelector() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'select_currency'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: controller.currencies.map((c) {
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tileColor: const Color(0xffF4F7FF),
                      title: Text(c['name']!),
                      trailing: Obx(
                        () => controller.selectedCurrency.value == c['code']
                            ? const Icon(
                                Icons.radio_button_checked,
                                color: Color(0xFF4C1CAE),
                              )
                            : const Icon(
                                Icons.radio_button_unchecked,
                                color: Color(0xFF4C1CAE),
                              ),
                      ),
                      onTap: () =>
                          controller.selectedCurrency.value = c['code']!,
                    );
                  }).toList(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'done'.tr,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ===================== Delivery Time Selector (uses tier 0 as shared) =====================
  void _showDeliveryTimeSelector(int tierIndex) {
    final dayOptions = [1, 2, 3, 5, 7, 14];
    final options = dayOptions.map(_dayLabel).toList();

    Get.bottomSheet(
      DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  child: Text('delivery_time'.tr, style: AppTextStyles.h6),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: options.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final option = options[index];
                      return Obx(() {
                        final pkg = controller.packages[tierIndex].value;
                        final isSelected = pkg.deliveryTime == option;

                        return GestureDetector(
                          onTap: () {
                            controller.updatePackageDeliveryTime(option);
                            Get.back();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xffF4F7FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(option, style: AppTextStyles.normalText),
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_unchecked,
                                  color: const Color(0xFF4C1CAE),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      title: 'done'.tr,
                      onPressed: () => Get.back(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
    );
  }

  // ===================== Preview =====================
  Widget _buildPackagePreview() {
    // Force reactive rebuild when text controllers change in core extras.
    controller.previewRefreshTick.value;
    final currency = controller.selectedCurrency.value;
    final prices = controller.packages.map((p) => p.value.price).toList();
    final delivery = controller.packages[0].value.deliveryTime;
    final revisions = controller.packages[0].value.revisions;
    final hasAnyPrice = prices.any((p) => p > 0);

    final lines = <String>[
      if (controller.coreCommercialIncluded.value)
        'feature_commercial_included'.tr,
      if (!controller.coreCommercialIncluded.value &&
          (controller.coreCommercialPriceController.text.trim().isNotEmpty))
        '${'extra_commercial'.tr} - +${_formatPreviewMoney(controller.coreCommercialExtraPrice, currency)}',
      if (controller.coreRawIncluded.value) 'feature_raw_included'.tr,
      if (!controller.coreRawIncluded.value &&
          (controller.coreRawPriceController.text.trim().isNotEmpty))
        '${'extra_raw'.tr} - +${_formatPreviewMoney(controller.coreRawExtraPrice, currency)}',
      if (controller.coreSubtitlesIncluded.value)
        'feature_subtitles_included'.tr,
      if (!controller.coreSubtitlesIncluded.value &&
          (controller.coreSubtitlesPriceController.text.trim().isNotEmpty))
        '${'extra_subtitles'.tr} - +${_formatPreviewMoney(controller.coreSubtitlesExtraPrice, currency)}',
      if (controller.coreScriptIncluded.value) 'feature_script_included'.tr,
      if (!controller.coreScriptIncluded.value &&
          (controller.coreScriptPriceController.text.trim().isNotEmpty))
        '${'extra_script'.tr} - +${_formatPreviewMoney(controller.coreScriptExtraPrice, currency)}',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hasAnyPrice || controller.globalExtras.isNotEmpty
              ? 'preview'.tr
              : 'preview_hint'.tr,
          style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F7FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF6B46C1).withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _previewPriceRow('tier_15'.tr, prices[0], currency),
              const SizedBox(height: 8),
              _previewPriceRow('tier_30'.tr, prices[1], currency),
              const SizedBox(height: 8),
              _previewPriceRow('tier_60'.tr, prices[2], currency),
              const SizedBox(height: 16),

              ...lines.map((f) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.check, color: Colors.black, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(f, style: const TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                );
              }).toList(),

              if (controller.globalExtras.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  'custom_extras_label'.tr,
                  style: AppTextStyles.extraSmallMediumText,
                ),
                const SizedBox(height: 8),
                ...controller.globalExtras.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '- ${e.name} (+${_formatPreviewMoney(e.price, currency)})',
                      style: AppTextStyles.extraSmallText,
                    ),
                  );
                }).toList(),
              ],

              const SizedBox(height: 16),
              Row(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Color(0xFFFBBB00),
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        delivery.isEmpty ? 'delivery_time'.tr : delivery,
                        style: AppTextStyles.extraSmallMediumText,
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      Image.asset(ImageAssets.revisionIcon, width: 12),
                      const SizedBox(width: 8),
                      Text(
                        'revisions_count'.trParams({
                          'count': '${revisions == 0 ? '-' : revisions}',
                        }),
                        style: AppTextStyles.extraSmallMediumText,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _previewPriceRow(String label, double price, String currency) {
    return Row(
      children: [
        Image.asset(ImageAssets.dollarIcon, height: 12),
        const SizedBox(width: 8),
        Text(
          '$label: ${price > 0 ? _formatPreviewMoney(price, currency) : '-'}',
          style: AppTextStyles.normalTextMedium,
        ),
      ],
    );
  }

  String _formatPreviewMoney(double amount, String currency) {
    final noDecimals = amount.toStringAsFixed(
      amount == amount.truncateToDouble() ? 0 : 2,
    );
    switch (currency.toUpperCase()) {
      case 'EUR':
        return '$noDecimals\u20AC';
      case 'USD':
        return '\$$noDecimals';
      case 'GBP':
        return '\u00A3$noDecimals';
      default:
        return '$noDecimals $currency';
    }
  }
}
