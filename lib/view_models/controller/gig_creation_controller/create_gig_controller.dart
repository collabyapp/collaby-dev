import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collaby_app/data/network/network_api_services.dart';
import 'package:collaby_app/models/create_gig_model/additional_feature.dart';
import 'package:collaby_app/models/create_gig_model/packages_model.dart';
import 'package:collaby_app/models/create_gig_model/video_model.dart';
import 'package:collaby_app/repository/gig_creation_repository/gig_creation_repository.dart';
import 'package:collaby_app/repository/profile_repository/profile_repository.dart';
import 'package:collaby_app/res/colors/app_color.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/utils/utils.dart';
import 'package:collaby_app/view_models/controller/profile_controller/gig_details_controller.dart';
import 'package:collaby_app/view_models/controller/profile_controller/profile_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class CreateGigController extends GetxController
    with GetTickerProviderStateMixin {
  // ===================== EDIT MODE =====================
  final isEditMode = false.obs;
  String? editingGigId;
  dynamic existingGigData; // GigDetailModel o Map

  // ===================== REPOS =====================
  final NetworkApiServices _networkService = NetworkApiServices();
  final GigCreationRepository gigCreationRepo = GigCreationRepository();
  final ProfileRepository _profileRepo = ProfileRepository();

  // ===================== TABS =====================
  late TabController tabController;
  final tabs = const [
    'tab_niches',
    'tab_pricing',
    'tab_description',
    'tab_gallery',
  ];
  final currentIndex = 0.obs;
  final RxInt highestCompletedStep = 0.obs;

  // ===================== UPLOAD STATE =====================
  final RxBool isUploadingGig = false.obs;
  final RxDouble uploadProgress = 0.0.obs;

  // cover (thumbnail del intro video)
  String? uploadedCoverUrl;

  // ===================== SERVICE NICHES =====================
  final List<String> allServiceNiches = [
    'niche_couple_creator',
    'niche_have_pets',
    'niche_mom_creator',
    'niche_green_screen',
    'niche_car_content',
    'niche_travel_content',
    'niche_outside',
    'niche_inside',
    'niche_interviews',
    'niche_podcast',
  ];

  final RxList<String> selectedServiceNiches = <String>[].obs;

  void toggleServiceNiche(String niche) {
    if (selectedServiceNiches.contains(niche)) {
      selectedServiceNiches.remove(niche);
    } else {
      selectedServiceNiches.add(niche);
    }
  }

  String _nicheKeyToPayload(String key) {
    switch (key) {
      case 'niche_couple_creator':
        return "I'm a couple creator";
      case 'niche_have_pets':
        return 'I have pets';
      case 'niche_mom_creator':
        return "I'm a mom creator";
      case 'niche_green_screen':
        return 'I can do green screen';
      case 'niche_car_content':
        return 'I can do car content';
      case 'niche_travel_content':
        return 'I can do travel content';
      case 'niche_outside':
        return 'I can do outdoor content';
      case 'niche_inside':
        return 'I can do indoor content';
      case 'niche_interviews':
        return 'I can do interviews';
      case 'niche_podcast':
        return 'I can do podcasts';
      default:
        return key;
    }
  }

  String _payloadToNicheKey(String value) {
    final v = value.toLowerCase().trim();
    if (v.contains('couple')) return 'niche_couple_creator';
    if (v.contains('pets')) return 'niche_have_pets';
    if (v.contains('mom')) return 'niche_mom_creator';
    if (v.contains('green')) return 'niche_green_screen';
    if (v.contains('car')) return 'niche_car_content';
    if (v.contains('travel')) return 'niche_travel_content';
    if (v.contains('outdoor')) return 'niche_outside';
    if (v.contains('indoor')) return 'niche_inside';
    if (v.contains('interview')) return 'niche_interviews';
    if (v.contains('podcast')) return 'niche_podcast';
    return value;
  }

  // ===================== PRICING =====================
  final selectedCurrency = 'EUR'.obs;

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

  /// Included feature labels (UI preview)
  var includedFeatures = <String>[
    'Commercial Use License',
    'Subtitles Included',
    'Raw Video Files',
    'Custom Scriptwriting',
  ];

  /// Presets de extras (custom)
  final extraPresets = const <String>['Additional revision', 'Custom request'];

  /// Extras personalizados globales
  final RxList<AdditionalFeature> globalExtras = <AdditionalFeature>[].obs;
  final RxString creatorBadge = 'none'.obs;
  final RxInt levelProgressPercent = 0.obs;
  final RxMap<String, dynamic> levelRequirements = <String, dynamic>{}.obs;
  final RxInt previewRefreshTick = 0.obs;

  /// Core minimal shared:
  /// Included toggle + price if not included
  final coreScriptIncluded = false.obs;
  final coreRawIncluded = false.obs;
  final coreSubtitlesIncluded = false.obs;
  final coreCommercialIncluded = true.obs;

  late final TextEditingController coreScriptPriceController;
  late final TextEditingController coreRawPriceController;
  late final TextEditingController coreSubtitlesPriceController;
  late final TextEditingController coreCommercialPriceController;
  late final TextEditingController revisionsController;

  double get coreScriptExtraPrice =>
      double.tryParse(
        coreScriptPriceController.text.trim().replaceAll(',', '.'),
      ) ??
      0;
  double get coreRawExtraPrice =>
      double.tryParse(
        coreRawPriceController.text.trim().replaceAll(',', '.'),
      ) ??
      0;
  double get coreSubtitlesExtraPrice =>
      double.tryParse(
        coreSubtitlesPriceController.text.trim().replaceAll(',', '.'),
      ) ??
      0;
  double get coreCommercialExtraPrice =>
      double.tryParse(
        coreCommercialPriceController.text.trim().replaceAll(',', '.'),
      ) ??
      0;

  void markPreviewDirty() {
    previewRefreshTick.value++;
  }

  void setCoreScriptIncluded(bool v) {
    coreScriptIncluded.value = v;
    if (v) coreScriptPriceController.text = '';
    markPreviewDirty();
  }

  void setCoreRawIncluded(bool v) {
    coreRawIncluded.value = v;
    if (v) coreRawPriceController.text = '';
    markPreviewDirty();
  }

  void setCoreSubtitlesIncluded(bool v) {
    coreSubtitlesIncluded.value = v;
    if (v) coreSubtitlesPriceController.text = '';
    markPreviewDirty();
  }

  void setCoreCommercialIncluded(bool v) {
    coreCommercialIncluded.value = v;
    if (v) coreCommercialPriceController.text = '';
    markPreviewDirty();
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

  bool get isNichesReady => selectedServiceNiches.isNotEmpty;

  // ===================== DESCRIPTION =====================
  final QuillController quillController = QuillController.basic();
  final FocusNode descriptionFocusNode = FocusNode();
  final int descriptionMinChars = 200;
  final RxInt descriptionCharCount = 0.obs;

  bool get isDescriptionReady =>
      descriptionCharCount.value >= descriptionMinChars;

  // ===================== GALLERY =====================
  final ImagePicker _picker = ImagePicker();
  final RxList<VideoItem> galleryVideos = <VideoItem>[].obs;

  VideoItem? get introVideo =>
      galleryVideos.isEmpty ? null : galleryVideos.first;

  final RxBool isDeclarationAccepted = false.obs;

  int get maxIntroVideosAllowed => 1;
  int get maxPortfolioVideosAllowed => 2;
  int get maxVideosAllowed => maxIntroVideosAllowed + maxPortfolioVideosAllowed;
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
    coreCommercialPriceController = TextEditingController();
    revisionsController = TextEditingController();

    coreScriptPriceController.addListener(() {
      final hasValue = coreScriptPriceController.text.trim().isNotEmpty;
      if (hasValue && coreScriptIncluded.value) {
        coreScriptIncluded.value = false;
      }
      markPreviewDirty();
    });
    coreRawPriceController.addListener(() {
      final hasValue = coreRawPriceController.text.trim().isNotEmpty;
      if (hasValue && coreRawIncluded.value) {
        coreRawIncluded.value = false;
      }
      markPreviewDirty();
    });
    coreSubtitlesPriceController.addListener(() {
      final hasValue = coreSubtitlesPriceController.text.trim().isNotEmpty;
      if (hasValue && coreSubtitlesIncluded.value) {
        coreSubtitlesIncluded.value = false;
      }
      markPreviewDirty();
    });
    coreCommercialPriceController.addListener(() {
      final hasValue = coreCommercialPriceController.text.trim().isNotEmpty;
      if (hasValue && coreCommercialIncluded.value) {
        coreCommercialIncluded.value = false;
      }
      markPreviewDirty();
    });
    revisionsController.addListener(markPreviewDirty);

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

    _loadCreatorBadge();

    quillController.addListener(_updateDescriptionStats);
    _updateDescriptionStats();
  }

  Future<void> _loadCreatorBadge() async {
    try {
      final response = await _profileRepo.getCreatorProfileApi();
      if (response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          final raw = (data['badge'] ?? '').toString().trim().toLowerCase();
          if (raw.isNotEmpty) {
            creatorBadge.value = raw;
          }

          final progress = data['creatorLevelProgress'];
          if (progress is Map<String, dynamic>) {
            final pct = progress['levelTwoProgressPercent'];
            levelProgressPercent.value = (pct is num) ? pct.round() : 0;

            final req = progress['requirements'];
            if (req is Map<String, dynamic>) {
              levelRequirements.value = req;
            }
          } else {
            // Fallback for older backend payloads
            final reviewStats = data['reviewStats'];
            final totalReviews = reviewStats is Map<String, dynamic>
                ? (reviewStats['totalReviews'] as num?)?.toInt() ?? 0
                : 0;
            final averageRating = reviewStats is Map<String, dynamic>
                ? (reviewStats['averageRating'] as num?)?.toDouble() ?? 0
                : 0;
            final hasGig = data['isGigCreated'] == true;

            levelRequirements.value = {
              'gigs': {'current': hasGig ? 1 : 0, 'target': 1, 'met': hasGig},
              'reviews': {
                'current': totalReviews,
                'target': 10,
                'met': totalReviews >= 10,
              },
              'averageRating': {
                'current': averageRating,
                'target': 4.5,
                'met': averageRating >= 4.5,
              },
            };
            final checks = [
              hasGig ? 1 : 0,
              totalReviews >= 10 ? 1 : 0,
              averageRating >= 4.5 ? 1 : 0,
            ];
            levelProgressPercent.value =
                ((checks.reduce((a, b) => a + b) / checks.length) * 100)
                    .round();
          }
        }
      }
    } catch (_) {
      // Non-blocking: pricing UI falls back to "new" level if profile call fails.
    }
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
      final globalAdditionalFeaturesRaw = readField(gig, 'additionalFeatures');
      final globalAdditionalFeatures = globalAdditionalFeaturesRaw is List
          ? globalAdditionalFeaturesRaw
          : const <dynamic>[];
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
          final currency = (getP('currency') ?? 'EUR').toString();

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
              pkg.deliveryTime = deliveryDays > 0
                  ? '$deliveryDays Days'
                  : pkg.deliveryTime;
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
            if (list.any((x) => x.toLowerCase().contains('raw')))
              coreRawIncluded.value = true;
            if (list.any((x) => x.toLowerCase().contains('subtitle')))
              coreSubtitlesIncluded.value = true;
          }

          // additionalFeatures: solo leemos del primer pricing (shared)
          if (i == 0) {
            final add = globalAdditionalFeatures.isNotEmpty
                ? globalAdditionalFeatures
                : getP('additionalFeatures');
            if (add is List) {
              for (final x in add) {
                if (x is! Map) continue;
                final t = (x['featureType'] ?? '')
                    .toString()
                    .toLowerCase()
                    .trim();
                final pr =
                    ((x['price'] ?? 0) as num?)?.toDouble() ??
                    (double.tryParse((x['price'] ?? 0).toString()) ?? 0.0);
                final days =
                    ((x['deliveryTimesIndays'] ?? 0) as num?)?.toInt() ??
                    (int.tryParse((x['deliveryTimesIndays'] ?? 0).toString()) ??
                        0);

                if (t == 'script' || t == 'scriptwriting') {
                  if (!coreScriptIncluded.value) {
                    coreScriptPriceController.text = pr.toString();
                  }
                  continue;
                }

                if (t == 'rawfiles' || t == 'raw_files') {
                  if (!coreRawIncluded.value) {
                    coreRawPriceController.text = pr.toString();
                  }
                  continue;
                }

                if (t == 'subtitles') {
                  if (!coreSubtitlesIncluded.value) {
                    coreSubtitlesPriceController.text = pr.toString();
                  }
                  continue;
                }

                final readableName = switch (t) {
                  'additionalrevision' => 'Additional revision',
                  'customrequest' => 'Custom request',
                  _ => (x['featureType'] ?? 'custom').toString(),
                };

                globalExtras.add(
                  AdditionalFeature(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    name: readableName,
                    price: pr,
                    extraDays: days,
                  ),
                );
              }
            }
          }
        }
      }

      // video styles / niches
      final styles =
          readField(gig, 'videoStyles') ?? readField(gig, 'videoStyle');
      if (styles is List) {
        final extracted = <String>[];
        for (final s in styles) {
          if (s is Map) {
            final name = s['name']?.toString().trim();
            if (name != null && name.isNotEmpty) extracted.add(name);
          } else {
            final name = s?.toString().trim();
            if (name != null && name.isNotEmpty) extracted.add(name);
          }
        }
        if (extracted.isNotEmpty) {
          selectedServiceNiches
            ..clear()
            ..addAll(extracted.map(_payloadToNicheKey));
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
      if (!isEditMode.value) {
        Utils.snackBar('error'.tr, 'edit_load_failed'.tr);
      }
    }
  }

  // ===================== PRICING HELPERS =====================
  void updatePackagePrice(int tierIndex, double price) {
    packages[tierIndex].update((p) {
      if (p == null) return;
      p.price = price;
    });
    markPreviewDirty();
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
    globalExtras[idx] = globalExtras[idx].copyWith(
      name: name,
      price: price,
      extraDays: extraDays,
    );
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
      if (kIsWeb) {
        await _ingestPickedVideoWeb(x);
      } else {
        await _ingestPickedVideo(File(x.path));
      }
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

  Future<void> _ingestPickedVideoWeb(XFile file) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final item = VideoItem(id: id, path: file.path);
    galleryVideos.add(item);

    try {
      item.isUploading.value = true;
      item.uploadProgress.value = 0.0;
      item.uploadStatus.value = 'upload_preparing_video'.tr;

      final videoBytes = await file.readAsBytes();
      if (videoBytes.isEmpty) {
        throw Exception('Selected video is empty');
      }

      item.uploadStatus.value = 'upload_generating_thumbnail'.tr;
      final thumbBytes = await _buildWebFallbackThumbnailBytes();
      item.uploadProgress.value = 0.4;

      item.uploadStatus.value = 'upload_uploading_video'.tr;
      final result = await _networkService.uploadVideoWithThumbnail(
        videoBytes: videoBytes,
        thumbnailBytes: thumbBytes,
        videoFileName: file.name.isEmpty ? 'video.mp4' : file.name,
        thumbnailFileName: 'thumbnail.png',
        useCase: 'gigs-attachments',
        headers: const {},
      );

      item.videoUrl.value = result.url;
      if ((result.thumbnailUrl ?? '').isNotEmpty) {
        item.thumbnailUrl.value = result.thumbnailUrl!;
      }

      item.path = result.url;
      item.uploadProgress.value = 1.0;
      item.isUploading.value = false;
      item.uploadStatus.value = 'upload_complete'.tr;
    } catch (e) {
      debugPrint('Error processing web video: $e');
      galleryVideos.removeWhere((v) => v.id == id);

      Utils.snackBar('error'.tr, 'upload_video_failed'.tr);
    }
  }

  Future<Uint8List> _buildWebFallbackThumbnailBytes() async {
    // 1x1 PNG transparente en base64 para evitar dependencia de assets en web debug.
    const transparentPngBase64 =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO7Z3f8AAAAASUVORK5CYII=';
    return base64Decode(transparentPngBase64);
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
      Utils.snackBar('incomplete_pricing'.tr, 'incomplete_pricing_msg'.tr);
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
    if (coreCommercialIncluded.value && coreCommercialExtraPrice > 0) {
      Utils.snackBar('invalid'.tr, 'commercial_included_priced'.tr);
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

  bool _validateNiches() {
    if (!isNichesReady) {
      Utils.snackBar('select_niches'.tr, 'select_niches_msg'.tr);
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
    final uploadingVideos = galleryVideos
        .where((v) => v.isUploading.value)
        .toList();
    if (uploadingVideos.isNotEmpty) {
      Utils.snackBar('upload_in_progress'.tr, 'upload_in_progress_msg'.tr);
      return false;
    }
    return true;
  }

  bool get isCurrentStepReady {
    switch (currentIndex.value) {
      case 0:
        return isNichesReady;
      case 1:
        return isPricingReady;
      case 2:
        return isDescriptionReady;
      case 3:
        return isGalleryReady;
      default:
        return false;
    }
  }

  // ===================== NAVIGATION =====================
  bool canNavigateToTab(int targetIndex) =>
      targetIndex <= highestCompletedStep.value;

  void onTabTapped(int index) {
    if (canNavigateToTab(index)) {
      tabController.animateTo(index);
      currentIndex.value = index;
    } else {
      Utils.snackBar(
        'complete_current_step'.tr,
        'complete_current_step_msg'.tr,
      );
    }
  }

  void onNext() {
    final idx = currentIndex.value;
    final valid = switch (idx) {
      0 => _validateNiches(),
      1 => _validatePricing(),
      2 => _validateDescription(),
      3 => _validateGallery(),
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
    if (n.contains('script')) return 'scriptwriting';
    if (n.contains('raw')) return 'rawFiles';
    if (n.contains('subtitle')) return 'subtitles';
    if (n.contains('commercial')) return 'commercialUseLicense';
    if (n.contains('custom request')) return 'customRequest';
    return name.trim();
  }

  Map<String, dynamic> _generateGigPayload() {
    final packageNames = ['15 Sec', '30 Sec', '60 Sec'];

    // shared delivery/revisions desde tier0
    final sharedDeliveryDays = _parseDeliveryTime(
      packages[0].value.deliveryTime,
    );
    final sharedRevisions = packages[0].value.revisions;

    // shared features (incluidos)
    final sharedFeatures = <String>[
      if (coreCommercialIncluded.value) 'Commercial Use License',
      if (coreRawIncluded.value) 'Raw Video Files',
      if (coreSubtitlesIncluded.value) 'Subtitles Included',
      // OJO: "Custom Scriptwriting" NO va en features si lo tratas con boolean separado,
      // para evitar duplicidades.
    ];

    // shared extras (paid)
    final sharedExtras = <Map<String, dynamic>>[];

    String _safeFeatureType(String value) {
      final normalized = value.trim().toLowerCase();
      String slug(String raw) => raw
          .trim()
          .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')
          .replaceAll(RegExp(r'_+'), '_')
          .replaceAll(RegExp(r'^_|_$'), '')
          .toLowerCase();
      switch (normalized) {
        case 'script':
        case 'scriptwriting':
          return 'scriptwriting';
        case 'additionalrevision':
          return 'additionalRevision';
        case 'rawfiles':
        case 'rawvideofiles':
        case 'raw video files':
          return 'rawFiles';
        case 'subtitles':
        case 'subtitlesincluded':
        case 'subtitles included':
          return 'subtitles';
        case 'rushdelivery':
        case 'rush delivery':
          return 'rushDelivery';
        case 'addlogo':
        case 'add logo':
          return 'addLogo';
        case 'export4k':
        case '4k export':
          return 'export4k';
        case 'commercialuselicense':
        case 'commercial use license':
          return 'commercialUseLicense';
        case 'customrequest':
        case 'custom request':
          return 'customRequest';
        default:
          final generated = slug(value);
          return generated.isEmpty ? '' : generated;
      }
    }

    if (!coreScriptIncluded.value && coreScriptExtraPrice > 0) {
      sharedExtras.add({
        'featureType': _safeFeatureType('scriptwriting'),
        'price': coreScriptExtraPrice,
        'deliveryTimesIndays': 0,
      });
    }

    if (!coreRawIncluded.value && coreRawExtraPrice > 0) {
      sharedExtras.add({
        'featureType': _safeFeatureType('rawFiles'),
        'price': coreRawExtraPrice,
        'deliveryTimesIndays': 0,
      });
    }

    if (!coreSubtitlesIncluded.value && coreSubtitlesExtraPrice > 0) {
      sharedExtras.add({
        'featureType': _safeFeatureType('subtitles'),
        'price': coreSubtitlesExtraPrice,
        'deliveryTimesIndays': 0,
      });
    }
    if (!coreCommercialIncluded.value && coreCommercialExtraPrice > 0) {
      sharedExtras.add({
        'featureType': _safeFeatureType('commercialUseLicense'),
        'price': coreCommercialExtraPrice,
        'deliveryTimesIndays': 0,
      });
    }

    // custom extras
    for (final e in globalExtras) {
      final inferred = _inferFeatureTypeFromName(e.name);
      final type = _safeFeatureType(inferred);
      if (type.isEmpty) {
        continue;
      }
      sharedExtras.add({
        'featureType': type,
        'price': e.price,
        'deliveryTimesIndays': e.extraDays,
      });
    }

    final pricingList = <Map<String, dynamic>>[];

    for (int i = 0; i < packages.length; i++) {
      final pkg = packages[i].value;

      pricingList.add({
        'pricingName': packageNames[i],
        'currency': selectedCurrency.value,
        'price': pkg.price,
        'deliveryTimeDays': sharedDeliveryDays,
        'numberOfRevisions': sharedRevisions,
        'features': sharedFeatures,
      });
    }

    // harden: ensure additionalFeatures have only allowed keys
    final sanitizedAdditionalFeatures = sharedExtras
        .map((e) {
          final map = Map<String, dynamic>.from(e);
          final featureType = _safeFeatureType(
            (map['featureType'] ?? '').toString(),
          );
          if (featureType.isEmpty) {
            return null;
          }
          return {
            'featureType': featureType,
            'price': map['price'] ?? 0,
            'deliveryTimesIndays': map['deliveryTimesIndays'] ?? 0,
          };
        })
        .whereType<Map<String, dynamic>>()
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
    String _deriveTitle(String text) {
      final cleaned = text.replaceAll('\n', ' ').trim();
      if (cleaned.isEmpty) return 'UGC Video';
      return cleaned.length > 60 ? cleaned.substring(0, 60).trim() : cleaned;
    }

    final title = _deriveTitle(description);

    final videoStylePayload = selectedServiceNiches
        .map(_nicheKeyToPayload)
        .map((name) => name.toString().trim())
        .where((name) => name.isNotEmpty)
        .toList();

    return <String, dynamic>{
      'gigThumbnail': uploadedCoverUrl ?? '',
      'videoStyle': videoStylePayload,
      'pricing': pricingList,
      'additionalFeatures': sanitizedAdditionalFeatures,
      'title': title,
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

      final updatePayload = isEditMode.value
          ? (Map<String, dynamic>.from(payload)..remove('videoStyles'))
          : payload;

      bool _isAdditionalFeatureValidationError(String msg) {
        final m = msg.toLowerCase();
        return m.contains('additionalfeatures') &&
            (m.contains('should not exist') ||
                m.contains('must not exist') ||
                m.contains('not allowed') ||
                m.contains('forbid'));
      }

      String _extractMessage(dynamic raw) {
        if (raw is List) {
          return raw.map((e) => e.toString()).join(', ');
        }
        if (raw == null) return '';
        return raw.toString();
      }

      int? _readStatusCode(dynamic raw) {
        if (raw is! Map) return null;
        final status = raw['statusCode'];
        if (status is int) return status;
        if (status is num) return status.toInt();
        return int.tryParse(status?.toString() ?? '');
      }

      bool _isSuccessResponse(dynamic raw) {
        if (raw is! Map) return false;
        if (raw['error'] == true) return false;
        final statusCode = _readStatusCode(raw);
        if (statusCode == null) {
          // Some endpoints return only {message, data} on success.
          return true;
        }
        return statusCode >= 200 && statusCode < 300;
      }

      bool _needsAdditionalFeatureFallbackFromResponse(dynamic res) {
        if (res is! Map) return false;
        if (res['error'] != true) return false;
        final msg = _extractMessage(res['message']);
        return _isAdditionalFeatureValidationError(msg);
      }

      Map<String, dynamic> _moveAdditionalFeaturesToPricing(
        Map<String, dynamic> body,
      ) {
        final cloned = Map<String, dynamic>.from(body);
        final extrasRaw = cloned['additionalFeatures'];
        final extras = extrasRaw is List
            ? extrasRaw
                  .whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList()
            : <Map<String, dynamic>>[];

        cloned.remove('additionalFeatures');
        if (extras.isEmpty) return cloned;

        if (cloned['pricing'] is List) {
          cloned['pricing'] = (cloned['pricing'] as List).map((p) {
            if (p is! Map) return p;
            final item = Map<String, dynamic>.from(p);
            item['additionalFeatures'] = extras
                .map((e) => Map<String, dynamic>.from(e))
                .toList();
            return item;
          }).toList();
        }

        if (cloned['pricings'] is List) {
          cloned['pricings'] = (cloned['pricings'] as List).map((p) {
            if (p is! Map) return p;
            final item = Map<String, dynamic>.from(p);
            item['additionalFeatures'] = extras
                .map((e) => Map<String, dynamic>.from(e))
                .toList();
            return item;
          }).toList();
        }

        return cloned;
      }

      Map<String, dynamic> _stripAdditionalFeatures(Map<String, dynamic> body) {
        final cloned = Map<String, dynamic>.from(body);
        cloned.remove('additionalFeatures');
        if (cloned['pricing'] is List) {
          cloned['pricing'] = (cloned['pricing'] as List).map((p) {
            if (p is Map) {
              final item = Map<String, dynamic>.from(p);
              item['additionalFeatures'] = <Map<String, dynamic>>[];
              return item;
            }
            return p;
          }).toList();
        }
        if (cloned['pricings'] is List) {
          cloned['pricings'] = (cloned['pricings'] as List).map((p) {
            if (p is Map) {
              final item = Map<String, dynamic>.from(p);
              item['additionalFeatures'] = <Map<String, dynamic>>[];
              return item;
            }
            return p;
          }).toList();
        }
        return cloned;
      }

      Map<String, dynamic> _dropAdditionalFeaturesKey(
        Map<String, dynamic> body,
      ) {
        final cloned = Map<String, dynamic>.from(body);
        cloned.remove('additionalFeatures');
        if (cloned['pricing'] is List) {
          cloned['pricing'] = (cloned['pricing'] as List).map((p) {
            if (p is Map) {
              final item = Map<String, dynamic>.from(p);
              item.remove('additionalFeatures');
              return item;
            }
            return p;
          }).toList();
        }
        if (cloned['pricings'] is List) {
          cloned['pricings'] = (cloned['pricings'] as List).map((p) {
            if (p is Map) {
              final item = Map<String, dynamic>.from(p);
              item.remove('additionalFeatures');
              return item;
            }
            return p;
          }).toList();
        }
        return cloned;
      }

      dynamic response;
      try {
        response = isEditMode.value
            ? await gigCreationRepo.updateGigApi(editingGigId!, updatePayload)
            : await gigCreationRepo.createGigApi(payload);
        if (_needsAdditionalFeatureFallbackFromResponse(response)) {
          final fallbackPayloadLegacy = isEditMode.value
              ? _moveAdditionalFeaturesToPricing(updatePayload)
              : _moveAdditionalFeaturesToPricing(payload);
          response = isEditMode.value
              ? await gigCreationRepo.updateGigApi(
                  editingGigId!,
                  fallbackPayloadLegacy,
                )
              : await gigCreationRepo.createGigApi(fallbackPayloadLegacy);
        }
        if (_needsAdditionalFeatureFallbackFromResponse(response)) {
          final fallbackPayloadStrip = isEditMode.value
              ? _stripAdditionalFeatures(updatePayload)
              : _stripAdditionalFeatures(payload);
          response = isEditMode.value
              ? await gigCreationRepo.updateGigApi(
                  editingGigId!,
                  fallbackPayloadStrip,
                )
              : await gigCreationRepo.createGigApi(fallbackPayloadStrip);
          if (_needsAdditionalFeatureFallbackFromResponse(response)) {
            final fallbackPayloadDrop = isEditMode.value
                ? _dropAdditionalFeaturesKey(updatePayload)
                : _dropAdditionalFeaturesKey(payload);
            response = isEditMode.value
                ? await gigCreationRepo.updateGigApi(
                    editingGigId!,
                    fallbackPayloadDrop,
                  )
                : await gigCreationRepo.createGigApi(fallbackPayloadDrop);
          }
        }
      } catch (firstError) {
        final firstMessage = firstError.toString();
        if (_isAdditionalFeatureValidationError(firstMessage)) {
          // Try 1: legacy backend expects additional features inside each tier.
          final fallbackPayloadLegacy = isEditMode.value
              ? _moveAdditionalFeaturesToPricing(updatePayload)
              : _moveAdditionalFeaturesToPricing(payload);
          try {
            response = isEditMode.value
                ? await gigCreationRepo.updateGigApi(
                    editingGigId!,
                    fallbackPayloadLegacy,
                  )
                : await gigCreationRepo.createGigApi(fallbackPayloadLegacy);
          } catch (_) {
            // Try 2: keep key with empty array.
            final fallbackPayloadStrip = isEditMode.value
                ? _stripAdditionalFeatures(updatePayload)
                : _stripAdditionalFeatures(payload);
            try {
              response = isEditMode.value
                  ? await gigCreationRepo.updateGigApi(
                      editingGigId!,
                      fallbackPayloadStrip,
                    )
                  : await gigCreationRepo.createGigApi(fallbackPayloadStrip);
            } catch (_) {
              // Try 3: remove key entirely as final fallback.
              final fallbackPayloadDrop = isEditMode.value
                  ? _dropAdditionalFeaturesKey(updatePayload)
                  : _dropAdditionalFeaturesKey(payload);
              response = isEditMode.value
                  ? await gigCreationRepo.updateGigApi(
                      editingGigId!,
                      fallbackPayloadDrop,
                    )
                  : await gigCreationRepo.createGigApi(fallbackPayloadDrop);
            }
          }
        } else {
          rethrow;
        }
      }

      uploadProgress.value = 1.0;

      if (Get.isDialogOpen ?? false) Get.back();

      if (response == null) throw Exception('error_no_response'.tr);

      final statusCode = _readStatusCode(response);
      final message = _extractMessage(response['message']);

      if (_isSuccessResponse(response)) {
        if (isEditMode.value) {
          if (Get.isRegistered<ProfileController>()) {
            await Get.find<ProfileController>().refreshAll();
          }
          Get.back();
          try {
            Get.find<GigDetailController>().fetchGigDetail();
          } catch (_) {}
        } else {
          Utils.snackBar('success'.tr, 'publish_success'.tr);
          _navigateToSuccessScreen();
        }
      } else {
        final msg = message.isNotEmpty
            ? message
            : 'error_failed_status'.trParams({'code': '$statusCode'});
        if (_isAdditionalFeatureValidationError(msg)) {
          dynamic retryResponse;

          final fallbackPayloadLegacy = isEditMode.value
              ? _moveAdditionalFeaturesToPricing(updatePayload)
              : _moveAdditionalFeaturesToPricing(payload);
          retryResponse = isEditMode.value
              ? await gigCreationRepo.updateGigApi(
                  editingGigId!,
                  fallbackPayloadLegacy,
                )
              : await gigCreationRepo.createGigApi(fallbackPayloadLegacy);

          final retryStatus = _readStatusCode(retryResponse);
          final retryMessage = _extractMessage(retryResponse?['message']);

          if ((retryStatus != 200 && retryStatus != 201) &&
              _isAdditionalFeatureValidationError(retryMessage)) {
            final fallbackPayloadStrip = isEditMode.value
                ? _stripAdditionalFeatures(updatePayload)
                : _stripAdditionalFeatures(payload);
            retryResponse = isEditMode.value
                ? await gigCreationRepo.updateGigApi(
                    editingGigId!,
                    fallbackPayloadStrip,
                  )
                : await gigCreationRepo.createGigApi(fallbackPayloadStrip);
          }

          final retryStatusAfterStrip = _readStatusCode(retryResponse);
          final retryMessageAfterStrip = _extractMessage(
            retryResponse?['message'],
          );
          if ((retryStatusAfterStrip != 200 && retryStatusAfterStrip != 201) &&
              _isAdditionalFeatureValidationError(retryMessageAfterStrip)) {
            final fallbackPayloadDrop = isEditMode.value
                ? _dropAdditionalFeaturesKey(updatePayload)
                : _dropAdditionalFeaturesKey(payload);
            retryResponse = isEditMode.value
                ? await gigCreationRepo.updateGigApi(
                    editingGigId!,
                    fallbackPayloadDrop,
                  )
                : await gigCreationRepo.createGigApi(fallbackPayloadDrop);
          }

          final retryStatusAfterDrop = _readStatusCode(retryResponse);
          final retryMessageAfterDrop = _extractMessage(
            retryResponse?['message'],
          );
          if (_isSuccessResponse(retryResponse)) {
            if (isEditMode.value) {
              if (Get.isRegistered<ProfileController>()) {
                await Get.find<ProfileController>().refreshAll();
              }
              Get.back();
              try {
                Get.find<GigDetailController>().fetchGigDetail();
              } catch (_) {}
            } else {
              Utils.snackBar('success'.tr, 'publish_success'.tr);
              _navigateToSuccessScreen();
            }
          } else {
            throw Exception(
              retryMessageAfterDrop.isNotEmpty
                  ? retryMessageAfterDrop
                  : 'error_failed_status'.trParams({
                      'code': '${retryStatusAfterDrop ?? '-'}',
                    }),
            );
          }
        } else {
          throw Exception(msg);
        }
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                  isEditMode.value
                      ? 'uploading_title_update'.tr
                      : 'uploading_title_create'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() {
                  final progress = uploadProgress.value;
                  String message = 'upload_preparing'.tr;
                  if (progress < 0.5)
                    message = 'upload_uploading_videos'.tr;
                  else if (progress < 1.0)
                    message = 'upload_finalizing'.tr;
                  else
                    message = 'upload_complete'.tr;
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
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColor.primaryColor,
                          ),
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

  // ================= Public helpers =================

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
    markPreviewDirty();
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
    coreCommercialPriceController.dispose();
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
