import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/components/Button.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/view/settings_view/widget/setting_menu_item.dart';
import 'package:collaby_app/view_models/controller/settings_controller/app_language_controller.dart';
import 'package:collaby_app/view_models/controller/settings_controller/delete_account_controller.dart';
import 'package:collaby_app/view_models/controller/settings_controller/log_out_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SettingsView extends StatelessWidget {
  final DeleteAccountController deleteAccountController = Get.put(
    DeleteAccountController(),
  );

  final LogoutController logoutController = Get.put(LogoutController());
  final AppLanguageController appLanguageController = Get.put(AppLanguageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text('settings_title'.tr),
        centerTitle: true,
      ),
      body: Obx(
        () => Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  SettingsMenuItem(
                    icon: ImageAssets.securityIcon,
                    iconColor: Color(0xFF6366F1),
                    iconBgColor: Color(0xFF6366F1).withOpacity(0.1),
                    title: 'settings_account_security'.tr,
                    onTap: () {
                      Get.toNamed(
                        RouteName.accountSecurityView,
                        arguments: {'isEdit': true},
                      );
                    },
                  ),
                  SizedBox(height: 12),
                  SettingsMenuItem(
                    icon: ImageAssets.walletIcon,
                    iconColor: Color(0xFF6366F1),
                    iconBgColor: Color(0xFF6366F1).withOpacity(0.1),
                    title: 'settings_billing_withdrawal'.tr,
                    onTap: () {
                      Get.toNamed(RouteName.withdrawalView);
                    },
                  ),
                  SizedBox(height: 12),
                  SettingsMenuItem(
                    icon: ImageAssets.shippingIcon,
                    iconColor: Color(0xFF6366F1),
                    iconBgColor: Color(0xFF6366F1).withOpacity(0.1),
                    title: 'settings_shipping_address'.tr,
                    onTap: () {
                      Get.toNamed(
                        RouteName.shippingAddressView,
                        arguments: {'isEdit': true},
                      );
                    },
                  ),
                  SizedBox(height: 12),
                  SettingsMenuItem(
                    icon: ImageAssets.securityIcon,
                    iconColor: Color(0xFF6366F1),
                    iconBgColor: Color(0xFF6366F1).withOpacity(0.1),
                    title: 'settings_app_language'.tr,
                    trailing: Text(
                      _languageLabel(Get.locale ?? const Locale('en', 'US')),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: _showLanguageDialog,
                  ),
                  SizedBox(height: 12),

                  SettingsMenuItem(
                    icon: ImageAssets.deleteIcon,
                    iconColor: Color(0xFF6366F1),
                    iconBgColor: Color(0xFF6366F1).withOpacity(0.1),
                    title: 'settings_delete_account'.tr,
                    isIcon: false,
                    onTap: () {
                      _showDeleteConfirmationDialog(context);
                    },
                  ),

                  Spacer(),

                  CustomButton(
                    title: 'settings_logout'.tr,
                    onPressed: () {
                      logoutController.showLogoutConfirmation();
                    },
                  ),
                ],
              ),
            ),
            // Loading overlay for both logout and delete account
            if (deleteAccountController.isLoading || logoutController.isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 16),
                      Text(
                        logoutController.isLoading
                            ? 'settings_logging_out'.tr
                            : 'settings_deleting_account'.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text(
              'settings_delete_account'.tr,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'settings_delete_confirm_body'.tr,
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'cancel'.tr,
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close confirmation dialog
              deleteAccountController.deleteAccount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'delete'.tr,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  void _showLanguageDialog() {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'settings_select_language'.tr,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...appLanguageController.supportedLocales.map((locale) {
                final current = Get.locale ?? const Locale('en', 'US');
                final selected = current.languageCode == locale.languageCode;
                return ListTile(
                  title: Text(_languageLabel(locale)),
                  trailing: selected
                      ? const Icon(Icons.check, color: Color(0xFF6F4BFF))
                      : null,
                  onTap: () async {
                    await appLanguageController.changeLanguage(locale);
                    Get.back();
                  },
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  String _languageLabel(Locale locale) {
    switch (locale.languageCode) {
      case 'es':
        return 'language_spanish'.tr;
      case 'de':
        return 'language_german'.tr;
      case 'fr':
        return 'language_french'.tr;
      case 'pt':
        return 'language_portuguese'.tr;
      case 'it':
        return 'language_italian'.tr;
      case 'nl':
        return 'language_dutch'.tr;
      default:
        return 'language_english'.tr;
    }
  }
}
