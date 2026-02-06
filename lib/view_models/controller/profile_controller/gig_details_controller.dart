import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GigDetailController extends GetxController {
  final isLoading = false.obs;

  final gigStatus = 'active'.obs;

  void showStatusBottomSheet(BuildContext context) {}

  final gigId = ''.obs;
  final title = ''.obs;
  final description = ''.obs;
  final gigThumbnail = ''.obs;

  final categories = <String>[].obs;
  final durations = <String>[].obs;
  final selectedDuration = ''.obs;

  final videoStyles = <String>[].obs;
  final requirements = <String>[].obs;
  final gallery = <String>[].obs;
  final inclusions = <String>[].obs;

  final selectedPrice = 0.0.obs;
  final deliveryText = ''.obs;
  final numberOfRevisions = 0.obs;

  final gigDetail = Rxn<dynamic>();

  void selectDuration(String value) {
    selectedDuration.value = value;
  }

  Future<void> fetchGigDetail() async {}
}
