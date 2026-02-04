import 'package:get/get.dart';
class AccountCreatedController extends GetxController {
  AccountCreatedController({required dynamic usernameArg})
    : username = _toPlainString(usernameArg);

  final String username; // plain String for UI
  final RxInt currentStep =
      0.obs; // 0=Complete profile, 1=Create Gig, 2=Publish

  static String _toPlainString(dynamic v) {
    if (v is String) return v;
    if (v is RxString) return v.value;
    return v?.toString() ?? '';
  }

  void goTo(int step) => currentStep.value = step;
}
