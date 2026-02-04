import 'package:collaby_app/models/onboarding_model.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  final _currentIndex = 0.obs;

  int get currentIndex => _currentIndex.value;

  final List<OnboardingModel> _onboardingData = [
    OnboardingModel(
      image: 'assets/images/onboarding_1.png',
      title: 'Unleash Your\n Potential',
      description:
          'Connect with brands, grow your audience, and turn creativity into income effortlessly',
    ),
    OnboardingModel(
      image: 'assets/images/onboarding_2.png',
      title: 'Unleash Your\n Potential',
      description:
          'Connect with brands, grow your audience, and turn creativity into income effortlessly',
    ),
  ];

  List<OnboardingModel> get onboardingData => _onboardingData;

  void nextPage() {
    if (_currentIndex.value < _onboardingData.length - 1) {
      _currentIndex.value++;
    }
  }

  void previousPage() {
    if (_currentIndex.value > 0) {
      _currentIndex.value--;
    }
  }

  void onGetStarted() {
    // Navigate to next screen
    Get.offAllNamed(RouteName.signUpView);
  }

  void onLogin() {
    // Navigate to login screen
    Get.offAllNamed(RouteName.logInView);
  }
}
