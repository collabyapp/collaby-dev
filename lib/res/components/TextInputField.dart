import 'package:flutter/material.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';

/// Reusable text field with prefix icon, error text, and suffix
class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final error = errorText != null;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: error ? const Color(0xFFFF6B6B) : const Color(0xFFE7E7EE),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 13),

                  child: Text(
                    label,
                    style: AppTextStyles.extraSmallText.copyWith(
                      color: Color(0xff606A79),
                    ),
                  ),
                ),

                TextField(
                  onChanged: onChanged,
                  keyboardType: keyboardType,
                  obscureText: obscureText,
                  style: AppTextStyles.normalText,
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTextStyles.normalText.copyWith(
                      color: Color(0xffA0AEC0),
                    ),
                    prefixIcon: prefixIcon,
                    suffixIcon: suffixIcon,
                    // filled: false,
                    border: InputBorder.none,
                    // fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),

                    // border: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(14),
                    //   borderSide: const BorderSide(color: Color(0xFFE7E7EE)),
                    // ),
                    // enabledBorder: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(14),
                    //   borderSide: BorderSide(
                    //     color: error
                    //         ? const Color(0xFFFF6B6B)
                    //         : const Color(0xFFE7E7EE),
                    //     width: 1.4,
                    //   ),
                    // ),
                    // focusedBorder: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(14),
                    //   borderSide: BorderSide(
                    //     color: error
                    //         ? const Color(0xFFFF6B6B)
                    //         : const Color(0xFF6C63FF),
                    //     width: 1.6,
                    //   ),
                    // ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (error)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorText!,
              style: const TextStyle(color: Color(0xFFFF4444), fontSize: 12),
            ),
          ),
      ],
    );
  }
}
