import 'package:get/get.dart';

String localizeGigFeatureLabel(String raw) {
  final value = raw.trim();
  final normalized = value.toLowerCase();

  if (normalized.contains('commercial')) return 'extra_commercial'.tr;
  if (normalized.contains('raw')) return 'extra_raw'.tr;
  if (normalized.contains('subtitle')) return 'extra_subtitles'.tr;
  if (normalized.contains('script')) return 'extra_script'.tr;

  if (normalized == 'additional revision' ||
      normalized == 'additional_revision' ||
      normalized == 'additionalrevision') {
    return 'preset_additional_revision'.tr;
  }
  if (normalized == 'rush delivery' ||
      normalized == 'rush_delivery' ||
      normalized == 'rushdelivery') {
    return 'preset_rush_delivery'.tr;
  }
  if (normalized == 'add logo' || normalized == 'add_logo' || normalized == 'addlogo') {
    return 'preset_add_logo'.tr;
  }
  if (normalized == '4k export' || normalized == '4k_export' || normalized == 'export4k') {
    return 'preset_4k_export'.tr;
  }
  if (normalized == 'custom request' ||
      normalized == 'custom_request' ||
      normalized == 'customrequest' ||
      normalized == 'custom') {
    return 'preset_custom_request'.tr;
  }

  return value;
}

