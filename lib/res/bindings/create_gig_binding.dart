import 'package:collaby_app/view_models/controller/gig_creation_controller/create_gig_controller.dart';
import 'package:get/get.dart';

class CreateGigBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateGigController>(
      () => CreateGigController(),
      fenix: true,
    );
  }
}
