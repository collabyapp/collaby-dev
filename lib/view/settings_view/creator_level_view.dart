import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view_models/controller/profile_controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreatorLevelView extends StatelessWidget {
  CreatorLevelView({super.key});

  final ProfileController controller = Get.put(ProfileController());

  String _normalizeBadge(String raw) {
    final v = raw.trim().toLowerCase();
    if (v == 'pro' || v == 'level_three' || v == 'level3') return 'pro';
    if (v == 'level_two' || v == 'level2') return 'level_two';
    if (v == 'level_one' || v == 'level1') return 'level_one';
    return 'level_one';
  }

  String _levelLabel(String badge) {
    switch (badge) {
      case 'pro':
        return 'creator_level_pro'.tr;
      case 'level_two':
        return 'creator_level_two'.tr;
      default:
        return 'creator_level_one'.tr;
    }
  }

  List<String> _benefits(String levelKey) {
    switch (levelKey) {
      case 'pro':
        return const [
          'level_feature_max_visibility',
          'level_feature_promote_priority',
          'level_feature_support_priority_high',
        ];
      case 'level_two':
        return const [
          'level_feature_promote_enabled',
          'level_feature_priority_discovery',
          'level_feature_support_priority_medium',
        ];
      default:
        return const [
          'level_feature_standard_visibility',
          'level_feature_support_standard',
        ];
    }
  }

  String _withdrawalKey(String levelKey) {
    switch (levelKey) {
      case 'pro':
        return 'level_withdrawal_3_days';
      case 'level_two':
        return 'level_withdrawal_7_days';
      default:
        return 'level_withdrawal_14_days';
    }
  }

  Widget _levelCard({required String keyName, required bool isCurrent}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCurrent ? const Color(0xffEFEAFF) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent ? const Color(0xff816CED) : const Color(0xffE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _levelLabel(keyName),
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: AppFonts.OpenSansBold,
                    color: Color(0xff111827),
                  ),
                ),
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xff4D2CAD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'creator_level_current_badge'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontFamily: AppFonts.OpenSansSemiBold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ..._benefits(keyName).map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text('\u2022 ${b.tr}'),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'level_withdrawal_eta'.trParams({
              'time': _withdrawalKey(keyName).tr,
            }),
            style: const TextStyle(
              fontFamily: AppFonts.OpenSansSemiBold,
              color: Color(0xff374151),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('creator_level_title'.tr), centerTitle: true),
      body: Obx(() {
        final profile = controller.profileData.value;
        final normalizedBadge = _normalizeBadge(profile?.badge ?? 'level_one');
        final progress = profile?.creatorLevelProgress;
        final progressPct = (progress?.levelTwoProgressPercent ?? 0).clamp(
          0,
          100,
        );

        return RefreshIndicator(
          onRefresh: controller.refreshAll,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xffF7F5FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffE2DBFF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'creator_level_current'.trParams({
                        'level': _levelLabel(normalizedBadge),
                      }),
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: AppFonts.OpenSansSemiBold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (progress != null) ...[
                      Text(
                        'creator_level_progress'.trParams({
                          'percent': '$progressPct',
                        }),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          value: progressPct / 100,
                          backgroundColor: const Color(0xffE9E3FF),
                          valueColor: const AlwaysStoppedAnimation(
                            Color(0xff816CED),
                          ),
                        ),
                      ),
                    ] else
                      Text('creator_level_progress_unavailable'.tr),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _levelCard(
                keyName: 'level_one',
                isCurrent: normalizedBadge == 'level_one',
              ),
              _levelCard(
                keyName: 'level_two',
                isCurrent: normalizedBadge == 'level_two',
              ),
              _levelCard(keyName: 'pro', isCurrent: normalizedBadge == 'pro'),
            ],
          ),
        );
      }),
    );
  }
}
