import 'package:collaby_app/view_models/controller/user_preference/user_preference_view_model.dart';
import 'package:get/get.dart';

class NavController extends GetxController {
  var selectedIndex = 0.obs;
  final _userPref = UserPreference();

  @override
  void onInit() {
    super.onInit();
    // Check if there are any arguments passed when navigating
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map) {
      final index = arguments['index'];
      if (index != null && index is int && index >= 0 && index <= 3) {
        selectedIndex.value = index;
      }
    }

    isLogin();
  }

  Future<void> isLogin() async {
    await _userPref.saveUser(isLogin: true); // Map<String, dynamic>
  }

  void changeTabIndex(int index) {
    selectedIndex.value = index;
  }
}
