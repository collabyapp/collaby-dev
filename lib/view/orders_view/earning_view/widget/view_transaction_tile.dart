
import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
class ViewTransactionsTile extends StatelessWidget {
  final VoidCallback onTap;
  const ViewTransactionsTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Color(0xFFF1ECFF),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Image.asset(ImageAssets.transactionIcon, width: 24),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Text(
                'View Transactions History',
                style: AppTextStyles.normalTextMedium,
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

