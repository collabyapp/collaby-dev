import 'package:collaby_app/models/chat_model/chat_model.dart';
import 'package:collaby_app/models/profile_model/user_model.dart';
import 'package:collaby_app/res/colors/app_color.dart';
import 'package:collaby_app/res/components/Button.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/utils/utils.dart';
import 'package:collaby_app/view_models/controller/chat_controller/chat_controller.dart';
import 'package:collaby_app/view_models/controller/profile_controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OfferScreen extends StatefulWidget {
  @override
  State<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {
  final ChatController chatController = Get.find<ChatController>();
  final ProfileController gigsController = Get.put(ProfileController());

  final _formKey = GlobalKey<FormState>();

  final TextEditingController priceController = TextEditingController();
  final TextEditingController revisionsController = TextEditingController(
    text: '3',
  );
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController videoTimelineController = TextEditingController(
    text: '15',
  );

  final RxString selectedGigId = ''.obs;
  // final RxInt selectedVideoLength = 15.obs;
  final RxInt selectedDeliveryDays = 1.obs;
  final RxBool isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _loadGigs();
  }

  Future<void> _loadGigs() async {
    try {
      isLoading.value = true;
      await gigsController.fetchMyGigs(refresh: true);

      // Select first gig by default if available
      if (gigsController.myGigs.isNotEmpty) {
        selectedGigId.value = gigsController.myGigs.first.gigId;
        // Set starting price as default price
        priceController.text = gigsController.myGigs.first.startingPrice
            .toString();
      } else {
        // No gigs available
        Utils.snackBar(
          'No Gigs Available',
          'Please create a gig first to send custom offers.',
        );
        Get.back();
      }
    } catch (e) {
      Utils.snackBar('Error', 'Failed to load gigs: ${e.toString()}');
      Get.back();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text('Create an Offer', style: AppTextStyles.normalTextBold),
        centerTitle: true,
      ),
      body: Obx(() {
        if (isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading your gigs...', style: AppTextStyles.smallText),
              ],
            ),
          );
        }

        if (gigsController.myGigs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.work_off_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No Gigs Available', style: AppTextStyles.normalTextBold),
                SizedBox(height: 8),
                Text(
                  'Create a gig to send custom offers',
                  style: AppTextStyles.smallText,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGigSelection(),
                      SizedBox(height: 24),
                      _buildOfferDetails(),
                      SizedBox(height: 24),
                      _buildDescriptionField(),
                    ],
                  ),
                ),
              ),
              _buildBottomSection(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildGigSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Select Gig',
              style: AppTextStyles.smallText.copyWith(color: Color(0xff172B4D)),
            ),
            Spacer(),
            TextButton(
              onPressed: () => _showGigSelector(),
              child: Text(
                'Change',
                style: AppTextStyles.smallTextBold.copyWith(
                  color: Color(0xff816CED),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Obx(() {
          final selectedGig = gigsController.myGigs.firstWhere(
            (gig) => gig.gigId == selectedGigId.value,
            orElse: () => gigsController.myGigs.first,
          );

          return Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    selectedGig.gigThumbnail,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[300],
                      child: Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedGig.gigTitle,
                        style: AppTextStyles.smallMediumText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Starting at \$${selectedGig.startingPrice}',
                        style: AppTextStyles.extraSmallText.copyWith(
                          color: AppColor.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildOfferDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Offer Detail', style: AppTextStyles.normalTextBold),
        SizedBox(height: 10),

        // Video Timeline
        Text(
          'Video Timeline',
          style: AppTextStyles.smallText.copyWith(color: Color(0XFF172B4D)),
        ),
        SizedBox(height: 8),

        TextFormField(
          controller: videoTimelineController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'Video Timeline (seconds)',
            prefixText: 'sec ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.purple),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a video Duration';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            if (double.parse(value) <= 0) {
              return 'Duration must be greater than 0';
            }
            return null;
          },
        ),

        // Obx(
        //   () => Container(
        //     decoration: BoxDecoration(
        //       borderRadius: BorderRadius.circular(30),
        //       color: Colors.white,
        //       border: Border.all(color: Colors.grey[300]!),
        //     ),
        //     child: Padding(
        //       padding: const EdgeInsets.symmetric(
        //         horizontal: 10.0,
        //         vertical: 5,
        //       ),
        //       child: Row(
        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //         children: [
        //           _buildTimeOption('15 Sec', 15),
        //           SizedBox(width: 12),
        //           _buildTimeOption('30 Sec', 30),
        //           SizedBox(width: 12),
        //           _buildTimeOption('60 Sec', 60),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
        SizedBox(height: 20),

        // Your Price
        Text(
          'Your Price',
          style: AppTextStyles.smallText.copyWith(color: Color(0XFF172B4D)),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: priceController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'Price (USD)',
            prefixText: '\$ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.purple),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a price';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            if (double.parse(value) <= 0) {
              return 'Price must be greater than 0';
            }
            return null;
          },
        ),

        SizedBox(height: 20),

        // Delivery Time
        Text(
          'Delivery Time',
          style: AppTextStyles.smallText.copyWith(color: Color(0XFF172B4D)),
        ),
        SizedBox(height: 8),
        _buildDeliveryTimeSelector(),

        // GestureDetector(
        //   onTap: () => _showDeliveryTimeSelector(),
        //   child: Container(
        //     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        //     decoration: BoxDecoration(
        //       border: Border.all(color: Colors.grey[300]!),
        //       borderRadius: BorderRadius.circular(8),
        //     ),
        //     child: Row(
        //       children: [
        //         Obx(
        //           () => Text(
        //             selectedDeliveryDays.value == 1
        //                 ? '1 day'
        //                 : '${selectedDeliveryDays.value} days',
        //             style: TextStyle(
        //               color: selectedDeliveryDays.value > 0
        //                   ? Colors.black
        //                   : Colors.grey[500],
        //             ),
        //           ),
        //         ),
        //         Spacer(),
        //         Icon(Icons.keyboard_arrow_right, color: Colors.grey[500]),
        //       ],
        //     ),
        //   ),
        // ),
        SizedBox(height: 20),

        // Number of Revisions
        Text(
          'Number of Revisions',
          style: AppTextStyles.smallText.copyWith(color: Color(0XFF172B4D)),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: revisionsController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.purple),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter number of revisions';
            }
            if (int.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
      ],
    );
  }

  // Widget _buildTimeOption(String label, int seconds) {
  //   return GestureDetector(
  //     onTap: () => selectedVideoLength.value = seconds,
  //     child: Container(
  //       padding: EdgeInsets.symmetric(horizontal: 30, vertical: 6),
  //       decoration: BoxDecoration(
  //         color: selectedVideoLength.value == seconds
  //             ? Color(0xff917DE5)
  //             : Colors.transparent,
  //         borderRadius: BorderRadius.circular(20),
  //       ),
  //       child: Text(
  //         label,
  //         style: TextStyle(
  //           fontFamily: AppFonts.OpenSansRegular,
  //           color: selectedVideoLength.value == seconds
  //               ? Colors.white
  //               : Colors.black,
  //           fontSize: 12,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildDeliveryTimeSelector() {
    return GestureDetector(
      onTap: () => _showDeliveryTimeBottomSheet(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          // color: Colors.grey[50],
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Obx(
              () => Text(
                selectedDeliveryDays.value == 1
                    ? '1 day '
                    : '${selectedDeliveryDays.value} days',
                style: AppTextStyles.smallMediumText,
              ),
            ),
            Spacer(),
            Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Describe Your Offer', style: AppTextStyles.normalTextBold),
        SizedBox(height: 8),
        TextFormField(
          controller: descriptionController,
          maxLines: 5,
          maxLength: 1000,
          decoration: InputDecoration(
            hintText: 'Describe what you will deliver...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.purple),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please describe your offer';
            }
            if (value.trim().length < 20) {
              return 'Description must be at least 20 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(
          () => CustomButton(
            title: chatController.isSaving.value ? 'Sending...' : 'Send Offer',
            onPressed: chatController.isSaving.value ? null : _sendOffer,
          ),
        ),
      ),
    );
  }

  void _showGigSelector() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 16),
            Text('Select Gig', style: AppTextStyles.h6),
            SizedBox(height: 16),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  shrinkWrap: true,
                  itemCount: gigsController.myGigs.length,
                  itemBuilder: (context, index) {
                    final gig = gigsController.myGigs[index];
                    return _buildGigOption(gig);
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildGigOption(MyGigModel gig) {
    return Obx(
      () => GestureDetector(
        onTap: () {
          selectedGigId.value = gig.gigId;
          // Update price when changing gig
          priceController.text = gig.startingPrice.toString();
          Get.back();
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: selectedGigId.value == gig.gigId
                  ? AppColor.primaryColor
                  : Colors.grey[300]!,
              width: selectedGigId.value == gig.gigId ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: selectedGigId.value == gig.gigId
                ? AppColor.primaryColor.withOpacity(0.05)
                : Colors.white,
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  gig.gigThumbnail,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: Icon(Icons.image, color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gig.gigTitle,
                      style: AppTextStyles.smallMediumText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Starting at \$${gig.startingPrice}',
                      style: AppTextStyles.extraSmallText.copyWith(
                        color: AppColor.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (gig.reviewStats.totalReviews > 0) ...[
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.amber),
                          SizedBox(width: 4),
                          Text(
                            '${gig.reviewStats.averageRating.toStringAsFixed(1)} (${gig.reviewStats.totalReviews})',
                            style: AppTextStyles.extraSmallText,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (selectedGigId.value == gig.gigId)
                Icon(
                  Icons.check_circle,
                  color: AppColor.primaryColor,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeliveryTimeBottomSheet() {
    final deliveryOptions = [1, 2, 3, 5, 7, 14, 21, 30];

    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text('Select Delivery Time', style: AppTextStyles.h6),
                ],
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Choose how many days you need to complete this project',
                style: AppTextStyles.extraSmallText.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
            SizedBox(height: 16),
            Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: deliveryOptions.length,
                itemBuilder: (context, index) {
                  final days = deliveryOptions[index];
                  return Obx(
                    () => InkWell(
                      onTap: () {
                        selectedDeliveryDays.value = days;
                        Get.back();
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 8),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: selectedDeliveryDays.value == days
                              ? AppColor.primaryColor.withOpacity(0.1)
                              : Colors.white,
                          border: Border.all(
                            color: selectedDeliveryDays.value == days
                                ? AppColor.primaryColor
                                : Colors.grey[200]!,
                            width: selectedDeliveryDays.value == days ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: selectedDeliveryDays.value == days
                                    ? AppColor.primaryColor.withOpacity(0.2)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.access_time,
                                color: selectedDeliveryDays.value == days
                                    ? AppColor.primaryColor
                                    : Colors.grey[600],
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                days == 1 ? '1 day' : '$days days',
                                style: AppTextStyles.smallMediumText.copyWith(
                                  fontWeight: selectedDeliveryDays.value == days
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: selectedDeliveryDays.value == days
                                      ? AppColor.primaryColor
                                      : Colors.black87,
                                ),
                              ),
                            ),
                            if (selectedDeliveryDays.value == days)
                              Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColor.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              )
                            else
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 2,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _sendOffer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (chatController.isSaving.value) {
      return;
    }

    try {
      final selectedGig = gigsController.myGigs.firstWhere(
        (gig) => gig.gigId == selectedGigId.value,
        orElse: () => gigsController.myGigs.first,
      );

      final offerDetails = OfferDetails(
        gigTitle: selectedGig.gigTitle,
        gigDescription: descriptionController.text.trim(),
        videoLength: int.tryParse(videoTimelineController.text) ?? 15,
        price: double.parse(priceController.text),
        deliveryDays: selectedDeliveryDays.value,
        revisions: int.parse(revisionsController.text),
        gigThumbnail: selectedGig.gigThumbnail,
        currency: 'USD',
        status: 'pending',
      );

      // Send the offer
      await chatController.sendCustomOffer(offerDetails, selectedGig.gigId);

      // Success - screen will be closed by controller
    } catch (e) {
      Utils.snackBar(
        'Error',
        'Failed to send offer: ${e.toString()}',
        // backgroundColor: Colors.red[100],
        // colorText: Colors.red[900],
      );
    }
  }

  @override
  void dispose() {
    priceController.dispose();
    revisionsController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
