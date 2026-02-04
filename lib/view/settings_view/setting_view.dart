import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/components/Button.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/view/settings_view/widget/setting_menu_item.dart';
import 'package:collaby_app/view_models/controller/settings_controller/delete_account_controller.dart';
import 'package:collaby_app/view_models/controller/settings_controller/log_out_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SettingsView extends StatelessWidget {
  final DeleteAccountController deleteAccountController = Get.put(
    DeleteAccountController(),
  );

  final LogoutController logoutController = Get.put(LogoutController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text('Settings'),
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
                    title: 'Account Security',
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
                    title: 'Billing & Withdrawal',
                    onTap: () {
                      Get.toNamed(RouteName.withdrawalView);
                    },
                  ),
                  SizedBox(height: 12),
                  SettingsMenuItem(
                    icon: ImageAssets.shippingIcon,
                    iconColor: Color(0xFF6366F1),
                    iconBgColor: Color(0xFF6366F1).withOpacity(0.1),
                    title: 'Shipping Address',
                    onTap: () {
                      Get.toNamed(
                        RouteName.shippingAddressView,
                        arguments: {'isEdit': true},
                      );
                    },
                  ),
                  SizedBox(height: 12),

                  SettingsMenuItem(
                    icon: ImageAssets.deleteIcon,
                    iconColor: Color(0xFF6366F1),
                    iconBgColor: Color(0xFF6366F1).withOpacity(0.1),
                    title: 'Delete Account',
                    isIcon: false,
                    onTap: () {
                      _showDeleteConfirmationDialog(context);
                    },
                  ),

                  Spacer(),

                  CustomButton(
                    title: 'Logout',
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
                            ? 'Logging out...'
                            : 'Deleting account...',
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
              'Delete Account',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
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
              'Delete',
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
}

