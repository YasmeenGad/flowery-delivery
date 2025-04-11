import 'package:auto_size_text/auto_size_text.dart';
import 'package:flowery_delivery/core/utils/extension/string_exetension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/styles/colors/my_colors.dart';
import '../../../../core/styles/fonts/my_fonts.dart';
import '../viewModel/profile_view_model_cubit.dart';
import 'custom_picture_main_screen.dart';

class CustomMainProfileData extends StatelessWidget {
  const CustomMainProfileData({super.key, required this.state});

  final GetLoggedUserDataSuccess state;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16.w,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
Expanded(child:  CustomPictureMainScreen(image: state.data.driver!.photo!.imageFormat()))
       ,
        Expanded(
          flex: 3,
          child:  Column(
          spacing: 6.h,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(child: AutoSizeText('${state.data.driver!.firstName}',
                style: MyFonts.styleMedium500_18)),
            FittedBox(child: AutoSizeText('${state.data.driver!.email}',)),
            AutoSizeText('${state.data.driver!.phone}',
                style: MyFonts.styleRegular400_16),
          ],
        ),),

        Icon(
          Icons.arrow_forward_ios,
          color: MyColors.grey,
          size: 20.sp,
        ),
      ],
    );
  }
}
