import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/view_models/controller/profile_controller/boost_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class BoostDetailsScreen extends StatelessWidget {
  BoostDetailsScreen({Key? key}) : super(key: key);

  final BoostProfileController controller = Get.put(BoostProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Boost Profile'), centerTitle: false),
      body: Obx(() {
        if (controller.isLoading.value && controller.boostData.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.boostData.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Failed to load boost profile'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refreshData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final subscription = controller.boostData.value!.subscription;
        final analytics = controller.boostData.value!.analytics;
        final performanceGraph = controller.boostData.value!.performanceGraph;

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Boost Card
                _buildPremiumBoostCard(subscription),
                const SizedBox(height: 24),

                // Analytics Overview
                _buildAnalyticsSection(analytics),
                const SizedBox(height: 24),

                // Boost Performance Graph
                _buildPerformanceGraph(performanceGraph),
                const SizedBox(height: 24),

                // Auto-Boost Monthly
                if (subscription.autoRenewal)
                  _buildAutoBoostSection(subscription),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPremiumBoostCard(subscription) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Premium Boost', style: AppTextStyles.h6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Color(0xffDCFCE7),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  subscription.planDetails.badge,
                  style: AppTextStyles.extraSmallMediumText.copyWith(
                    color: Color(0xff166534),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Features
          ...subscription.planDetails.features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check, size: 20, color: Colors.black),
                  const SizedBox(width: 8),
                  Text(feature, style: AppTextStyles.extraSmallText),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Price
          Row(
            children: [
              Image.asset(ImageAssets.dollarIcon, color: Color(0xffFACC15)),
              const SizedBox(width: 8),
              Text(
                '\$${subscription.planDetails.price}',
                style: AppTextStyles.h6Bold,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Duration Slider (Static - for display only)
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: subscription.daysRemaining / subscription.duration,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF917DE5),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Dates
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start Date',
                    style: AppTextStyles.extraSmallText.copyWith(fontSize: 10),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.getFormattedStartDate(),
                    style: AppTextStyles.extraSmallMediumText,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'End Date',
                    style: AppTextStyles.extraSmallText.copyWith(fontSize: 10),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.getFormattedEndDate(),
                    style: AppTextStyles.extraSmallMediumText,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection(analytics) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Analytic Overview',
                style: AppTextStyles.extraSmallMediumText.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                controller.getAnalyticsPeriod(),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAnalyticCard(
                controller.formatNumber(analytics.profileViews),
                'Profile View',
                isLargeText: true,
              ),
              Container(
                width: 1, // Set the width for the vertical line
                height:
                    40, // Ensure the height is enough to match the card height
                color: Colors.black.withOpacity(
                  0.28,
                ), // Set the color of the divider
              ),

              _buildAnalyticCard(
                '${analytics.responseRate}%',
                'Response Rate',
                isLargeText: true,
              ),
              Container(
                width: 1, // Set the width for the vertical line
                height:
                    40, // Ensure the height is enough to match the card height
                color: Colors.black.withOpacity(
                  0.28,
                ), // Set the color of the divider
              ),

              _buildAnalyticCard(
                analytics.newLeads.toString(),
                'New Leads',
                isLargeText: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticCard(
    String number,
    String label, {
    bool isLargeText = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            number,

            style: AppTextStyles.normalTextMedium.copyWith(
              color: Color(0xff4C1CAE),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.extraSmallText),
        ],
      ),
    );
  }

  Widget _buildPerformanceGraph(performanceGraph) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Boost Performance',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildLegend(Color(0xff5DA160), 'Profile View'),
              const SizedBox(width: 16),
              _buildLegend(Color(0xFF816CED), 'Engagement'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 100,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: Colors.grey[200], strokeWidth: 1);
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 &&
                            index < performanceGraph.dailyData.length) {
                          final date = DateTime.parse(
                            performanceGraph.dailyData[index].date,
                          );
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('EEE').format(date).substring(0, 3),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 11,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 100,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (performanceGraph.dailyData.length - 1).toDouble(),
                minY: 0,
                maxY: 500,
                lineBarsData: [
                  // Profile Views Line
                  LineChartBarData(
                    spots: List<FlSpot>.from(
                      performanceGraph.dailyData.asMap().entries.map(
                        (entry) => FlSpot(
                          entry.key.toDouble(),
                          entry.value.profileViews.toDouble(),
                        ),
                      ),
                    ),
                    isCurved: true,
                    color: Color(0xff5DA160),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                  // Engagement/Response Rate Line
                  LineChartBarData(
                    spots: List<FlSpot>.from(
                      performanceGraph.dailyData.asMap().entries.map(
                        (entry) => FlSpot(
                          entry.key.toDouble(),
                          entry.value.responseRate.toDouble(),
                        ),
                      ),
                    ),
                    isCurved: true,
                    color: Color(0xFF816CED),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.extraSmallMediumText.copyWith(fontSize: 8),
        ),
      ],
    );
  }

  Widget _buildAutoBoostSection(subscription) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Auto-Boost Monthly', style: AppTextStyles.normalTextMedium),
              SizedBox(height: 4),
              Text(
                'Save 20% with auto renewal',
                style: AppTextStyles.extraSmallText,
              ),
            ],
          ),
          Obx(
            () => Switch(
              value: subscription.autoRenewal,
              onChanged: controller.isAutoRenewalUpdating.value
                  ? null
                  : (_) => controller.toggleAutoRenewal(),
              activeColor: const Color(0xFF7C5FFF),
            ),
          ),
        ],
      ),
    );
  }
}


