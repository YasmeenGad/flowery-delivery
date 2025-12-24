import 'package:flowery_delivery/core/styles/colors/my_colors.dart';
import 'package:flowery_delivery/core/styles/fonts/my_fonts.dart';
import 'package:flowery_delivery/core/utils/widgets/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GenderSelectionWidget extends StatefulWidget {
  final ValueChanged<String?> selectedGenderCallback;

  const GenderSelectionWidget({
    super.key,
    required this.selectedGenderCallback,
  });

  @override
  State<GenderSelectionWidget> createState() => _GenderSelectionWidgetState();
}

class _GenderSelectionWidgetState extends State<GenderSelectionWidget> {
  String? selectedGender;

  void _updateGender(String? value) {
    setState(() => selectedGender = value);
    widget.selectedGenderCallback(value);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Gender',
          style: MyFonts.styleMedium500_18.copyWith(color: MyColors.gray),
        ),
        horizontalSpacing(20.w),

        // ✅ New API: handle selection via RadioGroup
        RadioGroup<String>(
          groupValue: selectedGender,
          onChanged: _updateGender,
          child: Row(
            children: [
              Row(
                children: [
                  Radio<String>(
                    value: 'female',
                    activeColor: MyColors.baseColor,
                  ),
                  Text(
                    'female',
                    style: MyFonts.styleRegular400_16
                        .copyWith(color: MyColors.blackBase),
                  ),
                ],
              ),
              horizontalSpacing(20.w),
              Row(
                children: [
                  Radio<String>(
                    value: 'male',
                    activeColor: MyColors.baseColor,
                  ),
                  Text(
                    'male',
                    style: MyFonts.styleRegular400_16
                        .copyWith(color: MyColors.blackBase),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
