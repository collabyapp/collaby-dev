import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collaby_app/data/network/network_api_services.dart';
import 'package:collaby_app/models/create_gig_model/additional_feature.dart';
import 'package:collaby_app/models/create_gig_model/packages_model.dart';
import 'package:collaby_app/models/create_gig_model/video_model.dart';
import 'package:collaby_app/repository/gig_creation_repository/gig_creation_repository.dart';
import 'package:collaby_app/res/colors/app_color.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/utils/utils.dart';
import 'package:collaby_app/view_models/controller/profile_controller/gig_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class CreateGigController extends GetxController with GetTickerProviderStateMixin {
  // ===================== EDIT MODE =====================
  final isEditMode = false.obs;
  String? editingGigId;
  dynamic existingGigData; // GigDetailModel o Map

  // ===================== REPOS =====================
  final NetworkApiServices _networkService = NetworkApiServices();
  final GigCreationRepository gigCreationRepo = GigCreationRepository();

  // ===================== TABS =====================
  late TabController tabController;
  final tabs = const ['tab_pricing', 'tab_description', 'tab_gallery'];
  final currentIndex = 0.obs;
  final RxInt highestCompletedStep = 0.obs;

  // ===================== UPLOAD STATE =====================
  final RxBool isUploadingGig = false.obs;
  final RxDouble uploadProgress = 0.0.obs;

  // cover (thumbnail del intro video)
  String? uploadedCoverUrl;

  // ===================== OVERVIEW (REMOVED) =====================

  // ===================== PRICING =====================
  final selectedCurrency = 'USD'.obs;

  late final List<Rx<PackageModel>> packages;
  late final List<TextEditingController> priceControllers;

  final currencies = const [
    {'code': 'USD', 'name': 'US Dollar (USD)'},
    {'code': 'EUR', 'name': 'Euro (EUR)'},
    {'code': 'GBP', 'name': 'British Pound (GBP)'},
    {'code': 'CHF', 'name': 'Swiss Franc (CHF)'},
    {'code': 'CAD', 'name': 'Canadian Dollar (CAD)'},
    {'code': 'AUD', 'name': 'Australian Dollar (AUD)'},
    {'code': 'NZD', 'name': 'New Zealand Dollar (NZD)'},
    {'code': 'SEK', 'name': 'Swedish Krona (SEK)'},
    {'code': 'NOK', 'name': 'Norwegian Krone (NOK)'},
    {'code': 'DKK', 'name': 'Danish Krone (DKK)'},
    {'code': 'PLN', 'name': 'Polish Zloty (PLN)'},
    {'code': 'MXN', 'name': 'Mexican Peso (MXN)'},
    {'code': 'BRL', 'name': 'Brazilian Real (BRL)'},
    {'code': 'AED', 'name': 'United Arab Emirates Dirham (AED)'},
  ];

  /// UI legacy (si quieres mantenerlo para texto de UI)
  var includedFeatures = <String>[
    'Commercial Use License',
    'Subtitles Included',
    'Raw Video Files',
    'Custom Scriptwriting',
  ];

  /// Presets de extras (custom)
  final extraPresets = const <String>[
    'Additional revision',
    'Rush delivery',
    'Add logo',
    '4K export',
    'Custom request',
  ];

  /// Extras personalizados globales
  final RxList<AdditionalFeature> globalExtras = <AdditionalFeature>[].obs;

  /// Core minimal shared:
  /// Included toggle + price if not included
  final coreScriptIncluded = false.obs;
  final coreRawIncluded = false.obs;
  final coreSubtitlesIncluded = false.obs;

  late final TextEditingController coreScriptPriceController;
  late final TextEditingController coreRawPriceController;
  late final TextEditingController coreSubtitlesPriceController;
  late final TextEditingController revisionsController;

  double get coreScriptExtraPrice =>
      double.tryParse(coreScriptPriceController.text.trim().replaceAll(',', '.')) ?? 0;
  double get coreRawExtraPrice =>
      double.tryParse(coreRawPriceController.text.trim().replaceAll(',', '.')) ?? 0;
  double get coreSubtitlesExtraPrice =>
      double.tryParse(coreSubtitlesPriceController.text.trim().replaceAll(',', '.')) ?? 0;

  void setCoreScriptIncluded(bool v) {
    coreScriptIncluded.value = v;
    if (v) coreScriptPriceController.text = '';
  }

  void setCoreRawIncluded(bool v) {
    coreRawIncluded.value = v;
    if (v) coreRawPriceController.text = '';
  }

  void setCoreSubtitlesIncluded(bool v) {
    coreSubtitlesIncluded.value = v;
    if (v) coreSubtitlesPriceController.text = '';
  }

  /// Pricing Ready:
  /// - los 3 precios deben ser > 0
  /// - deliveryTime y revisions (tier 0) deben estar completos
  bool get isPricingReady {
    final p0 = packages[0].value;
    final allPricesOk = packages.every((rx) => (rx.value.price) > 0);
    final deliveryOk = p0.deliveryTime.trim().isNotEmpty;
    final revisionsOk = p0.revisions > 0;
    return allPricesOk && deliveryOk && revisionsOk;
  }

  // ===================== DESCRIPTION =====================
  final QuillController quillController = QuillController.basic();
  final FocusNode descriptionFocusNode = FocusNode();
  final int descriptionMinChars = 200;
  final RxInt descriptionCharCount = 0.obs;

  bool get isDescriptionReady => descriptionCharCount.value >= descriptionMinChars;

  // ===================== GALLERY =====================
  final ImagePicker _picker = ImagePicker();
  final RxList<VideoItem> galleryVideos = <VideoItem>[].obs;

  VideoItem? get introVideo => galleryVideos.isEmpty ? null : galleryVideos.first;

  final RxBool isDeclarationAccepted = false.obs;

  int get maxVideosAllowed => 4;
  bool get hasIntroVideo => galleryVideos.isNotEmpty;

  bool get isGalleryReady {
    if (!hasIntroVideo) return false;
    if (!isDeclarationAccepted.value) return false;

    for (final v in galleryVideos) {
      if (v.isUploading.value) return false;
      if (v.videoUrl.value == null || v.videoUrl.value!.isEmpty) return false;
    }
    return true;
  }

  // ===================== GIG LINK =====================
  final gigLink = "https://app.collaby.co".obs;

  // ===================== INIT =====================
  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      isEditMode.value = args['isEditMode'] ?? false;
      editingGigId = args['gigId'];
      existingGigData = args['gigData'];
    }

    packages = List.generate(3, (_) => PackageModel().obs);
    priceControllers = List.generate(3, (_) => TextEditingController());

    for (int i = 0; i < 3; i++) {
      priceControllers[i].addListener(() {
        final v = priceControllers[i].text.trim();
        final parsed = double.tryParse(v.replaceAll(',', '')) ?? 0.0;
        updatePackagePrice(i, parsed);
      });
    }

    coreScriptPriceController = TextEditingController();
    coreRawPriceController = TextEditingController();
    coreSubtitlesPriceController = TextEditingController();
    revisionsController = TextEditingController();

    tabController = TabController(length: tabs.length, vsync: this);
    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        final targetIndex = tabController.index;
        if (!canNavigateToTab(targetIndex)) {
          Future.microtask(() => tabController.animateTo(currentIndex.value));
          Utils.snackBar(
            'complete_current_step'.tr,
            'complete_current_step_msg'.tr,
          );
        } else {
          currentIndex.value = targetIndex;
        }
      }
    });

    if (isEditMode.value && existingGigData != null) {
      _prefillGigData();
    }

    quillController.addListener(_updateDescriptionStats);
    _updateDescriptionStats();
  }

  // ===================== PREFILL (EDIT) =====================
  Future<void> _prefillGigData() async {
    try {
      final gig = existingGigData;

      dynamic readField(dynamic obj, String key) {
        if (obj == null) return null;
        if (obj is Map<String, dynamic>) return obj[key];
        try {
          final json = (obj as dynamic).toJson();
          if (json is Map<String, dynamic>) return json[key];
        } catch (_) {}
        try {
          return (obj as dynamic)[key];
        } catch (_) {}
        return null;
      }

      // pricing
      final pricings = readField(gig, 'pricings') ?? readField(gig, 'pricing');
      if (pricings is List) {
        for (int i = 0; i < pricings.length && i < 3; i++) {
          final p = pricings[i];

          dynamic getP(String key) {
            if (p is Map<String, dynamic>) return p[key];
            try {
              final json = (p as dynamic).toJson();
              if (json is Map<String, dynamic>) return json[key];
            } catch (_) {}
            return null;
          }

          // precios por tier
          final price = (getP('price') ?? 0).toDouble();
          final currency = (getP('currency') ?? 'USD').toString();

          priceControllers[i].text = price == 0 ? '' : price.toStringAsFixed(0);
          updatePackagePrice(i, price);
          selectedCurrency.value = currency;

          // shared delivery/revisions desde el tier 0 (si existen)
          if (i == 0) {
            final deliveryDays = (getP('deliveryTimeDays') ?? 0).toInt();
            final revisions = (getP('numberOfRevisions') ?? 0).toInt();
            packages[0].update((pkg) {
              if (pkg == null) return;
              // Si tu PackageModel usa strings tipo "3 Days", setÃ©alo asÃ­:
              pkg.deliveryTime = deliveryDays > 0 ? '$deliveryDays Days' : pkg.deliveryTime;
              pkg.revisions = revisions;
            });
            final revText = revisions == 0 ? '' : revisions.toString();
            if (revisionsController.text != revText) {
              revisionsController.text = revText;
            }
          }

          // includesScriptwriting
          final incSw = getP('includesScriptwriting');
          if (incSw == true) {
            coreScriptIncluded.value = true;
          }

          // features (raw/subtitles)
          final feats = getP('features');
          if (feats is List) {
            final list = feats.map((e) => e.toString()).toList();
            if (list.any((x) => x.toLowerCase().contains('raw'))) coreRawIncluded.value = true;
            if (list.any((x) => x.toLowerCase().contains('subtitle'))) coreSubtitlesIncluded.value = true;
          }

          // additionalFeatures: solo leemos del primer pricing (shared)
          if (i == 0) {
            final add = getP('additionalFeatures');
            if (add is List) {
              for (final x in add) {
                if (x is! Map) continue;
                final t = (x['featureType'] ?? '').toString().toLowerCase().trim();
                final priceStr = (x['price'] ?? 0).toString();
                final daysStr = (x['deliveryTimesIndays'] ?? 0).toString();

                final pr = double.tryParse(priceStr) ?? 0.0;
                final days = int.tryParse(daysStr) ?? 0;

                // core paid
                if (t == 'scriptwriting' || t == 'script') {
                  if (!coreScriptIncluded.value) coreScriptPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawFiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'raw_files' || t == 'rawfiles' || t == 'rawFiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles' || t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawFiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'raw_files' || t == 'rawFiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'subtitles') {
                  if (!coreSubtitlesIncluded.value) coreSubtitlesPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles' || t == 'raw_files' || t == 'rawfiles' || t == 'rawfiles' || t == 'rawFiles' || t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles' || t == 'raw_files' || t == 'rawFiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawfiles' || t == 'raw_files' || t == 'rawFiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'raw_files' || t == 'rawFiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'raw_files') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawFiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else if (t == 'rawfiles' || t == 'rawFiles') {
                  if (!coreRawIncluded.value) coreRawPriceController.text = pr.toString();
                } else {
                  // custom global extra
                  globalExtras.add(AdditionalFeature(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    name: (x['featureType'] ?? 'custom').toString(),
                    price: pr,
                    extraDays: days,
                  ));
                }
              }
            }
          }
        }
      }

      // description
      final desc = (readField(gig, 'description') ?? '').toString();
      quillController.document = Document()..insert(0, desc);

      // gallery
      final gallery = readField(gig, 'gallery');
      if (gallery is List) {
        for (final g in gallery) {
          final url = (g is Map) ? (g['url'] ?? '').toString() : '';
          final thumb = (g is Map) ? (g['thumbnail'] ?? '').toString() : '';
          if (url.trim().isNotEmpty) {
            await loadVideoFromUrl(url, thumb);
          }
        }
      }

      isDeclarationAccepted.value = true;
      highestCompletedStep.value = tabs.length - 1;
    } catch (e) {
      debugPrint('Error pre-filling data: $e');
      Utils.snackBar('error'.tr, 'edit_load_failed'.tr);
    }
  }

  // ===================== PRICING HELPERS =====================
  void updatePackagePrice(int tierIndex, double price) {
    packages[tierIndex].update((p) {
      if (p == null) return;
      p.price = price;
    });
  }

  void addOrUpdateGlobalExtra({
    String? id,
    required String name,
    required double price,
    required int extraDays,
  }) {
    if (id == null) {
      globalExtras.add(
        AdditionalFeature(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: name,
          price: price,
          extraDays: extraDays,
        ),
      );
      return;
    }

    final idx = globalExtras.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    globalExtras[idx] =
        globalExtras[idx].copyWith(name: name, price: price, extraDays: extraDays);
  }

  void removeGlobalExtra(String id) {
    globalExtras.removeWhere((e) => e.id == id);
  }

  // ===================== GALLERY =====================
  void toggleDeclaration() => isDeclarationAccepted.toggle();

  Future<void> pickVideoFromGallery() async {
    if (galleryVideos.length >= maxVideosAllowed) {
      Utils.snackBar(
        'limit_reached'.tr,
        'max_videos_msg'.trParams({'max': '$maxVideosAllowed'}),
      );
      return;
    }

    try {
      final XFile? x = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      if (x == null) return;
      await _ingestPickedVideo(File(x.path));
    } catch (e) {
      debugPrint('Error picking video: $e');
      Utils.snackBar('error'.tr, 'pick_video_failed'.tr);
    }
  }

  Future<void> _ingestPickedVideo(File file) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final item = VideoItem(id: id, path: file.path);
    galleryVideos.add(item);

    try {
      item.isUploading.value = true;
      item.uploadProgress.value = 0.0;
      item.uploadStatus.value = 'upload_preparing_video'.tr;

      item.uploadStatus.value = 'upload_generating_thumbnail'.tr;
      final thumbPath = await _generateThumbnail(file.path);
      if (thumbPath == null) throw Exception('Failed to generate thumbnail');

      item.thumbnailUrl.value = thumbPath;
      item.uploadProgress.value = 0.4;

      item.uploadStatus.value = 'upload_uploading_video'.tr;
      final result = await _networkService.uploadVideoWithThumbnail(
        videoPath: file.path,
        thumbnailPath: thumbPath,
        useCase: 'gigs-attachments',
        headers: const {},
      );

      item.videoUrl.value = result.url;
      if ((result.thumbnailUrl ?? '').isNotEmpty) {
        item.thumbnailUrl.value = result.thumbnailUrl!;
      }

      item.path = result.url;
      item.uploadProgress.value = 1.0;

      await _setVideoDuration(item, file.path);

      item.isUploading.value = false;
      item.uploadStatus.value = 'upload_complete'.tr;
    } catch (e) {
      debugPrint('Error processing video: $e');
      galleryVideos.removeWhere((v) => v.id == id);

      Utils.snackBar(
        'error'.tr,
        e.toString().contains('thumbnail')
            ? 'thumbnail_failed'.tr
            : 'upload_video_failed'.tr,
      );
    }
  }

  Future<String?> _generateThumbnail(String videoPath) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 300,
        quality: 85,
      );
      return thumbnailPath;
    } catch (e) {
      debugPrint('Error generating thumbnail: $e');
      return null;
    }
  }

  Future<void> _setVideoDuration(VideoItem item, String localPath) async {
    try {
      final ctrl = VideoPlayerController.file(File(localPath));
      await ctrl.initialize().timeout(const Duration(seconds: 5));
      item.duration.value = ctrl.value.duration;
      await ctrl.dispose();
    } catch (e) {
      debugPrint('Error getting video duration: $e');
      item.duration.value = Duration.zero;
    }
  }

  void removeVideo(String id) {
    try {
      final idx = galleryVideos.indexWhere((v) => v.id == id);
      if (idx == -1) return;
      galleryVideos.removeAt(idx);
    } catch (e) {
      debugPrint('Error removing video: $e');
      Utils.snackBar('error'.tr, 'remove_video_failed'.tr);
    }
  }

  Future<void> loadVideoFromUrl(String videoUrl, String thumbnailUrl) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final item = VideoItem(id: id, path: videoUrl);
    item.videoUrl.value = videoUrl;
    item.thumbnailUrl.value = thumbnailUrl;
    item.isUploading.value = false;
    galleryVideos.add(item);
  }

  void cleanupGalleryVideos() => galleryVideos.clear();

  // ===================== VALIDATION =====================
  bool _validatePricing() {
    if (!isPricingReady) {
      Utils.snackBar(
        'incomplete_pricing'.tr,
        'incomplete_pricing_msg'.tr,
      );
      return false;
    }

    // core rules: si no estÃ¡ incluido, el precio extra puede ser 0 (significa no ofrecerlo),
    // pero si estÃ¡ incluido, no debe tener precio
    if (coreScriptIncluded.value && coreScriptExtraPrice > 0) {
      Utils.snackBar('invalid'.tr, 'script_included_priced'.tr);
      return false;
    }
    if (coreRawIncluded.value && coreRawExtraPrice > 0) {
      Utils.snackBar('invalid'.tr, 'raw_included_priced'.tr);
      return false;
    }
    if (coreSubtitlesIncluded.value && coreSubtitlesExtraPrice > 0) {
      Utils.snackBar('invalid'.tr, 'subtitles_included_priced'.tr);
      return false;
    }

    return true;
  }

  bool _validateDescription() {
    if (descriptionCharCount.value < descriptionMinChars) {
      Utils.snackBar(
        'description_too_short'.tr,
        'description_min_chars'.trParams({'min': '$descriptionMinChars'}),
      );
      return false;
    }
    return true;
  }

  bool _validateGallery() {
    if (!hasIntroVideo) {
      Utils.snackBar('add_intro_video'.tr, 'add_intro_video_msg'.tr);
      return false;
    }
    if (!isDeclarationAccepted.value) {
      Utils.snackBar('accept_declaration'.tr, 'accept_declaration_msg'.tr);
      return false;
    }
    final uploadingVideos = galleryVideos.where((v) => v.isUploading.value).toList();
    if (uploadingVideos.isNotEmpty) {
      Utils.snackBar('upload_in_progress'.tr, 'upload_in_progress_msg'.tr);
      return false;
    }
    return true;
  }

  bool get isCurrentStepReady {
    switch (currentIndex.value) {
      case 0:
        return isPricingReady;
      case 1:
        return isDescriptionReady;
      case 2:
        return isGalleryReady;
      default:
        return false;
    }
  }

  // ===================== NAVIGATION =====================
  bool canNavigateToTab(int targetIndex) => targetIndex <= highestCompletedStep.value;

  void onTabTapped(int index) {
    if (canNavigateToTab(index)) {
      tabController.animateTo(index);
      currentIndex.value = index;
    } else {
      Utils.snackBar('complete_current_step'.tr, 'complete_current_step_msg'.tr);
    }
  }

  void onNext() {
    final idx = currentIndex.value;
    final valid = switch (idx) {
      0 => _validatePricing(),
      1 => _validateDescription(),
      2 => _validateGallery(),
      _ => true,
    };

    if (!valid) return;

    if (idx >= highestCompletedStep.value) {
      highestCompletedStep.value = idx + 1;
    }

    if (idx < tabs.length - 1) {
      tabController.animateTo(idx + 1);
      currentIndex.value = idx + 1;
    } else {
      submitGigToApi();
    }
  }

  // ===================== PAYLOAD =====================
  int _parseDeliveryTime(String deliveryTime) {
    final match = RegExp(r'(\d+)').firstMatch(deliveryTime);
    if (match != null) return int.parse(match.group(1)!);
    return 3;
  }

  String _inferFeatureTypeFromName(String name) {
    final n = name.toLowerCase();
    if (n.contains('revision')) return 'additionalRevision';
    if (n.contains('rush')) return 'rushDelivery';
    if (n.contains('logo')) return 'addLogo';
    if (n.contains('4k')) return 'export4k';
    return 'custom';
  }

  Map<String, dynamic> _generateGigPayload() {
    final packageNames = ['15 Sec', '30 Sec', '60 Sec'];

    // shared delivery/revisions desde tier0
    final sharedDeliveryDays = _parseDeliveryTime(packages[0].value.deliveryTime);
    final sharedRevisions = packages[0].value.revisions;

    // shared features (incluidos)
    final sharedFeatures = <String>[
      'Commercial Use License',
      if (coreRawIncluded.value) 'Raw Video Files',
      if (coreSubtitlesIncluded.value) 'Subtitles Included',
      // OJO: "Custom Scriptwriting" NO va en features si lo tratas con boolean separado,
      // para evitar duplicidades.
    ];

    // shared extras (paid)
    final sharedExtras = <Map<String, dynamic>>[];

    String _safeTitle(dynamic value) {
      final t = value == null ? '' : value.toString().trim();
      return t.isEmpty ? 'Extra' : t;
    }

    if (!coreScriptIncluded.value && coreScriptExtraPrice > 0) {
      sharedExtras.add({
        'featureType': 'scriptwriting',
        'title': _safeTitle('Scriptwriting'),
        'price': coreScriptExtraPrice,
        'deliveryTimesIndays': 0,
      });
    }

    if (!coreRawIncluded.value && coreRawExtraPrice > 0) {
      sharedExtras.add({
        'featureType': 'rawFiles',
        'title': _safeTitle('Raw Video Files'),
        'price': coreRawExtraPrice,
        'deliveryTimesIndays': 0,
      });
    }

    if (!coreSubtitlesIncluded.value && coreSubtitlesExtraPrice > 0) {
      sharedExtras.add({
        'featureType': 'subtitles',
        'title': _safeTitle('Subtitles'),
        'price': coreSubtitlesExtraPrice,
        'deliveryTimesIndays': 0,
      });
    }

    // custom extras
    for (final e in globalExtras) {
      final type = _inferFeatureTypeFromName(e.name);
      final title = _safeTitle(e.name);

      // no duplicar si el core ya lo estÃ¡ ofreciendo (por tipo)
      if (type == 'additionalRevision' ||
          type == 'rushDelivery' ||
          type == 'addLogo' ||
          type == 'export4k' ||
          type == 'custom') {
        sharedExtras.add({
          'featureType': type,
          'title': _safeTitle(title),
          'price': e.price,
          'deliveryTimesIndays': e.extraDays,
        });
      }
    }

    final pricingList = <Map<String, dynamic>>[];

    for (int i = 0; i < packages.length; i++) {
      final pkg = packages[i].value;

      pricingList.add({
        'pricingName': packageNames[i],
        'title': packageNames[i],
        'currency': selectedCurrency.value,
        'price': pkg.price,
        'deliveryTimeDays': sharedDeliveryDays,
        'numberOfRevisions': sharedRevisions,
        'features': sharedFeatures,
        'additionalFeatures': sharedExtras,
      });
    }

    // harden: ensure additionalFeatures titles are always strings
    final sanitizedPricingList = pricingList
        .map((p) {
          final rawExtras = p['additionalFeatures'];
          if (rawExtras is List) {
            final cleaned = rawExtras.map((e) {
              if (e is Map<String, dynamic>) {
                final title = e['title'];
                return {
                  ...e,
                  'title': title == null ? 'Extra' : title.toString(),
                };
              }
              return e;
            }).toList();
            return {...p, 'additionalFeatures': cleaned};
          }
          return p;
        })
        .toList();

    // gallery
    final galleryList = <Map<String, dynamic>>[];
    for (final video in galleryVideos) {
      final videoUrl = video.videoUrl.value;
      final thumbUrl = video.thumbnailUrl.value;

      if (videoUrl != null && videoUrl.isNotEmpty) {
        galleryList.add({
          'name': videoUrl.split('/').last,
          'type': 'video/mp4',
          'url': videoUrl,
          'thumbnail': thumbUrl ?? '',
          'size': 0,
        });
      }
    }

    uploadedCoverUrl = introVideo?.thumbnailUrl.value ?? '';

    final description = quillController.document.toPlainText().trim();

    return <String, dynamic>{
      'gigThumbnail': uploadedCoverUrl ?? '',
      'videoStyle': <String>[],
      'pricing': sanitizedPricingList,
      'description': description,
      'gallery': galleryList,
    };
  }

  // ===================== SUBMISSION =====================
  Future<void> submitGigToApi() async {
    if (!_validateGallery()) return;

    isUploadingGig.value = true;
    uploadProgress.value = 0.0;

    _showUploadProgressDialog();

    try {
      uploadProgress.value = 0.2;

      final allUploaded = galleryVideos.every((v) => v.isReady);
      if (!allUploaded) throw Exception('upload_in_progress_msg'.tr);
      uploadProgress.value = 0.5;

      final payload = _generateGigPayload();
      debugPrint('=== PAYLOAD ===');
      debugPrint(jsonEncode(payload));
      // Debug payload dialog removed for production builds.
      uploadProgress.value = 0.7;

      final response = isEditMode.value
          ? await gigCreationRepo.updateGigApi(editingGigId!, payload)
          : await gigCreationRepo.createGigApi(payload);

      uploadProgress.value = 1.0;

      if (Get.isDialogOpen ?? false) Get.back();

      if (response == null) throw Exception('error_no_response'.tr);

      final statusCode = response['statusCode'] as int?;
      final message = response['message'] as String?;

      if (statusCode == 201 || statusCode == 200) {
        if (isEditMode.value) {
          Get.back();
          try {
            Get.find<GigDetailController>().fetchGigDetail();
          } catch (_) {}
        } else {
          Utils.snackBar('success'.tr, message ?? 'publish_success'.tr);
          _navigateToSuccessScreen();
        }
      } else {
        throw Exception(message ?? 'error_failed_status'.trParams({'code': '$statusCode'}));
      }
    } catch (e, stackTrace) {
      debugPrint('Submission error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (Get.isDialogOpen ?? false) Get.back();

      final s = e.toString();
      String errorMessage = isEditMode.value
          ? 'error_update_failed'.tr
          : 'error_publish_failed'.tr;

      if (s.contains('SocketException')) {
        errorMessage = 'error_no_internet'.tr;
      } else if (s.contains('TimeoutException')) {
        errorMessage = 'error_timeout'.tr;
      } else {
        errorMessage = s.replaceFirst('Exception: ', '');
      }

      Utils.snackBar('error'.tr, errorMessage);
    } finally {
      isUploadingGig.value = false;
      uploadProgress.value = 0.0;
    }
  }

  // Debug payload dialog removed for production builds.

  void _showUploadProgressDialog() {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Lottie.asset(
                    'assets/json/loading.json',
                    repeat: true,
                    width: 500,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isEditMode.value ? 'uploading_title_update'.tr : 'uploading_title_create'.tr,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Obx(() {
                  final progress = uploadProgress.value;
                  String message = 'upload_preparing'.tr;
                  if (progress < 0.5) message = 'upload_uploading_videos'.tr;
                  else if (progress < 1.0) message = 'upload_finalizing'.tr;
                  else message = 'upload_complete'.tr;
                  return Text(
                    message,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  );
                }),
                const SizedBox(height: 24),
                Obx(() {
                  final progress = uploadProgress.value;
                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 16),
                Text(
                  'upload_wait'.tr,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _navigateToSuccessScreen() => Get.offAllNamed(RouteName.gigSuccessView);

  void copyLink() {
    Clipboard.setData(ClipboardData(text: gigLink.value));
    Utils.snackBar('copied'.tr, 'link_copied'.tr);
  }

  void exploreJobs() => Get.offAllNamed(RouteName.bottomNavigationView);

// ================= COMPATIBILITY LAYER =================

RxList<AdditionalFeature> get additionalFeatures => globalExtras;

void addAdditionalFeature(AdditionalFeature feature) {
  globalExtras.add(feature);
}

void removeAdditionalFeature(String id) {
  globalExtras.removeWhere((e) => e.id == id);
}

List<String> get featureOptions => extraPresets;

final RxnString selectedFeature = RxnString();

void selectFeature(String? value) => selectedFeature.value = value;
void resetFeaturePicker() => selectedFeature.value = null;

List<VideoItem> get portfolioVideos {
  if (galleryVideos.length <= 1) return <VideoItem>[];
  return galleryVideos.sublist(1);
}

String formatDuration(Duration d) {
  final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$mm:$ss';
}

final RxInt currentTierIndex = 0.obs;

void setCurrentTier(int index) => currentTierIndex.value = index;

void updatePackageRevisions(int revisions) {
  packages[0].update((p) {
    if (p == null) return;
    p.revisions = revisions;
  });
  final nextText = revisions == 0 ? '' : revisions.toString();
  if (revisionsController.text != nextText) {
    revisionsController.text = nextText;
  }
}

void updatePackageDeliveryTime(String deliveryTime) {
  packages[0].update((p) {
    if (p == null) return;
    p.deliveryTime = deliveryTime;
  });
}

List<String> get videoStyles => <String>[];
RxList<String> get selectedStyles => <String>[].obs;
void toggleStyle(String style) {}

final RxList<String> tags = <String>[].obs;
void addTag(String tag) {
  final t = tag.trim();
  if (t.isNotEmpty && !tags.contains(t)) tags.add(t);
}
void removeTag(String tag) => tags.remove(tag);

  @override
  void onClose() {
    uploadedCoverUrl = null;
    descriptionFocusNode.dispose();
    quillController.removeListener(_updateDescriptionStats);

    for (final c in priceControllers) {
      c.dispose();
    }

    coreScriptPriceController.dispose();
    coreRawPriceController.dispose();
    coreSubtitlesPriceController.dispose();
    revisionsController.dispose();

    cleanupGalleryVideos();
    tabController.dispose();
    super.onClose();
  }

  void _updateDescriptionStats() {
    final text = quillController.document.toPlainText();
    descriptionCharCount.value = _countChars(text);
  }

  int _countChars(String text) {
    final cleaned = text.replaceAll(RegExp(r'\s+'), '').trim();
    if (cleaned.isEmpty) return 0;
    return cleaned.length;
  }
}



